//! RSX vertex instructions: 128-bit slots of four big-endian 32-bit words, each holding up to two operations (a vector
//! operation and a scalar one) with three shared source operands, an output or temporary destination for each, a
//! condition code test and an address register. This reads instructions; it neither executes nor lowers them.
//!
//! The layout is the NV40 vertex program format the RSX shares. Opcodes this reader has no entry for are refused with
//! their number.
use std::fmt::Write;

/// What is wrong with a vertex program, and where.
#[derive(Clone, Debug, PartialEq, Eq, thiserror::Error)]
#[error("vertex program at byte {offset}: {detail}")]
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
fn flag(n: u32, bit: u32) -> bool {
    bits(n, bit, 1) != 0
}

macro_rules! opcodes {
    ($kind:ident, $doc:literal; $($name:ident = $code:literal;)+) => {
        #[doc = $doc]
        #[derive(Clone, Copy, Debug, PartialEq, Eq)]
        #[repr(u8)]
        pub enum $kind {
            $(
                #[doc = concat!("`", stringify!($name), "`, opcode ", stringify!($code), ".")]
                $name = $code,
            )+
        }
        impl $kind {
            fn read(code: u8) -> Option<Self> { match code { $($code => Some(Self::$name),)+ _ => None } }
            /// The opcode's name in upper case (`MOV`, `MAD`, ...).
            pub fn mnemonic(self) -> &'static str { match self { $(Self::$name => stringify!($name),)+ } }
        }
    }
}

opcodes! { VectorOpcode, "A vector operation: four lanes at once, up to three sources.";
    NOP=0x00; MOV=0x01; MUL=0x02; ADD=0x03; MAD=0x04; DP3=0x05; DPH=0x06; DP4=0x07;
    DST=0x08; MIN=0x09; MAX=0x0a; SLT=0x0b; SGE=0x0c; ARL=0x0d; FRC=0x0e; FLR=0x0f;
    SEQ=0x10; SFL=0x11; SGT=0x12; SLE=0x13; SNE=0x14; STR=0x15; SSG=0x16; ARR=0x17;
    ARA=0x18; TXL=0x19;
}

opcodes! { ScalarOpcode, "A scalar operation: one source, its result replicated to the lanes the write mask names.";
    NOP=0x00; MOV=0x01; RCP=0x02; RCC=0x03; RSQ=0x04; EXP=0x05; LOG=0x06; LIT=0x07;
    LG2=0x0d; EX2=0x0e; SIN=0x0f; COS=0x10; PUSHA=0x13; POPA=0x14;
}

/// What a source operand reads.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum SourceKind {
    /// No register: the operand is unused (register type 0).
    None,
    /// A temporary register `R<n>`, 0 to 31.
    Temporary(u8),
    /// A vertex attribute: the instruction's one input index (`v[n]`), or that index plus the address register where
    /// [`Instruction::input_relative`] is set.
    Input,
    /// A float constant: the instruction's one constant index (`c[n]`), or that index plus the address register where
    /// [`Instruction::constant_relative`] is set.
    Constant,
}

/// One of an instruction's three source operands.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Source {
    /// What it reads.
    pub kind: SourceKind,
    /// The source lane (0 x to 3 w) each result lane takes.
    pub swizzle: [u8; 4],
    /// Whether the value is negated (after the absolute value, if both).
    pub negate: bool,
    /// Whether the absolute value is taken.
    pub absolute: bool,
}

/// An output the program writes.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Output {
    /// The clip-space position (destination 0).
    Position,
    /// The first colour (1).
    Color0,
    /// The second colour (2).
    Color1,
    /// The first back-face colour (3).
    BackColor0,
    /// The second back-face colour (4).
    BackColor1,
    /// The fog coordinate (5).
    FogCoord,
    /// Destination 6, the point size in the nouveau driver's naming. On the programs of Tony Hawk's SHRED it is written
    /// with all four lanes by 48 programs (their output mask has bit 13 set) and with the x lane alone by one (bit 5).
    PointSize,
    /// Texture coordinate set `n` (destination `7 + n`, 0 to 9).
    TexCoord(u8),
    /// A destination field value nothing here names (17 to 30).
    Other(u8),
}

