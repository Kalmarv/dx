//! RSX fragment instructions. Words in the big-endian microcode are rotated by
//! 16 bits before field extraction. Inline constants occupy one further slot.
//! This reads instructions; it neither executes nor lowers them.
use primase_foundations::bytes::View;
use std::fmt::Write;

macro_rules! opcodes {
    ($($name:ident = $code:literal, $arity:literal;)+) => {
        /// A fragment instruction's opcode.
        #[derive(Clone, Copy, Debug, PartialEq, Eq)]
        #[repr(u8)]
        pub enum Opcode {
            $(
                #[doc = concat!("`", stringify!($name), "`, opcode ", stringify!($code), ", with ", stringify!($arity), " sources.")]
                $name = $code,
            )+
        }
        impl Opcode {
            fn read(code: u8) -> Option<Self> { match code { $($code => Some(Self::$name),)+ _ => None } }
            /// The opcode's name in upper case (`MOV`, `TEX`, ...).
            pub fn mnemonic(self) -> &'static str { match self { $(Self::$name => stringify!($name),)+ } }
            /// How many sources the instruction reads.
            pub fn source_count(self) -> usize { match self { $(Self::$name => $arity,)+ } }
        }
    }
}

// The arithmetic/texture vocabulary follows NV_fragment_program[2]. The RSX
// encodings are described by the public RSX instruction declarations.
opcodes! {
    NOP=0x00,0; MOV=0x01,1; MUL=0x02,2; ADD=0x03,2; MAD=0x04,3;
    DP3=0x05,2; DP4=0x06,2; DST=0x07,2; MIN=0x08,2; MAX=0x09,2;
    SLT=0x0a,2; SGE=0x0b,2; SLE=0x0c,2; SGT=0x0d,2; SNE=0x0e,2; SEQ=0x0f,2;
    FRC=0x10,1; FLR=0x11,1; KIL=0x12,0; PK4=0x13,1; UP4=0x14,1;
    DDX=0x15,1; DDY=0x16,1; TEX=0x17,1; TXP=0x18,1; TXD=0x19,3;
    RCP=0x1a,1; RSQ=0x1b,1; EX2=0x1c,1; LG2=0x1d,1; LIT=0x1e,1; LRP=0x1f,3;
    STR=0x20,0; SFL=0x21,0; COS=0x22,1; SIN=0x23,1; PK2=0x24,1; UP2=0x25,1;
    POW=0x26,2; PKB=0x27,1; UPB=0x28,1; PK16=0x29,1; UP16=0x2a,1;
    PKG=0x2c,1; UPG=0x2d,1; DP2A=0x2e,3; TXL=0x2f,2; TXB=0x31,2;
    REFL=0x36,2; DP2=0x38,2; NRM=0x39,1; DIV=0x3a,2; DIVSQ=0x3b,2; LIF=0x3c,1;
    FENCT=0x3d,0; FENCB=0x3e,0; BRK=0x40,0; CAL=0x41,0;
    IFE=0x42,0; LOOP=0x43,0; REP=0x44,0; RET=0x45,0;
}

impl Opcode {
    /// The opcode with this number (the 7-bit value of the instruction's opcode field), if the reader has an entry for it.
    pub fn from_code(code: u8) -> Option<Self> {
        Self::read(code)
    }

