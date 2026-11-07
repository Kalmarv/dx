//! The token stream: records and the decoder.
//!
//! A program is a version token, then instruction tokens each followed by its operand tokens, then `END`
//! (`0x0000ffff`). An instruction token holds the opcode in bits 0 to 15, opcode-specific controls in bits 16 to 23,
//! from Shader Model 2 on the count of operand tokens that follow in bits 24 to 27, the predicate flag in bit 28 and
//! the pixel 1.x co-issue flag in bit 30. A comment token (`0xfffe`) holds its length in words in bits 16 to 30.
//!
//! An operand token has bit 31 set, the register number in bits 0 to 10 and the register type split over bits 28 to 30
//! (its low three bits) and 11 to 12 (its high two). A destination has its write mask in bits 16 to 19, its result
//! modifiers in 20 to 23 and the pixel 1.x result shift in 24 to 27; a source its swizzle in bits 16 to 23 and its
//! modifier in 24 to 27. Bit 13 marks a relatively addressed operand: from Shader Model 2 on a relative-address token
//! (the address register `a0` or the loop counter `aL`, with a swizzle) follows it; in a vertex 1.x program the index
//! is always `a0.x` and no token follows.

use crate::opcodes::Shape;
use crate::{ConstantTable, DebugInfo, Opcode, Result, Stage, Version, error};

/// The most words a program may have, END included.
const MAX_WORDS: usize = 1_048_576;

/// A register type (`D3DSHADER_PARAM_REGISTER_TYPE`, `D3DSPR_*`). Type 3 is the address register in a vertex program
/// and a texture register in a pixel program; type 6 is a vertex program's texture-coordinate output (`oTN`) before
/// 3.0 and its output `oN` in 3.0.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum RegisterType {
    /// `rN` (`D3DSPR_TEMP`, 0).
    Temp,
    /// `vN` (`D3DSPR_INPUT`, 1).
    Input,
    /// `cN` (`D3DSPR_CONST`, 2).
    Const,
    /// `a0` of a vertex program (`D3DSPR_ADDR`, 3).
    Address,
    /// `tN` of a pixel program (`D3DSPR_TEXTURE`, 3).
    Texture,
    /// `oPos` (0), `oFog` (1) or `oPts` (2) of a vertex program before 3.0 (`D3DSPR_RASTOUT`, 4).
    RasterizerOut,
    /// `oDN`, a vertex program's colour output before 3.0 (`D3DSPR_ATTROUT`, 5).
    AttributeOut,
    /// `oTN` before vertex 3.0, `oN` in 3.0 (`D3DSPR_TEXCRDOUT` and `D3DSPR_OUTPUT`, 6).
    Output,
    /// `iN`, an integer constant (`D3DSPR_CONSTINT`, 7).
    ConstInt,
    /// `oCN`, a pixel program's colour output (`D3DSPR_COLOROUT`, 8).
    ColorOut,
    /// `oDepth` (`D3DSPR_DEPTHOUT`, 9).
    DepthOut,
    /// `sN` (`D3DSPR_SAMPLER`, 10).
    Sampler,
    /// `cN` from 2048 on, the number being `N - 2048` (`D3DSPR_CONST2`, 11).
    Const2,
    /// `cN` from 4096 on (`D3DSPR_CONST3`, 12).
    Const3,
    /// `cN` from 6144 on (`D3DSPR_CONST4`, 13).
    Const4,
    /// `bN`, a boolean constant (`D3DSPR_CONSTBOOL`, 14).
    ConstBool,
    /// `aL`, the loop counter (`D3DSPR_LOOP`, 15).
    Loop,
    /// `vPos` (0) or `vFace` (1) of a pixel 3.0 program (`D3DSPR_MISCTYPE`, 17).
    Misc,
    /// `lN`, a label (`D3DSPR_LABEL`, 18).
    Label,
    /// `p0`, the predicate (`D3DSPR_PREDICATE`, 19).
    Predicate,
}

impl RegisterType {
    /// The type's value in the token (`D3DSPR_*`).
    pub fn code(self) -> u8 {
        use RegisterType::*;
        match self {
            Temp => 0,
            Input => 1,
            Const => 2,
            Address | Texture => 3,
            RasterizerOut => 4,
            AttributeOut => 5,
            Output => 6,
            ConstInt => 7,
            ColorOut => 8,
            DepthOut => 9,
            Sampler => 10,
            Const2 => 11,
            Const3 => 12,
            Const4 => 13,
            ConstBool => 14,
            Loop => 15,
            Misc => 17,
            Label => 18,
            Predicate => 19,
        }
    }