impl Output {
    fn from_field(n: u8) -> Self {
        match n {
            0 => Self::Position,
            1 => Self::Color0,
            2 => Self::Color1,
            3 => Self::BackColor0,
            4 => Self::BackColor1,
            5 => Self::FogCoord,
            6 => Self::PointSize,
            7..=16 => Self::TexCoord(n.saturating_sub(7)),
            n => Self::Other(n),
        }
    }
    /// The destination field value.
    pub fn field(self) -> u8 {
        match self {
            Self::Position => 0,
            Self::Color0 => 1,
            Self::Color1 => 2,
            Self::BackColor0 => 3,
            Self::BackColor1 => 4,
            Self::FogCoord => 5,
            Self::PointSize => 6,
            Self::TexCoord(n) => n.saturating_add(7),
            Self::Other(n) => n,
        }
    }
}

/// Where an operation's result goes.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Destination {
    /// Nowhere: the operation is absent or its result is discarded (the destination field is all ones).
    None,
    /// A temporary register `R<n>` (a 6-bit field for the vector operation, 5 for the scalar one).
    Temporary(u8),
    /// An output register.
    Output(Output),
}

/// The condition code test and register of an instruction.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Condition {
    /// Whether the test is enabled (the operation runs per lane where it holds).
    pub test: bool,
    /// The test, 3 bits as stored (NV_vertex_program2: 0 FL, 1 LT, 2 EQ, 3 LE, 4 GT, 5 NE, 6 GE, 7 TR).
    pub code: u8,
    /// The condition register lane each test lane reads.
    pub swizzle: [u8; 4],
    /// Which of the two condition registers is tested.
    pub register: u8,
    /// Whether the operation updates the condition register.
    pub update: bool,
}

/// One 128-bit slot.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Instruction {
    /// The slot's byte offset in the microcode.
    pub offset: usize,
    /// The four words as stored (big-endian read), most significant first.
    pub words: [u32; 4],
    /// The vector operation.
    pub vector: VectorOpcode,
    /// The scalar operation.
    pub scalar: ScalarOpcode,
    /// The three source operands, shared by both operations.
    pub sources: [Source; 3],
    /// The attribute index of every source of kind [`SourceKind::Input`].
    pub input: u8,
    /// The constant index (ten bits) of every source of kind [`SourceKind::Constant`].
    pub constant: u16,
    /// Whether attribute sources add the address register to [`Self::input`].
    pub input_relative: bool,
    /// Whether constant sources add the address register to [`Self::constant`].
    pub constant_relative: bool,
    /// Which address register and which of its lanes a relative operand adds.
    pub address: (u8, u8),
    /// Where the vector operation's result goes.
    pub vector_destination: Destination,
    /// Where the scalar operation's result goes.
    pub scalar_destination: Destination,
    /// The vector operation's write mask, bit 0 x to bit 3 w.
    pub vector_mask: u8,
    /// The scalar operation's write mask, bit 0 x to bit 3 w.
    pub scalar_mask: u8,
    /// Whether results are clamped to 0..1.
    pub saturate: bool,
    /// The condition test.
    pub condition: Condition,
    /// Whether this is the program's last instruction.
    pub last: bool,
    /// The bits of the four words that no field here covers.
    pub unassigned: [u32; 4],
}

impl Instruction {
    /// The outputs this instruction writes: the destination of each operation that has an output destination and a
    /// non-empty write mask.
    pub fn outputs(&self) -> Vec<Output> {
        let mut out = Vec::new();
        for (destination, mask, present) in [
            (
                self.vector_destination,
                self.vector_mask,
                self.vector != VectorOpcode::NOP,
            ),
            (
                self.scalar_destination,
                self.scalar_mask,
                self.scalar != ScalarOpcode::NOP,
            ),
        ] {
            if let Destination::Output(o) = destination
                && mask != 0
                && present
                && !out.contains(&o)
            {
                out.push(o);
            }
        }
        out
    }
}

/// A decoded vertex program.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Program {
    /// The instructions in order.
    pub instructions: Vec<Instruction>,
}

impl Program {
    /// The vertex attributes the program reads, bit `n` for attribute `n`, as a program header's `attribute_input_mask`
    /// states them. An attribute read relative to the address register can be any, so `None` where one is.
    pub fn input_mask(&self) -> Option<u32> {
        let mut mask = 0u32;
        for i in &self.instructions {
            if i.sources.iter().any(|s| s.kind == SourceKind::Input) {
                if i.input_relative {
                    return None;
                }
                mask |= 1u32.checked_shl(u32::from(i.input)).unwrap_or(0);
            }
        }
        Some(mask)
    }