    /// The name Mesa's nouveau driver gives the opcode number, where its `nvfx_shader.h` defines one; `None` for the
    /// numbers it does not (`PKG`, `UPG`, `DP2`, `NRM`, `DIVSQ` and the two fences). [`Opcode::mnemonic`] is the name
    /// RPCS3's declarations use. The two agree except for `PK4`/`PK4B`, `UP4`/`UP4B`, `PK2`/`PK2H`, `UP2`/`UP2H`,
    /// `PKB`/`PK4UB`, `UPB`/`UP4UB`, `PK16`/`PK2US`, `UP16`/`UP2US`, `REFL`/`RFL`, `LIF`/`LITEX2` and `IFE`/`IF`.
    pub fn mesa_name(self) -> Option<&'static str> {
        Some(match self {
            Self::PK4 => "PK4B",
            Self::UP4 => "UP4B",
            Self::PK2 => "PK2H",
            Self::UP2 => "UP2H",
            Self::PKB => "PK4UB",
            Self::UPB => "UP4UB",
            Self::PK16 => "PK2US",
            Self::UP16 => "UP2US",
            Self::REFL => "RFL",
            Self::LIF => "LITEX2",
            Self::IFE => "IF",
            Self::PKG | Self::UPG | Self::DP2 | Self::NRM | Self::DIVSQ | Self::FENCT | Self::FENCB => {
                return None;
            }
            other => other.mnemonic(),
        })
    }

    /// Whether the instruction samples a texture.
    pub fn samples_texture(self) -> bool {
        matches!(self, Self::TEX | Self::TXP | Self::TXD | Self::TXL | Self::TXB)
    }
    /// Whether the instruction writes a destination register or condition code.
    pub fn writes_destination(self) -> bool {
        !matches!(
            self,
            Self::NOP
                | Self::KIL
                | Self::FENCT
                | Self::FENCB
                | Self::BRK
                | Self::CAL
                | Self::IFE
                | Self::LOOP
                | Self::REP
                | Self::RET
        )
    }
}

/// A fragment register.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct Register {
    /// The register number (0 to 63).
    pub index: u8,
    /// Whether it is a half-precision register (`h<n>`) rather than a full one (`r<n>`).
    pub half: bool,
}

/// What a source operand reads.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum SourceKind {
    /// A register.
    Register(Register),
    /// An interpolated input, by its 4-bit input index ([`InputSource::from_index`] names it).
    Input(u8),
    /// The inline constant in the slot after the instruction.
    Constant,
}

/// The interpolant an input operand reads, from its 4-bit input index ([`SourceKind::Input`]).
///
/// On the programs of Tony Hawk's SHRED (3,267 distinct fragment programs) the indices read are 1 (9 programs), 4 to 11
/// and 13. Index `4 + k` is texture coordinate set `k`: the program header's `tex_coords_input_mask` has bit `k` set
/// exactly when index `4 + k` is read, in all 3,267 programs for `k` 0 to 7 and 9 (`k` 8 is never read and its bit is
/// never set). Index 1 is the first colour: the header's `attribute_input_mask` has bits 0 and 2 set in the nine
/// programs that read it. Indices 0, 2, 3, 12 and 14 are never read there: [`InputSource::TexCoord`] names 12 by the
/// same rule, the other four are left as [`InputSource::Other`].
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum InputSource {
    /// Input index 1, the first colour.
    Color0,
    /// Input index `4 + k`, texture coordinate set `k` (0 to 9).
    TexCoord(u8),
    /// An index that is neither (0, 2, 3, 14, 15 and the 4-bit values nothing names).
    Other(u8),
}

impl InputSource {
    /// The first input index of the texture coordinate sets.
    const TEXCOORD_BASE: u8 = 4;
    /// How many texture coordinate sets the indices reach.
    const TEXCOORDS: u8 = 10;

    /// The interpolant input index `index` (the 4-bit field of the instruction) reads.
    pub fn from_index(index: u8) -> Self {
        match index {
            1 => Self::Color0,
            i => match i.checked_sub(Self::TEXCOORD_BASE) {
                Some(k) if k < Self::TEXCOORDS => Self::TexCoord(k),
                _ => Self::Other(i),
            },
        }
    }

    /// The input index of this interpolant: the inverse of [`InputSource::from_index`].
    pub fn index(self) -> u8 {
        match self {
            Self::Color0 => 1,
            Self::TexCoord(k) => Self::TEXCOORD_BASE.saturating_add(k),
            Self::Other(i) => i,
        }
    }
}

impl SourceKind {
    /// The interpolant this operand reads, if it is an input operand.
    pub fn input_source(self) -> Option<InputSource> {
        match self {
            Self::Input(index) => Some(InputSource::from_index(index)),
            _ => None,
        }
    }
}