    /// The register type of a token value in `version` (whose stage tells `a0` from `tN`), and the largest register
    /// number it has (`None` for a bank whose size is the device's), or why the value names no register. A type is
    /// read in any version, as Microsoft's disassembler lists it.
    fn of(code: u32, version: Version) -> std::result::Result<(Self, Option<u32>), String> {
        use RegisterType::*;
        Ok(match code {
            0 => (Temp, None),
            1 => (Input, None),
            2 => (Const, None),
            3 if version.stage == Stage::Vertex => (Address, Some(0)),
            3 => (Texture, None),
            4 => (RasterizerOut, Some(2)),
            5 => (AttributeOut, None),
            6 => (Output, None),
            7 => (ConstInt, None),
            8 => (ColorOut, None),
            9 => (DepthOut, Some(0)),
            10 => (Sampler, None),
            11 => (Const2, None),
            12 => (Const3, None),
            13 => (Const4, None),
            14 => (ConstBool, None),
            15 => (Loop, Some(0)),
            17 => (Misc, Some(1)),
            18 => (Label, None),
            19 => (Predicate, Some(0)),
            _ => return Err("is not a Direct3D 9 register type".into()),
        })
    }
}

/// A register: its type and number.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct Register {
    /// The register type.
    pub kind: RegisterType,
    /// The register number, bits 0 to 10 of the operand token.
    pub number: u32,
}

/// A source modifier (`D3DSHADER_PARAM_SRCMOD_TYPE`, `D3DSPSM_*`), bits 24 to 27 of a source token.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Modifier {
    /// No modifier (0).
    None,
    /// `-r` (1).
    Negate,
    /// `r_bias`, `r - 0.5` (2).
    Bias,
    /// `-r_bias` (3).
    BiasNegate,
    /// `r_bx2`, `2 * (r - 0.5)` (4).
    Sign,
    /// `-r_bx2` (5).
    SignNegate,
    /// `1 - r` (6).
    Complement,
    /// `r_x2` (7).
    X2,
    /// `-r_x2` (8).
    X2Negate,
    /// `r_dz`, divided by its z lane (9).
    DivideZ,
    /// `r_dw`, divided by its w lane (10).
    DivideW,
    /// `r_abs` (11).
    Abs,
    /// `-r_abs` (12).
    AbsNegate,
    /// `!r`, of a boolean or predicate (13).
    Not,
}

impl Modifier {
    /// The modifier's value in the token.
    pub fn code(self) -> u8 {
        use Modifier::*;
        match self {
            None => 0,
            Negate => 1,
            Bias => 2,
            BiasNegate => 3,
            Sign => 4,
            SignNegate => 5,
            Complement => 6,
            X2 => 7,
            X2Negate => 8,
            DivideZ => 9,
            DivideW => 10,
            Abs => 11,
            AbsNegate => 12,
            Not => 13,
        }
    }

    fn of(code: u32) -> Option<Self> {
        use Modifier::*;
        Some(match code {
            0 => None,
            1 => Negate,
            2 => Bias,
            3 => BiasNegate,
            4 => Sign,
            5 => SignNegate,
            6 => Complement,
            7 => X2,
            8 => X2Negate,
            9 => DivideZ,
            10 => DivideW,
            11 => Abs,
            12 => AbsNegate,
            13 => Not,
            _ => return Option::None,
        })
    }
}

/// The index register of a relatively addressed operand (`c[a0.x + 4]`, `v[aL]`).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Relative {
    /// The word of the relative-address token; `None` in a vertex 1.x program, whose index is `a0.x` with no token of
    /// its own.
    pub word: Option<usize>,
    /// The index register: the address register `a0` or the loop counter `aL`.
    pub register: Register,
    /// The relative-address token's swizzle, as stored (bits 16 to 23). Compilers write the lane they index with
    /// replicated (`a0.x` as `.xxxx`); Microsoft's assembler writes `c0[a0]` and `[aL]` with `.xyzw`. `[0, 0, 0, 0]`
    /// in a vertex 1.x program.
    pub swizzle: [u8; 4],
}

/// The minimum precision of an operand (`D3DSP_MIN_PRECISION`, bits 14 to 15 of a destination or source token), which
/// fxc writes in a feature level 9 program's Direct3D 9 part for a `min16float` value. Microsoft's listing writes it
/// after the operand: `{min16f}`, `{min2_8f}`, nothing for 3. A relative-address or predicate token's bits 14 to 15
/// mean nothing; it ignores them.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Hash)]
pub enum Precision {
    /// 0, the precision of the register (`D3DMP_DEFAULT`).
    #[default]
    Default,
    /// 1, at least 16 bits (`D3DMP_16`, `{min16f}`).
    Min16,
    /// 2, at least 2.8 fixed point (`D3DMP_2_8`, `{min2_8f}`).
    Min2_8,
    /// 3, which `d3d9types.h` does not name and the listing writes nothing for.
    Unnamed,
}