    /// The outputs the program writes (the position excepted, which every program writes), as a program header's
    /// `attribute_output_mask` states them: destinations 1 to 5 are bits 0 to 4; destination 6 is bit 13, or bit 5 where
    /// only its x lane is written; destination `n` from 7 is bit `n + 7`. Measured on the 170 distinct vertex programs
    /// of Tony Hawk's SHRED, where destinations 1 and 6 to 14 occur; the others follow the nouveau driver's output
    /// numbering and no program of that game writes them.
    pub fn output_mask(&self) -> u32 {
        let mut mask = 0u32;
        let mut slot6 = 0u8;
        for i in &self.instructions {
            for (destination, lanes, present) in [
                (i.vector_destination, i.vector_mask, i.vector != VectorOpcode::NOP),
                (i.scalar_destination, i.scalar_mask, i.scalar != ScalarOpcode::NOP),
            ] {
                let Destination::Output(output) = destination else {
                    continue;
                };
                if lanes == 0 || !present {
                    continue;
                }
                match output.field() {
                    0 => {}
                    6 => slot6 |= lanes,
                    n @ 1..=5 => mask |= 1u32.checked_shl(u32::from(n).saturating_sub(1)).unwrap_or(0),
                    n => mask |= 1u32.checked_shl(u32::from(n).saturating_add(7)).unwrap_or(0),
                }
            }
        }
        if slot6 != 0 {
            mask |= if slot6 == 1 { 1 << 5 } else { 1 << 13 };
        }
        mask
    }

    /// The number of temporary registers the program uses: one more than the highest it reads or writes, and at least one.
    pub fn register_count(&self) -> u32 {
        let mut highest = 0u32;
        for i in &self.instructions {
            let written = [i.vector_destination, i.scalar_destination]
                .into_iter()
                .filter_map(|d| match d {
                    Destination::Temporary(n) => Some(u32::from(n)),
                    _ => None,
                });
            let read = i.sources.iter().filter_map(|s| match s.kind {
                SourceKind::Temporary(n) => Some(u32::from(n)),
                _ => None,
            });
            for n in written.chain(read) {
                highest = highest.max(n.saturating_add(1));
            }
        }
        highest.max(1)
    }
}

/// The bits no field covers: bits 31 and 28 of word 0. (Word 1's bits 12 to 21 are the constant index, ten bits wide; the
/// values seen reach 467, the last of the RSX's 468 vertex constants.)
const UNASSIGNED: [u32; 4] = [(1 << 31) | (1 << 28), 0, 0, 0];

fn source(raw: u32) -> Source {
    let kind = match bits(raw, 0, 2) {
        0 => SourceKind::None,
        1 => SourceKind::Temporary(bits8(raw, 2, 5)),
        2 => SourceKind::Input,
        _ => SourceKind::Constant,
    };
    Source {
        kind,
        // the swizzle fields run x at bit 14 down to w at bit 8
        swizzle: [14, 12, 10, 8].map(|shift| bits8(raw, shift, 2)),
        negate: flag(raw, 16),
        absolute: false,
    }
}

fn destination(result: bool, temporary: u8, none: u8, field: u8) -> Destination {
    if result {
        Destination::Output(Output::from_field(field))
    } else if temporary == none {
        Destination::None
    } else {
        Destination::Temporary(temporary)
    }
}