/// A source operand.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Source {
    /// What the source reads.
    pub kind: SourceKind,
    /// For each lane the component (0 x to 3 w) it reads.
    pub swizzle: [u8; 4],
    /// The source is negated.
    pub negate: bool,
    /// The source's absolute value is used.
    pub absolute: bool,
}

/// The condition code test an instruction executes under.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Predicate {
    /// Bit 0 less, bit 1 equal, bit 2 greater. Zero never executes; seven always executes.
    pub test: u8,
    /// For each lane the component of the condition code it tests.
    pub swizzle: [u8; 4],
    /// Which of the two condition-code registers it tests.
    pub register: u8,
}

impl Predicate {
    /// NV condition-code test, with all three outcomes enabled meaning true.
    pub fn condition(self) -> &'static str {
        match self.test {
            0 => "FL",
            1 => "LT",
            2 => "EQ",
            3 => "LE",
            4 => "GT",
            5 => "NE",
            6 => "GE",
            7 => "TR",
            _ => "invalid",
        }
    }
}

/// What a flow-control instruction does.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Control {
    /// `IFE`: a conditional block.
    If {
        /// The byte offset of the else block.
        else_offset: usize,
        /// The byte offset where the block ends.
        end_offset: usize,
    },
    /// `LOOP`: the three byte fields of the second operand word are the count (bits 2 to 9), the initial counter value
    /// (10 to 17) and the increment (19 to 26), as RPCS3 and Mesa name them. No program on Tony Hawk's SHRED disc uses it.
    Loop {
        /// The iteration count.
        count: u8,
        /// The initial counter value.
        initial: u8,
        /// The counter increment.
        increment: u8,
        /// The byte offset where the loop ends (the third operand word without its top bit).
        end_offset: usize,
    },
    /// `REP`: the same three byte fields, which Mesa found always filled with one value (a repeat count) and names
    /// `count1`, `count2` and `count3`; RPCS3 reads the first as the repeat count. Kept as stored, in that order.
    Repeat {
        /// The three counts as stored (bits 2 to 9, 10 to 17 and 19 to 26 of the second operand word).
        counts: [u8; 3],
        /// The byte offset where the repeated block ends.
        end_offset: usize,
    },
    /// `CAL`: a subroutine call. The target is the second operand word without its top bit, a count of 32-bit words as
    /// every other branch offset is (Mesa's `NV40_FP_OP_SUB_OFFSET`); it must be an instruction boundary.
    Call {
        /// The byte offset of the first instruction of the subroutine.
        target: usize,
        /// The instruction's three operand words, as stored.
        encoded: [u32; 3],
    },
    /// `BRK`.
    Break,
    /// `RET`.
    Return,
}