impl Precision {
    /// The precision of an operand token's bits 14 to 15.
    pub fn of(token: u32) -> Self {
        match (token >> 14) & 3 {
            0 => Precision::Default,
            1 => Precision::Min16,
            2 => Precision::Min2_8,
            _ => Precision::Unnamed,
        }
    }
}

/// A destination operand.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Destination {
    /// The word of the operand token.
    pub word: usize,
    /// The register written.
    pub register: Register,
    /// The lanes written, bit 0 x to bit 3 w (bits 16 to 19); a declaration's lanes declared.
    pub mask: u8,
    /// `_sat` (`D3DSPDM_SATURATE`, bit 20).
    pub saturate: bool,
    /// `_pp` (`D3DSPDM_PARTIALPRECISION`, bit 21).
    pub partial_precision: bool,
    /// `_centroid` (`D3DSPDM_MSAMPCENTROID`, bit 22).
    pub centroid: bool,
    /// The pixel 1.x result shift (bits 24 to 27 as a signed number): 1 `_x2`, 2 `_x4`, 3 `_x8`, -1 `_d2`, -2 `_d4`,
    /// -3 `_d8`; 0 otherwise and in every other version.
    pub shift: i8,
    /// The index register, for a relatively addressed destination (`o[aL]` of a vertex 3.0 program).
    pub relative: Option<Relative>,
    /// The minimum precision, bits 14 to 15.
    pub precision: Precision,
}

/// A source operand.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Source {
    /// The word of the operand token.
    pub word: usize,
    /// The register read.
    pub register: Register,
    /// The lane of the register (0 x to 3 w) each of the operand's x, y, z and w reads: bits 16 to 23, two per lane.
    pub swizzle: [u8; 4],
    /// The source modifier.
    pub modifier: Modifier,
    /// The index register, for a relatively addressed source.
    pub relative: Option<Relative>,
    /// The minimum precision, bits 14 to 15 (of a predicate, nothing the listing writes).
    pub precision: Precision,
}

/// The comparison of `if_comp`, `break_comp` and `setp_comp` (`D3DSHADER_COMPARISON`), bits 16 to 18 of the instruction
/// token.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Comparison {
    /// `_gt` (1).
    Greater,
    /// `_eq` (2).
    Equal,
    /// `_ge` (3).
    GreaterEqual,
    /// `_lt` (4).
    Less,
    /// `_ne` (5).
    NotEqual,
    /// `_le` (6).
    LessEqual,
}

/// An instruction: everything but declarations, definitions, comments and `END`.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Instruction {
    /// The word of the instruction token, counted from the version token.
    pub word: usize,
    /// The opcode.
    pub opcode: Opcode,
    /// The opcode-specific controls, bits 16 to 23: for `tex` from pixel 1.4 on 0 `texld`, 1 `texldp` (projected) and 2
    /// `texldb` (biased); for `if_comp`, `break_comp` and `setp_comp` the [`Comparison`]; 0 for every other opcode.
    pub control: u8,
    /// The co-issue flag of a pixel 1.x instruction (bit 30), written `+` before it.
    pub coissue: bool,
    /// The predicate an instruction is predicated on (bit 28 set): the predicate register `p0`, its swizzle and
    /// [`Modifier::Not`] or none. Its token follows the destination's.
    pub predicate: Option<Source>,
    /// The destination; `None` for an opcode that has none. `texkill`'s is the register it tests.
    pub destination: Option<Destination>,
    /// The sources, in the order the stream writes them.
    pub sources: Vec<Source>,
}

impl Instruction {
    /// The comparison of `if_comp`, `break_comp` and `setp_comp`; `None` for other opcodes.
    pub fn comparison(&self) -> Option<Comparison> {
        if !matches!(self.opcode, Opcode::IfC | Opcode::BreakC | Opcode::SetP) {
            return None;
        }
        Some(match self.control {
            1 => Comparison::Greater,
            2 => Comparison::Equal,
            3 => Comparison::GreaterEqual,
            4 => Comparison::Less,
            5 => Comparison::NotEqual,
            _ => Comparison::LessEqual,
        })
    }
}

/// A sampler's texture type (`D3DSAMPLER_TEXTURE_TYPE`), bits 27 to 30 of its declaration token.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum TextureType {
    /// `dcl_2d` (2).
    D2,
    /// `dcl_cube` (3).
    Cube,
    /// `dcl_volume` (4).
    Volume,
}