/// Decode a whole vertex program: complete 16-byte slots, the last instruction flagged as last and no other.
pub fn decode(bytes: &[u8]) -> Result<Program, Error> {
    if bytes.is_empty() || !bytes.len().is_multiple_of(16) {
        return Err(error(0, "vertex microcode must contain complete 16-byte slots"));
    }
    let (slots, _) = bytes.as_chunks::<16>();
    let mut instructions = Vec::with_capacity(slots.len());
    for (n, slot) in slots.iter().enumerate() {
        let offset = n.saturating_mul(16);
        let (words, _) = slot.as_chunks::<4>();
        let [w0, w1, w2, w3] = words else {
            return Err(error(offset, "a slot is four words"));
        };
        let [w0, w1, w2, w3] = [w0, w1, w2, w3].map(|w| u32::from_be_bytes(*w));
        let vec_code = bits8(w1, 22, 5);
        let sca_code = bits8(w1, 27, 5);
        let vector = VectorOpcode::read(vec_code)
            .ok_or_else(|| error(offset, format!("vector opcode {vec_code:#04x} has no entry")))?;
        let scalar = ScalarOpcode::read(sca_code)
            .ok_or_else(|| error(offset, format!("scalar opcode {sca_code:#04x} has no entry")))?;
        let raw0 = bits(w1, 0, 8).wrapping_shl(9) | bits(w2, 23, 9);
        let raw1 = bits(w2, 6, 17);
        let raw2 = bits(w2, 0, 6).wrapping_shl(11) | bits(w3, 21, 11);
        let mut sources = [raw0, raw1, raw2].map(source);
        for (s, bit) in sources.iter_mut().zip([21, 22, 23]) {
            s.absolute = flag(w0, bit);
        }
        let dest_field = bits8(w3, 2, 5);
        let mask = |w: u32, top: u32| -> u8 {
            // bit `top` is x, the three below are y, z and w
            (0..4).fold(0u8, |m, lane| {
                let set = flag(w, top.saturating_sub(lane));
                m | u8::from(set).wrapping_shl(lane)
            })
        };
        instructions.push(Instruction {
            offset,
            words: [w0, w1, w2, w3],
            vector,
            scalar,
            sources,
            input: bits8(w1, 8, 4),
            constant: bits16(w1, 12, 10),
            input_relative: flag(w0, 27),
            constant_relative: flag(w3, 1),
            address: (bits8(w0, 24, 1), bits8(w0, 0, 2)),
            vector_destination: destination(flag(w0, 30), bits8(w0, 15, 6), 0x3f, dest_field),
            scalar_destination: destination(flag(w3, 12), bits8(w3, 7, 5), 0x1f, dest_field),
            vector_mask: mask(w3, 16),
            scalar_mask: mask(w3, 20),
            saturate: flag(w0, 26),
            condition: Condition {
                test: flag(w0, 13),
                code: bits8(w0, 10, 3),
                swizzle: [8, 6, 4, 2].map(|shift| bits8(w0, shift, 2)),
                register: bits8(w0, 25, 1),
                update: flag(w0, 29),
            },
            last: flag(w3, 0),
            unassigned: [
                w0 & UNASSIGNED[0],
                w1 & UNASSIGNED[1],
                w2 & UNASSIGNED[2],
                w3 & UNASSIGNED[3],
            ],
        });
    }
    for (n, i) in instructions.iter().enumerate() {
        let is_final = n.saturating_add(1) == instructions.len();
        if i.last != is_final {
            return Err(error(
                i.offset,
                if is_final {
                    "the last slot is not flagged as the program's last"
                } else {
                    "a slot before the end is flagged as the program's last"
                },
            ));
        }
    }
    Ok(Program { instructions })
}

fn channels(mask: u8) -> String {
    "xyzw"
        .chars()
        .enumerate()
        .filter(|&(n, _)| bits(u32::from(mask), u32::try_from(n).unwrap_or(0), 1) != 0)
        .map(|(_, c)| c)
        .collect()
}

fn lanes(s: [u8; 4]) -> String {
    s.into_iter()
        .map(|n| "xyzw".chars().nth(usize::from(n)).unwrap_or('?'))
        .collect()
}

impl Program {
    /// Stable inspection text: one line per slot, its operations, destinations and operands.
    pub fn disassemble(&self) -> String {
        let mut out = String::new();
        for i in &self.instructions {
            let _ = write!(out, "{:04x}:", i.offset);
            let render = |d: Destination| match d {
                Destination::None => "-".to_owned(),
                Destination::Temporary(n) => format!("R{n}"),
                Destination::Output(o) => format!("o[{o:?}]"),
            };
            if i.vector != VectorOpcode::NOP {
                let _ = write!(
                    out,
                    " {} {}.{}",
                    i.vector.mnemonic(),
                    render(i.vector_destination),
                    channels(i.vector_mask)
                );
            }
            if i.scalar != ScalarOpcode::NOP {
                let _ = write!(
                    out,
                    " {} {}.{}",
                    i.scalar.mnemonic(),
                    render(i.scalar_destination),
                    channels(i.scalar_mask)
                );
            }
            for s in &i.sources {
                let text = match s.kind {
                    SourceKind::None => continue,
                    SourceKind::Temporary(n) => format!("R{n}"),
                    SourceKind::Input if i.input_relative => {
                        format!("v[A{}.{}+{}]", i.address.0, i.address.1, i.input)
                    }
                    SourceKind::Input => format!("v[{}]", i.input),
                    SourceKind::Constant if i.constant_relative => {
                        format!("c[A{}.{}+{}]", i.address.0, i.address.1, i.constant)
                    }
                    SourceKind::Constant => format!("c[{}]", i.constant),
                };
                let _ = write!(
                    out,
                    ", {}{}{}.{}",
                    if s.negate { "-" } else { "" },
                    if s.absolute { "|" } else { "" },
                    text,
                    lanes(s.swizzle)
                );
            }
            let _ = writeln!(
                out,
                " ; sat={} cond={}{} last={}",
                i.saturate,
                if i.condition.test { "on " } else { "off " },
                i.condition.code,
                i.last
            );
        }
        out
    }
}