/// A decoded instruction.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Instruction {
    /// The byte offset of the instruction's first slot.
    pub offset: usize,
    /// Its size in bytes: 16, or 32 with an inline constant.
    pub size: usize,
    /// The opcode.
    pub opcode: Opcode,
    /// Rotated words, including fields not interpreted here.
    pub words: [u32; 4],
    /// The instruction is the last of the program.
    pub end: bool,
    /// The destination register.
    pub destination: Register,
    /// The components written, bit 0 x to bit 3 w.
    pub write_mask: u8,
    /// The result goes to the condition code only.
    pub no_destination: bool,
    /// The instruction updates a condition-code register.
    pub update_condition: bool,
    /// Which condition-code register it updates.
    pub condition_destination: u8,
    /// The condition under which it executes.
    pub predicate: Predicate,
    /// The result is clamped to 0 to 1.
    pub saturate: bool,
    /// The result precision code, as stored.
    pub precision: u8,
    /// The texture lookup expands its result (the signed-range flag), as stored.
    pub expand_texture: bool,
    /// The texture unit a sampling instruction reads.
    pub texture_unit: Option<u8>,
    /// The sources, as many as the opcode reads.
    pub sources: Vec<Source>,
    /// The inline constant of the slot after the instruction, as IEEE bits.
    pub constant: Option<[u32; 4]>,
    /// Encoded modifiers for each source, and the result scale, retained without floating-point evaluation.
    pub source_precision: [u8; 3],
    /// The result scale code, as stored.
    pub scale: u8,
    /// The inputs are addressed indirectly (bit 30 of the last operand word). Clear in every instruction of the
    /// fragment programs on the disc.
    pub indexed_input: bool,
    /// Bits 19 to 29 of the last operand word, as stored. Bits 21 to 29 are all ones on every instruction of the
    /// disc's programs that reads an interpolant and zero on every other; bits 19 and 20 are always zero. It is not an
    /// address in any of them.
    pub input_address: u16,
    /// Bit 31 of the last operand word, as stored: a flag of the interpolant the instruction reads (always clear where
    /// it reads none). Within one program every read of one interpolant has the same value in 17,689 of the disc's
    /// 17,691 (program, interpolant) pairs; it is clear on all 10,409 texture lookups' coordinates (texture
    /// coordinates 0 and 1) and set on most of the reads of texture coordinates 4 to 7. What it selects is not
    /// established: a program's parameter table names no varying, so the sense (perspective-corrected or not) is not
    /// tied to any data, and it is read as the bit it is.
    pub interpolant_flag: bool,
    /// What a flow-control instruction does.
    pub control: Option<Control>,
}

/// A decoded fragment program.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Program {
    /// The instructions, in order.
    pub instructions: Vec<Instruction>,
    /// The program's size in bytes.
    pub byte_len: usize,
}

/// What is wrong with a fragment program, and where.
#[derive(Clone, Debug, PartialEq, Eq, thiserror::Error)]
#[error("RSX fragment program at byte {offset}: {detail}")]
pub struct Error {
    /// The byte offset in the microcode where the problem is.
    pub offset: usize,
    /// What was expected there, or what was found instead.
    pub detail: String,
}

fn error(offset: usize, detail: impl Into<String>) -> Error {
    Error {
        offset,
        detail: detail.into(),
    }
}
/// The `width` bits of `n` from bit `shift` up.
fn bits(n: u32, shift: u32, width: u32) -> u32 {
    let mask = 1u32.checked_shl(width).map_or(u32::MAX, |m| m.wrapping_sub(1));
    n.checked_shr(shift).unwrap_or(0) & mask
}
/// [`bits`] of at most 8 bits.
fn bits8(n: u32, shift: u32, width: u32) -> u8 {
    let [byte, ..] = bits(n, shift, width.min(8)).to_le_bytes();
    byte
}
/// [`bits`] of at most 16 bits.
fn bits16(n: u32, shift: u32, width: u32) -> u16 {
    let [a, b, ..] = bits(n, shift, width.min(16)).to_le_bytes();
    u16::from_le_bytes([a, b])
}
fn swizzle(n: u32, shift: u32) -> [u8; 4] {
    [0, 2, 4, 6].map(|k| bits8(n, shift.saturating_add(k), 2))
}