/// What a declaration token declares.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Declared {
    /// A sampler's texture type.
    Sampler(TextureType),
    /// Any other register's usage (`D3DDECLUSAGE`: 0 position, 1 blend weight, 2 blend indices, 3 normal, 4 point size,
    /// 5 texture coordinate, 6 tangent, 7 binormal, 8 tessellation factor, 9 transformed position, 10 colour, 11 fog,
    /// 12 depth, 13 sample; bits 0 to 3) and usage index (bits 16 to 19). A pixel 2.x program's `dcl t0` and `dcl v0`
    /// store usage 0 and index 0, as does `dcl vPos`.
    Semantic {
        /// The usage.
        usage: u8,
        /// The usage index.
        index: u8,
    },
}

/// A `dcl`: the declaration token and the register declared.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Declaration {
    /// The word of the instruction token.
    pub word: usize,
    /// The declaration token, as stored.
    pub token: u32,
    /// What the declaration token says.
    pub declared: Declared,
    /// The register declared, its mask, and its modifiers (`_pp`, `_centroid`).
    pub destination: Destination,
}

/// The literal of a definition.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Literal {
    /// `def`: four floats, as their bit patterns.
    Float([u32; 4]),
    /// `defi`: four integers.
    Integer([i32; 4]),
    /// `defb`: a boolean, as its word (`TRUE` is 1).
    Bool(u32),
}

/// A `def`, `defi` or `defb`: a constant register and the literal it holds.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Definition {
    /// The word of the instruction token.
    pub word: usize,
    /// The register defined: a float, integer or boolean constant, as the opcode says.
    pub destination: Destination,
    /// The literal.
    pub literal: Literal,
}

/// A comment: its words, without its token. The constant table is one, its first word the FourCC `CTAB`.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Comment {
    /// The word of the comment token.
    pub word: usize,
    /// The comment's words.
    pub data: Vec<u32>,
}

/// One record of the stream.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Item {
    /// A comment.
    Comment(Comment),
    /// A `dcl`.
    Declaration(Declaration),
    /// A `def`, `defi` or `defb`.
    Definition(Definition),
    /// Any other instruction.
    Instruction(Instruction),
}

impl Item {
    /// The word of the record's token.
    pub fn word(&self) -> usize {
        match self {
            Item::Comment(c) => c.word,
            Item::Declaration(d) => d.word,
            Item::Definition(d) => d.word,
            Item::Instruction(i) => i.word,
        }
    }
}

/// A program read: its version, its records in stream order, its constant table and its debug information.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Program {
    /// The version token.
    pub version: Version,
    /// Every record between the version token and `END`, in stream order.
    pub items: Vec<Item>,
    /// The word of `END`.
    pub end: usize,
    /// The `CTAB` comment decoded; `None` when the program has none.
    pub constants: Option<ConstantTable>,
    /// The `DBUG` comment decoded (a `/Zi` build's); `None` when the program has none.
    pub debug: Option<DebugInfo>,
}

impl Program {
    /// The comments, in stream order.
    pub fn comments(&self) -> impl Iterator<Item = &Comment> {
        self.items.iter().filter_map(|i| match i {
            Item::Comment(c) => Some(c),
            _ => None,
        })
    }
    /// The declarations, in stream order.
    pub fn declarations(&self) -> impl Iterator<Item = &Declaration> {
        self.items.iter().filter_map(|i| match i {
            Item::Declaration(d) => Some(d),
            _ => None,
        })
    }
    /// The definitions, in stream order.
    pub fn definitions(&self) -> impl Iterator<Item = &Definition> {
        self.items.iter().filter_map(|i| match i {
            Item::Definition(d) => Some(d),
            _ => None,
        })
    }
    /// The instructions, in stream order.
    pub fn instructions(&self) -> impl Iterator<Item = &Instruction> {
        self.items.iter().filter_map(|i| match i {
            Item::Instruction(i) => Some(i),
            _ => None,
        })
    }
}

/// Read a complete program: version token to `END`, with nothing after it. The bytes are little-endian words.
pub fn read(bytes: &[u8]) -> Result<Program> {
    collect(records(bytes)?)
}

/// Read the first program of `bytes`, which may hold more after it (a container's other records, say), and return it
/// with its exact bytes, version token to `END`. `END` is found by reading every record, never by searching for it
/// inside operands or comments.
pub fn frame(bytes: &[u8]) -> Result<(Program, &[u8])> {
    let program = collect(start(bytes, false)?)?;
    let span = bytes
        .get(..program.end.saturating_add(1).saturating_mul(4))
        .ok_or_else(|| error(program.end, "END is past the buffer"))?;
    Ok((program, span))
}