/// Decode exactly one big-endian fragment program. Requires END at the exact
/// end, validates branch boundaries and refuses reserved/unimplemented opcodes.
/// Inline constants are retained as IEEE bits, never decoded as instructions.
pub fn decode(bytes: &[u8]) -> Result<Program, Error> {
    if bytes.is_empty() || !bytes.len().is_multiple_of(16) {
        return Err(error(0, "fragment microcode must contain complete 16-byte slots"));
    }
    let view = View::new(bytes);
    let slot = |at| -> Result<[u32; 4], Error> {
        let data = view.slice(at, 16).map_err(|e| error(at, e.to_string()))?;
        let (words, _) = data.as_chunks::<4>();
        let [d, a, b, c] = words else {
            return Err(error(at, "a 16-byte slot"));
        };
        Ok([d, a, b, c].map(|w| u32::from_be_bytes(*w).rotate_left(16)))
    };
    let mut at = 0;
    let mut instructions = Vec::new();
    loop {
        let words = slot(at)?;
        let [d, a, b, c] = words;
        let code = bits8(d, 24, 6) | (bits8(b, 31, 1) << 6);
        let opcode =
            Opcode::read(code).ok_or_else(|| error(at, format!("unsupported fragment opcode {code:#x}")))?;
        let mut sources = Vec::new();
        for (i, raw) in [a, b, c].into_iter().take(opcode.source_count()).enumerate() {
            let kind = match bits(raw, 0, 2) {
                0 => SourceKind::Register(Register {
                    index: bits8(raw, 2, 6),
                    half: bits(raw, 8, 1) != 0,
                }),
                1 => SourceKind::Input(bits8(d, 13, 4)),
                2 => SourceKind::Constant,
                _ => {
                    return Err(error(
                        at.saturating_add(4).saturating_add(i.saturating_mul(4)),
                        "reserved source register type",
                    ));
                }
            };
            sources.push(Source {
                kind,
                swizzle: swizzle(raw, 9),
                negate: bits(raw, 17, 1) != 0,
                absolute: bits(raw, if i == 0 { 29 } else { 18 }, 1) != 0,
            });
        }
        let constant = if sources.iter().any(|s| s.kind == SourceKind::Constant) {
            Some(slot(at.saturating_add(16))?)
        } else {
            None
        };
        let size = if constant.is_some() { 32 } else { 16 };
        let control = match opcode {
            Opcode::IFE => Some(Control::If {
                else_offset: usize::try_from(b & 0x7fffffff)
                    .map_err(|_| error(at, "branch address overflow"))?
                    .checked_mul(4)
                    .ok_or_else(|| error(at, "branch address overflow"))?,
                end_offset: usize::try_from(c & 0x7fff_ffff)
                    .map_err(|_| error(at, "branch address overflow"))?
                    .checked_mul(4)
                    .ok_or_else(|| error(at, "branch address overflow"))?,
            }),
            Opcode::LOOP => Some(Control::Loop {
                count: bits8(b, 2, 8),
                initial: bits8(b, 10, 8),
                increment: bits8(b, 19, 8),
                end_offset: usize::try_from(c & 0x7fff_ffff)
                    .map_err(|_| error(at, "loop address overflow"))?
                    .checked_mul(4)
                    .ok_or_else(|| error(at, "loop address overflow"))?,
            }),
            Opcode::REP => Some(Control::Repeat {
                counts: [bits8(b, 2, 8), bits8(b, 10, 8), bits8(b, 19, 8)],
                end_offset: usize::try_from(c & 0x7fff_ffff)
                    .map_err(|_| error(at, "loop address overflow"))?
                    .checked_mul(4)
                    .ok_or_else(|| error(at, "loop address overflow"))?,
            }),
            Opcode::CAL => Some(Control::Call {
                target: usize::try_from(b & 0x7fff_ffff)
                    .map_err(|_| error(at, "call address overflow"))?
                    .checked_mul(4)
                    .ok_or_else(|| error(at, "call address overflow"))?,
                encoded: [a, b, c],
            }),
            Opcode::BRK => Some(Control::Break),
            Opcode::RET => Some(Control::Return),
            _ => None,
        };
        let end = d & 1 != 0;
        instructions.push(Instruction {
            offset: at,
            size,
            opcode,
            words,
            end,
            destination: Register {
                index: bits8(d, 1, 6),
                half: bits(d, 7, 1) != 0,
            },
            write_mask: bits8(d, 9, 4),
            no_destination: bits(d, 30, 1) != 0,
            update_condition: bits(d, 8, 1) != 0,
            condition_destination: bits8(a, 30, 1),
            predicate: Predicate {
                test: bits8(a, 18, 3),
                swizzle: swizzle(a, 21),
                register: bits8(a, 31, 1),
            },
            saturate: bits(d, 31, 1) != 0,
            precision: bits8(d, 22, 2),
            expand_texture: bits(d, 21, 1) != 0,
            texture_unit: opcode.samples_texture().then_some(bits8(d, 17, 4)),
            sources,
            constant,
            source_precision: [bits8(b, 19, 3), bits8(b, 22, 3), bits8(b, 25, 3)],
            scale: bits8(b, 28, 3),
            indexed_input: bits(c, 30, 1) != 0,
            input_address: bits16(c, 19, 11),
            interpolant_flag: bits(c, 31, 1) != 0,
            control,
        });
        at = at.saturating_add(size);
        if end {
            if at != bytes.len() {
                return Err(error(at, "bytes after END instruction"));
            }
            break;
        }
        if at == bytes.len() {
            return Err(error(at, "fragment program has no END instruction"));
        }
    }
    let boundary = |offset| offset == bytes.len() || instructions.iter().any(|i| i.offset == offset);
    for i in &instructions {
        match i.control {
            Some(Control::If {
                else_offset,
                end_offset,
            }) if !boundary(else_offset)
                || !boundary(end_offset)
                || else_offset < i.offset.saturating_add(i.size)
                || end_offset < else_offset =>
            {
                return Err(error(i.offset, "invalid IF boundaries"));
            }
            Some(Control::Loop { end_offset, .. } | Control::Repeat { end_offset, .. })
                if !boundary(end_offset) || end_offset < i.offset.saturating_add(i.size) =>
            {
                return Err(error(i.offset, "invalid loop boundary"));
            }
            Some(Control::Call { target, .. }) if !boundary(target) => {
                return Err(error(i.offset, "invalid call target"));
            }
            _ => {}
        }
    }
    Ok(Program {
        instructions,
        byte_len: bytes.len(),
    })
}

fn register(r: Register) -> String {
    format!("{}{}", if r.half { "h" } else { "r" }, r.index)
}
fn channels(s: [u8; 4]) -> String {
    s.into_iter()
        .map(|n| "xyzw".chars().nth(usize::from(n)).unwrap_or('?'))
        .collect()
}

impl Program {
    /// Stable inspection text. Full predicates and modifiers remain in the typed
    /// instruction even where an external assembler dialect omits them.
    pub fn disassemble(&self) -> String {
        let mut out = String::new();
        for i in &self.instructions {
            let _ = write!(out, "{:04x}: {}", i.offset, i.opcode.mnemonic());
            if i.opcode.writes_destination() {
                let mask: String = (0..4)
                    .zip("xyzw".chars())
                    .filter(|&(n, _)| bits(u32::from(i.write_mask), n, 1) != 0)
                    .map(|(_, channel)| channel)
                    .collect();
                let _ = write!(
                    out,
                    " {}.{mask}",
                    if i.no_destination || i.destination.index == 63 {
                        format!("cc{}", i.condition_destination)
                    } else {
                        register(i.destination)
                    }
                );
            }
            for s in &i.sources {
                let source = match s.kind {
                    SourceKind::Register(r) => register(r),
                    SourceKind::Input(n) => format!("input[{n}]"),
                    SourceKind::Constant => format!("{:08x?}", i.constant),
                };
                let _ = write!(
                    out,
                    ", {}{}{}.{}",
                    if s.negate { "-" } else { "" },
                    if s.absolute { "abs " } else { "" },
                    source,
                    channels(s.swizzle)
                );
            }
            if let Some(unit) = i.texture_unit {
                let _ = write!(out, ", tex{unit}");
            }
            if let Some(control) = &i.control {
                let _ = write!(out, " {control:?}");
            }
            let _ = writeln!(
                out,
                " ; pred={} cc{}.{}, sat={}, precision={}, scale={}, src_precision={:?}, end={}",
                i.predicate.test,
                i.predicate.register,
                channels(i.predicate.swizzle),
                i.saturate,
                i.precision,
                i.scale,
                i.source_precision,
                i.end
            );
        }
        out
    }
}

pub mod flow;