/// The records of a complete program, one at a time in stream order, for a caller that stops at the first record it
/// cannot use, before the reader has read further (and refused, maybe, something later). The version is read first;
/// a refusal ends the iteration, as does `END`, after which words left over are a refusal. [`read`] is these records
/// collected.
pub fn records(bytes: &[u8]) -> Result<Records<'_>> {
    if !bytes.len().is_multiple_of(4) || bytes.len() > MAX_WORDS.saturating_mul(4) {
        return Err(error(
            0,
            format!(
                "token stream of {} bytes is not whole words or exceeds 1,048,576 words",
                bytes.len()
            ),
        ));
    }
    start(bytes, true)
}

fn start(bytes: &[u8], whole: bool) -> Result<Records<'_>> {
    let words = Words { bytes };
    let token = words.get(0).ok_or_else(|| error(0, "no version token"))?;
    let version = Version::from_token(token).ok_or_else(|| {
        error(
            0,
            format!(
                "version token {token:#010x} is not a Direct3D 9 vertex (0xfffe) or pixel (0xffff) program of \
                 version 1.0 to 3.0"
            ),
        )
    })?;
    Ok(Records {
        words,
        version,
        at: 1,
        whole,
        end: None,
        done: false,
        constants: None,
        debug: None,
    })
}

fn collect(mut records: Records<'_>) -> Result<Program> {
    let mut items = Vec::new();
    for item in records.by_ref() {
        items.push(item?);
    }
    Ok(Program {
        version: records.version,
        items,
        end: records.end.unwrap_or(0),
        constants: records.constants,
        debug: records.debug,
    })
}

/// A program's records in stream order: see [`records`].
#[derive(Debug)]
pub struct Records<'a> {
    words: Words<'a>,
    version: Version,
    /// The word of the next record's token.
    at: usize,
    /// True when the program is the whole buffer, so that words after `END` are a refusal.
    whole: bool,
    end: Option<usize>,
    done: bool,
    constants: Option<ConstantTable>,
    debug: Option<DebugInfo>,
}

impl Records<'_> {
    /// The program's version.
    pub fn version(&self) -> Version {
        self.version
    }
    /// The constant table, once the `CTAB` comment has been read.
    pub fn constants(&self) -> Option<&ConstantTable> {
        self.constants.as_ref()
    }
    /// The debug information, once the `DBUG` comment has been read.
    pub fn debug(&self) -> Option<&DebugInfo> {
        self.debug.as_ref()
    }
    /// The word of `END`, once it has been read.
    pub fn end(&self) -> Option<usize> {
        self.end
    }
}

impl Iterator for Records<'_> {
    type Item = Result<Item>;

    fn next(&mut self) -> Option<Result<Item>> {
        if self.done {
            return None;
        }
        match self.record() {
            Ok(Some(item)) => Some(Ok(item)),
            Ok(None) => {
                self.done = true;
                let words = self.words.len();
                (self.whole && self.at != words).then(|| {
                    Err(error(
                        self.at,
                        format!("{} words after END", words.saturating_sub(self.at)),
                    ))
                })
            }
            Err(e) => {
                self.done = true;
                Some(Err(e))
            }
        }
    }
}

/// The stream's words, read from the bytes as needed; a buffer's bytes after its last whole word are never read.
#[derive(Debug)]
struct Words<'a> {
    bytes: &'a [u8],
}

impl Words<'_> {
    fn len(&self) -> usize {
        (self.bytes.len() / 4).min(MAX_WORDS)
    }
    fn get(&self, at: usize) -> Option<u32> {
        if at >= MAX_WORDS {
            return None;
        }
        let start = at.checked_mul(4)?;
        let word: [u8; 4] = self.bytes.get(start..start.checked_add(4)?)?.try_into().ok()?;
        Some(u32::from_le_bytes(word))
    }
}

/// The bits of `word` from `shift` that `mask` keeps, which is at most 8 bits wide.
fn bits(word: u32, shift: u32, mask: u32) -> u8 {
    u8::try_from(word.checked_shr(shift).unwrap_or(0) & mask & 0xff).unwrap_or(u8::MAX)
}

/// The register an operand token names (its bits 14 to 15, a precision, are the caller's).
fn register(token: u32, at: usize, version: Version) -> Result<Register> {
    if token & 0x8000_0000 == 0 {
        return Err(error(at, format!("operand token {token:#010x} lacks bit 31")));
    }
    let code = ((token >> 28) & 7) | ((token >> 8) & 0x18);
    let number = token & 0x7ff;
    let (kind, last) =
        RegisterType::of(code, version).map_err(|why| error(at, format!("register type {code} {why}")))?;
    if last.is_some_and(|last| number > last) {
        return Err(error(
            at,
            format!(
                "register {kind:?} {number}, where the type has registers 0 to {}",
                last.unwrap_or(0)
            ),
        ));
    }
    Ok(Register { kind, number })
}

/// Reads the operand tokens of one instruction, from the word after the instruction token up to `end` (the
/// instruction's length from Shader Model 2 on; the stream's end in 1.x, whose instructions do not state theirs).
struct Operands<'a> {
    words: &'a Words<'a>,
    at: usize,
    end: usize,
    /// The instruction token's word, which a truncation names.
    instruction: usize,
    version: Version,
}

impl Operands<'_> {
    fn next(&mut self) -> Result<(usize, u32)> {
        let at = self.at;
        let token = (at < self.end)
            .then(|| self.words.get(at))
            .flatten()
            .ok_or_else(|| {
                error(
                    self.instruction,
                    format!(
                        "instruction's operand span extends past {} (it ends at word {})",
                        if self.end < self.words.len() {
                            "its stated length"
                        } else {
                            "the stream"
                        },
                        self.end.min(self.words.len())
                    ),
                )
            })?;
        self.at = at.saturating_add(1);
        Ok((at, token))
    }

    /// The relative-address token after an operand token with bit 13 set, or the implicit `a0.x` of vertex 1.x.
    fn relative(&mut self, operand: usize, what: &str) -> Result<Relative> {
        let version = self.version;
        if version.major == 1 {
            return Ok(Relative {
                word: None,
                register: Register {
                    kind: RegisterType::Address,
                    number: 0,
                },
                swizzle: [0; 4],
            });
        }
        let (at, token) = self.next().map_err(|e| {
            error(
                operand,
                format!(
                    "relative addressing of {what} without its address token: {}",
                    e.detail
                ),
            )
        })?;
        let register = register(token & !0x2000, at, version)?;
        // type 3 is the address register `a0`, or `tN` in a pixel program, which Microsoft's disassembler lists as one
        if !matches!(
            register.kind,
            RegisterType::Address | RegisterType::Texture | RegisterType::Loop
        ) || token & 0x2000 != 0
        {
            return Err(error(
                at,
                format!(
                    "relative address token of {what} names {register:?}{}, where it is the address register a0 or the \
                     loop counter aL",
                    if token & 0x2000 != 0 {
                        " relatively addressed itself"
                    } else {
                        ""
                    }
                ),
            ));
        }
        if (token >> 24) & 15 != 0 {
            return Err(error(
                at,
                format!(
                    "relative address token of {what} has source modifier {}, where it has none",
                    (token >> 24) & 15
                ),
            ));
        }
        Ok(Relative {
            word: Some(at),
            register,
            swizzle: [16, 18, 20, 22].map(|shift| bits(token, shift, 3)),
        })
    }

    fn destination(&mut self) -> Result<Destination> {
        let (at, token) = self.next()?;
        let version = self.version;
        let register = register(token & !0x2000, at, version)?;
        let modifiers = (token >> 20) & 15;
        if modifiers & 8 != 0 {
            return Err(error(
                at,
                format!("destination {token:#010x} sets result modifier bit 23"),
            ));
        }
        let shift = bits(token, 24, 15);
        let shift = if shift >= 8 {
            i8::try_from(i16::from(shift).saturating_sub(16)).unwrap_or(0)
        } else {
            i8::try_from(shift).unwrap_or(0)
        };
        // pixel 1.x's shifts are read in any version, as Microsoft's disassembler lists them; 4 to 12 are no shift
        if !(-3..=3).contains(&shift) {
            return Err(error(
                at,
                format!("destination {token:#010x} has result shift {shift}, where it is -3 to 3"),
            ));
        }
        // relative addressing too, which in Shader Model 1 has no address token
        let relative = if token & 0x2000 != 0 {
            Some(self.relative(at, "a destination")?)
        } else {
            None
        };
        Ok(Destination {
            word: at,
            register,
            mask: bits(token, 16, 15),
            saturate: modifiers & 1 != 0,
            partial_precision: modifiers & 2 != 0,
            centroid: modifiers & 4 != 0,
            shift,
            relative,
            precision: Precision::of(token),
        })
    }

    fn source(&mut self) -> Result<Source> {
        let (at, token) = self.next()?;
        let version = self.version;
        let register = register(token & !0x2000, at, version)?;
        let modifier = Modifier::of((token >> 24) & 15).ok_or_else(|| {
            error(
                at,
                format!("source modifier {} is not one of 0 to 13", (token >> 24) & 15),
            )
        })?;
        let relative = if token & 0x2000 != 0 {
            Some(self.relative(at, "a source")?)
        } else {
            None
        };
        Ok(Source {
            word: at,
            register,
            swizzle: [16, 18, 20, 22].map(|shift| bits(token, shift, 3)),
            modifier,
            relative,
            precision: Precision::of(token),
        })
    }
}

impl Records<'_> {
    /// The next record, `None` at `END`.
    fn record(&mut self) -> Result<Option<Item>> {
        let version = self.version;
        let words = &self.words;
        let mut at = self.at;
        let word = at;
        let token = words.get(word).ok_or_else(|| {
            error(
                word,
                if word >= MAX_WORDS {
                    "the program exceeds 1,048,576 words without END"
                } else {
                    "missing END"
                },
            )
        })?;
        at = at.saturating_add(1);
        if token == 0xffff {
            self.end = Some(word);
            self.at = at;
            return Ok(None);
        }
        let op = token & 0xffff;
        if op == 0xfffe {
            if token & 0x8000_0000 != 0 {
                return Err(error(word, "COMMENT reserved bit"));
            }
            let count = usize::try_from((token >> 16) & 0x7fff).unwrap_or(usize::MAX);
            let end = at.saturating_add(count);
            let data: Vec<u32> = (at..end).map_while(|n| words.get(n)).collect();
            if data.len() != count {
                return Err(error(
                    word,
                    format!(
                        "instruction/comment span of {count} words extends past the stream's {} words",
                        words.len()
                    ),
                ));
            }
            if let Some((&tag, rest)) = data.split_first() {
                let bytes = || -> Vec<u8> { rest.iter().flat_map(|w| w.to_le_bytes()).collect() };
                if tag == u32::from_le_bytes(*b"CTAB") {
                    if self.constants.is_some() {
                        return Err(error(word, "duplicate CTAB"));
                    }
                    self.constants = Some(crate::ctab::read(
                        &bytes(),
                        word.saturating_add(2),
                        version.token(),
                    )?);
                } else if tag == u32::from_le_bytes(*b"DBUG") {
                    if self.debug.is_some() {
                        return Err(error(word, "duplicate DBUG"));
                    }
                    self.debug = Some(crate::debug::read(&bytes(), word.saturating_add(2))?);
                }
            }
            self.at = end;
            return Ok(Some(Item::Comment(Comment { word, data })));
        }
        let opcode = u16::try_from(op)
            .ok()
            .and_then(Opcode::from_code)
            .ok_or_else(|| error(word, format!("opcode {op} is not a Direct3D 9 instruction")))?;
        // an opcode outside its versions is read with the operands it takes there, as Microsoft's disassembler lists it
        let sm1 = version.major == 1;
        let length = usize::from(bits(token, 24, 15));
        let shape = match (opcode, opcode.shape(version)) {
            // 3.0's `sgn` reads one source, but Microsoft's assembler writes the three of 2.x (`sgn r0, c0, r1, r2`):
            // the stated length tells which
            (Opcode::Sgn, Shape::Operands { destination, .. }) if version.major == 3 && length == 4 => {
                Shape::Operands {
                    destination,
                    sources: 3,
                }
            }
            (_, shape) => shape,
        };
        let predicated = token & 0x1000_0000 != 0;
        let coissue = token & 0x4000_0000 != 0;
        let control = bits(token, 16, 0xff);
        if token & 0xa000_0000 != 0 {
            return Err(error(
                word,
                format!("instruction token {token:#010x} sets reserved bit 29 or 31"),
            ));
        }
        // co-issue (pixel 1.x's) and predication (2.x's and 3.0's) are read in any version, as Microsoft's
        // disassembler lists them
        if shape == Shape::Phase && token != 0xfffd {
            return Err(error(
                word,
                format!("phase token {token:#010x} has bits beyond the opcode"),
            ));
        }
        let controlled = match opcode {
            Opcode::Tex if !sm1 => (0..=2).contains(&control),
            Opcode::IfC | Opcode::BreakC | Opcode::SetP => (1..=6).contains(&control),
            _ => control == 0,
        };
        if !controlled {
            return Err(error(
                word,
                format!(
                    "{} has control bits {control:#x}, which it does not define",
                    opcode.name()
                ),
            ));
        }
        let end = if sm1 {
            words.len()
        } else {
            let end = at.saturating_add(length);
            if end > words.len() {
                return Err(error(
                    word,
                    format!(
                        "instruction/comment span of {length} operands extends past the stream's {} words",
                        words.len()
                    ),
                ));
            }
            end
        };
        let mut operands = Operands {
            words,
            at,
            end,
            instruction: word,
            version,
        };
        let item = match shape {
            Shape::Phase => Item::Instruction(Instruction {
                word,
                opcode,
                control,
                coissue,
                predicate: None,
                destination: None,
                sources: Vec::new(),
            }),
            Shape::Declaration => {
                if predicated {
                    return Err(error(word, "predicated dcl"));
                }
                let (token_at, token) = operands.next()?;
                let destination = operands.destination()?;
                Item::Declaration(Declaration {
                    word,
                    token,
                    declared: declared(token, token_at, destination.register)?,
                    destination,
                })
            }
            Shape::Definition { words: count } => {
                if predicated {
                    return Err(error(word, format!("predicated {}", opcode.name())));
                }
                let destination = operands.destination()?;
                let expected = match opcode {
                    Opcode::Def => RegisterType::Const,
                    Opcode::DefI => RegisterType::ConstInt,
                    _ => RegisterType::ConstBool,
                };
                if destination.register.kind != expected || destination.relative.is_some() {
                    return Err(error(
                        destination.word,
                        format!(
                            "{} defines {:?}, where it defines a {expected:?} register",
                            opcode.name(),
                            destination.register
                        ),
                    ));
                }
                let mut values = [0u32; 4];
                for value in values.iter_mut().take(count) {
                    *value = operands.next()?.1;
                }
                let literal = match opcode {
                    Opcode::Def => Literal::Float(values),
                    Opcode::DefI => Literal::Integer(values.map(|v| i32::from_le_bytes(v.to_le_bytes()))),
                    _ => {
                        let [value, ..] = values;
                        Literal::Bool(value)
                    }
                };
                Item::Definition(Definition {
                    word,
                    destination,
                    literal,
                })
            }
            Shape::Operands { destination, sources } => {
                let destination = if destination {
                    Some(operands.destination()?)
                } else {
                    None
                };
                let predicate = if predicated {
                    let p = operands.source()?;
                    if p.register.kind != RegisterType::Predicate
                        || !matches!(p.modifier, Modifier::None | Modifier::Not)
                    {
                        return Err(error(
                            p.word,
                            format!(
                                "the predicate token names {:?} with {:?}, where it is p0 or !p0",
                                p.register, p.modifier
                            ),
                        ));
                    }
                    Some(p)
                } else {
                    None
                };
                let mut read = Vec::with_capacity(sources);
                for _ in 0..sources {
                    read.push(operands.source()?);
                }
                Item::Instruction(Instruction {
                    word,
                    opcode,
                    control,
                    coissue,
                    predicate,
                    destination,
                    sources: read,
                })
            }
        };
        let used = operands.at.saturating_sub(at);
        if sm1 {
            // a 1.x instruction states no length; one that states one must state its own
            if length != 0 && length != used {
                return Err(error(
                    word,
                    format!(
                        "{} states {length} operand tokens, where its operands take {used}",
                        opcode.name()
                    ),
                ));
            }
        } else if used != length {
            return Err(error(
                word,
                format!(
                    "{} states {length} operand tokens, where its operands take {used}",
                    opcode.name()
                ),
            ));
        }
        self.at = operands.at;
        Ok(Some(item))
    }
}

/// What a declaration token declares for `register`.
fn declared(token: u32, at: usize, register: Register) -> Result<Declared> {
    if token & 0x8000_0000 == 0 {
        return Err(error(at, format!("DCL token {token:#010x} lacks bit 31")));
    }
    if register.kind == RegisterType::Sampler {
        return Ok(Declared::Sampler(match token {
            0x9000_0000 => TextureType::D2,
            0x9800_0000 => TextureType::Cube,
            0xa000_0000 => TextureType::Volume,
            _ => {
                return Err(error(
                    at,
                    format!(
                        "DCL sampler texture type {token:#x}, where it is 0x90000000 (2d), 0x98000000 (cube) or \
                         0xa0000000 (volume)"
                    ),
                ));
            }
        }));
    }
    if token & !0x800f_000f != 0 {
        return Err(error(at, "DCL semantic reserved bits"));
    }
    let usage = bits(token, 0, 15);
    if usage > 13 {
        return Err(error(at, format!("DCL usage {usage}, where it is 0 to 13")));
    }
    Ok(Declared::Semantic {
        usage,
        index: bits(token, 16, 15),
    })
}
