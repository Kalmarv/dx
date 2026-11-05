//! The instruction opcodes of Direct3D 9 shader bytecode (`D3DSHADER_INSTRUCTION_OPCODE_TYPE` in `d3d9types.h`), the
//! shader versions each belongs to and the operands each takes there.

use crate::{Stage, Version};

/// An instruction opcode: the low 16 bits of an instruction token. The variants carry the token value
/// ([`Opcode::code`]) and the assembler's name ([`Opcode::name`]); declarations (`dcl`), definitions (`def`, `defi`,
/// `defb`), comments and `end` are opcodes of the stream as well but are read into their own records.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum Opcode {
    /// `nop` (0).
    Nop,
    /// `mov` (1).
    Mov,
    /// `add` (2).
    Add,
    /// `sub` (3).
    Sub,
    /// `mad` (4).
    Mad,
    /// `mul` (5).
    Mul,
    /// `rcp` (6).
    Rcp,
    /// `rsq` (7).
    Rsq,
    /// `dp3` (8).
    Dp3,
    /// `dp4` (9).
    Dp4,
    /// `min` (10).
    Min,
    /// `max` (11).
    Max,
    /// `slt` (12).
    Slt,
    /// `sge` (13).
    Sge,
    /// `exp` (14).
    Exp,
    /// `log` (15).
    Log,
    /// `lit` (16).
    Lit,
    /// `dst` (17).
    Dst,
    /// `lrp` (18).
    Lrp,
    /// `frc` (19).
    Frc,
    /// `m4x4` (20).
    M4x4,
    /// `m4x3` (21).
    M4x3,
    /// `m3x4` (22).
    M3x4,
    /// `m3x3` (23).
    M3x3,
    /// `m3x2` (24).
    M3x2,
    /// `call` (25): its source is the label `lN`.
    Call,
    /// `callnz` (26): a label, then the boolean constant `bN` or the predicate `p0` it tests.
    CallNz,
    /// `loop` (27): the loop counter `aL`, then the integer constant `iN` of its start, count and step.
    Loop,
    /// `ret` (28).
    Ret,
    /// `endloop` (29).
    EndLoop,
    /// `label` (30): its source is the label `lN`.
    Label,
    /// `dcl` (31), read into a [`crate::Declaration`].
    Dcl,
    /// `pow` (32).
    Pow,
    /// `crs` (33).
    Crs,
    /// `sgn` (34): three sources in Shader Model 2, one in 3.
    Sgn,
    /// `abs` (35).
    Abs,
    /// `nrm` (36).
    Nrm,
    /// `sincos` (37): three sources in Shader Model 2 (the angle and the two `D3DSINCOSCONST` registers), one in 3.
    SinCos,
    /// `rep` (38): its source is the integer constant `iN` whose x lane is the count.
    Rep,
    /// `endrep` (39).
    EndRep,
    /// `if` (40): its source is the boolean constant `bN` or the predicate `p0`.
    If,
    /// `if_comp` (41): two sources compared as [`crate::Instruction::comparison`] says.
    IfC,
    /// `else` (42).
    Else,
    /// `endif` (43).
    EndIf,
    /// `break` (44).
    Break,
    /// `break_comp` (45): two sources compared as [`crate::Instruction::comparison`] says.
    BreakC,
    /// `mova` (46).
    Mova,
    /// `defb` (47), read into a [`crate::Definition`].
    DefB,
    /// `defi` (48), read into a [`crate::Definition`].
    DefI,
    /// `texcoord` (64) before pixel 1.4, `texcrd` in 1.4.
    TexCoord,
    /// `texkill` (65): its destination token names the register tested.
    TexKill,
    /// `tex` (66) before pixel 1.4, `texld` from 1.4 on (`texldp` and `texldb` by [`crate::Instruction::control`]).
    Tex,
    /// `texbem` (67).
    TexBem,
    /// `texbeml` (68).
    TexBemL,
    /// `texreg2ar` (69).
    TexReg2Ar,
    /// `texreg2gb` (70).
    TexReg2Gb,
    /// `texm3x2pad` (71).
    TexM3x2Pad,
    /// `texm3x2tex` (72).
    TexM3x2Tex,
    /// `texm3x3pad` (73).
    TexM3x3Pad,
    /// `texm3x3tex` (74).
    TexM3x3Tex,
    /// `texm3x3spec` (76).
    TexM3x3Spec,
    /// `texm3x3vspec` (77).
    TexM3x3VSpec,
    /// `expp` (78).
    ExpP,
    /// `logp` (79).
    LogP,
    /// `cnd` (80).
    Cnd,
    /// `def` (81), read into a [`crate::Definition`].
    Def,
    /// `texreg2rgb` (82).
    TexReg2Rgb,
    /// `texdp3tex` (83).
    TexDp3Tex,
    /// `texm3x2depth` (84).
    TexM3x2Depth,
    /// `texdp3` (85).
    TexDp3,
    /// `texm3x3` (86).
    TexM3x3,
    /// `texdepth` (87).
    TexDepth,
    /// `cmp` (88).
    Cmp,
    /// `bem` (89).
    Bem,
    /// `dp2add` (90).
    Dp2Add,
    /// `dsx` (91).
    Dsx,
    /// `dsy` (92).
    Dsy,
    /// `texldd` (93).
    TexLdd,
    /// `setp_comp` (94): its destination is the predicate `p0`, its two sources compared as
    /// [`crate::Instruction::comparison`] says.
    SetP,
    /// `texldl` (95).
    TexLdl,
    /// `breakp` (96): its source is the predicate `p0`.
    BreakP,
    /// `phase` (0xfffd): the boundary between the two phases of a pixel 1.4 program.
    Phase,
}

/// Every opcode with its token value and name, in token order.
const TABLE: &[(Opcode, u16, &str)] = &[
    (Opcode::Nop, 0, "nop"),
    (Opcode::Mov, 1, "mov"),
    (Opcode::Add, 2, "add"),
    (Opcode::Sub, 3, "sub"),
    (Opcode::Mad, 4, "mad"),
    (Opcode::Mul, 5, "mul"),
    (Opcode::Rcp, 6, "rcp"),
    (Opcode::Rsq, 7, "rsq"),
    (Opcode::Dp3, 8, "dp3"),
    (Opcode::Dp4, 9, "dp4"),
    (Opcode::Min, 10, "min"),
    (Opcode::Max, 11, "max"),
    (Opcode::Slt, 12, "slt"),
    (Opcode::Sge, 13, "sge"),
    (Opcode::Exp, 14, "exp"),
    (Opcode::Log, 15, "log"),
    (Opcode::Lit, 16, "lit"),
    (Opcode::Dst, 17, "dst"),
    (Opcode::Lrp, 18, "lrp"),
    (Opcode::Frc, 19, "frc"),
    (Opcode::M4x4, 20, "m4x4"),
    (Opcode::M4x3, 21, "m4x3"),
    (Opcode::M3x4, 22, "m3x4"),
    (Opcode::M3x3, 23, "m3x3"),
    (Opcode::M3x2, 24, "m3x2"),
    (Opcode::Call, 25, "call"),
    (Opcode::CallNz, 26, "callnz"),
    (Opcode::Loop, 27, "loop"),
    (Opcode::Ret, 28, "ret"),
    (Opcode::EndLoop, 29, "endloop"),
    (Opcode::Label, 30, "label"),
    (Opcode::Dcl, 31, "dcl"),
    (Opcode::Pow, 32, "pow"),
    (Opcode::Crs, 33, "crs"),
    (Opcode::Sgn, 34, "sgn"),
    (Opcode::Abs, 35, "abs"),
    (Opcode::Nrm, 36, "nrm"),
    (Opcode::SinCos, 37, "sincos"),
    (Opcode::Rep, 38, "rep"),
    (Opcode::EndRep, 39, "endrep"),
    (Opcode::If, 40, "if"),
    (Opcode::IfC, 41, "if_comp"),
    (Opcode::Else, 42, "else"),
    (Opcode::EndIf, 43, "endif"),
    (Opcode::Break, 44, "break"),
    (Opcode::BreakC, 45, "break_comp"),
    (Opcode::Mova, 46, "mova"),
    (Opcode::DefB, 47, "defb"),
    (Opcode::DefI, 48, "defi"),
    (Opcode::TexCoord, 64, "texcoord"),
    (Opcode::TexKill, 65, "texkill"),
    (Opcode::Tex, 66, "tex"),
    (Opcode::TexBem, 67, "texbem"),
    (Opcode::TexBemL, 68, "texbeml"),
    (Opcode::TexReg2Ar, 69, "texreg2ar"),
    (Opcode::TexReg2Gb, 70, "texreg2gb"),
    (Opcode::TexM3x2Pad, 71, "texm3x2pad"),
    (Opcode::TexM3x2Tex, 72, "texm3x2tex"),
    (Opcode::TexM3x3Pad, 73, "texm3x3pad"),
    (Opcode::TexM3x3Tex, 74, "texm3x3tex"),
    (Opcode::TexM3x3Spec, 76, "texm3x3spec"),
    (Opcode::TexM3x3VSpec, 77, "texm3x3vspec"),
    (Opcode::ExpP, 78, "expp"),
    (Opcode::LogP, 79, "logp"),
    (Opcode::Cnd, 80, "cnd"),
    (Opcode::Def, 81, "def"),
    (Opcode::TexReg2Rgb, 82, "texreg2rgb"),
    (Opcode::TexDp3Tex, 83, "texdp3tex"),
    (Opcode::TexM3x2Depth, 84, "texm3x2depth"),
    (Opcode::TexDp3, 85, "texdp3"),
    (Opcode::TexM3x3, 86, "texm3x3"),
    (Opcode::TexDepth, 87, "texdepth"),
    (Opcode::Cmp, 88, "cmp"),
    (Opcode::Bem, 89, "bem"),
    (Opcode::Dp2Add, 90, "dp2add"),
    (Opcode::Dsx, 91, "dsx"),
    (Opcode::Dsy, 92, "dsy"),
    (Opcode::TexLdd, 93, "texldd"),
    (Opcode::SetP, 94, "setp_comp"),
    (Opcode::TexLdl, 95, "texldl"),
    (Opcode::BreakP, 96, "breakp"),
    (Opcode::Phase, 0xfffd, "phase"),
];

/// The operand tokens an opcode takes in one shader version.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum Shape {
    /// An optional destination, then `sources` source operands (each followed by its relative-address token where it
    /// has one).
    Operands { destination: bool, sources: usize },
    /// `dcl`: the declaration token, then a destination.
    Declaration,
    /// `def`, `defi`, `defb`: a destination, then `words` literal words.
    Definition { words: usize },
    /// `phase`: no operands, and no bits but the opcode.
    Phase,
}

/// A range of versions of one stage, both ends included: (major, minor), a software version's minor being 255.
type Range = Option<((u8, u8), (u8, u8))>;

const ALL: Range = Some(((1, 0), (3, 255)));
const FROM_2: Range = Some(((2, 0), (3, 255)));
const FROM_2X: Range = Some(((2, 1), (3, 255)));
const FROM_3: Range = Some(((3, 0), (3, 255)));
const NONE: Range = None;
const fn pixel(from: (u8, u8), to: (u8, u8)) -> Range {
    Some((from, to))
}

impl Opcode {
    /// The opcode's token value (bits 0 to 15 of the instruction token).
    pub fn code(self) -> u16 {
        TABLE
            .iter()
            .find(|row| row.0 == self)
            .map_or(u16::MAX, |row| row.1)
    }

    /// The assembler's name of the opcode, as `d3d9types.h` names it in lower case (`if_comp` for `IFC`, `setp_comp`
    /// for `SETP`; `tex` and `texcoord` whatever the version, which the assembler spells `texld` and `texcrd` from
    /// pixel 1.4 on).
    pub fn name(self) -> &'static str {
        TABLE.iter().find(|row| row.0 == self).map_or("", |row| row.2)
    }

    /// The opcode of a token value, `None` for a value Direct3D 9 does not define (75, the reserved `texm3x3diff`,
    /// among them).
    pub fn from_code(code: u16) -> Option<Self> {
        TABLE.iter().find(|row| row.1 == code).map(|row| row.0)
    }

    /// The vertex and pixel versions the opcode is an instruction of, from Microsoft's instruction lists per version.
    fn versions(self) -> (Range, Range) {
        use Opcode::*;
        match self {
            Nop | Mov | Add | Sub | Mad | Mul | Dp3 | Def => (ALL, ALL),
            Dcl => (ALL, FROM_2),
            Rcp | Rsq | Min | Max | Exp | Log | Frc | M4x4 | M4x3 | M3x4 | M3x3 | M3x2 => (ALL, FROM_2),
            Dp4 => (ALL, pixel((1, 2), (3, 255))),
            Slt | Sge | Lit | Dst | ExpP | LogP => (ALL, NONE),
            Lrp => (FROM_2, ALL),
            Pow | Crs | Abs | Nrm | SinCos => (FROM_2, FROM_2),
            Sgn | Mova => (FROM_2, NONE),
            Call | CallNz | Ret | Label | Rep | EndRep | If | Else | EndIf | DefB | DefI => (FROM_2, FROM_2X),
            Loop | EndLoop => (FROM_2, FROM_3),
            IfC | Break | BreakC | SetP | BreakP => (FROM_2X, FROM_2X),
            TexLdl => (FROM_3, FROM_3),
            TexKill | Tex => (NONE, ALL),
            TexCoord => (NONE, pixel((1, 0), (1, 4))),
            TexBem | TexBemL | TexReg2Ar | TexReg2Gb | TexM3x2Pad | TexM3x2Tex | TexM3x3Pad | TexM3x3Tex
            | TexM3x3Spec | TexM3x3VSpec => (NONE, pixel((1, 0), (1, 3))),
            TexReg2Rgb | TexDp3Tex | TexDp3 | TexM3x3 => (NONE, pixel((1, 2), (1, 3))),
            TexM3x2Depth => (NONE, pixel((1, 3), (1, 3))),
            Cnd => (NONE, pixel((1, 0), (1, 4))),
            Cmp => (NONE, pixel((1, 2), (3, 255))),
            TexDepth | Bem | Phase => (NONE, pixel((1, 4), (1, 4))),
            Dp2Add => (NONE, FROM_2),
            Dsx | Dsy | TexLdd => (NONE, FROM_2X),
        }
    }

    /// True when the opcode is an instruction of `version`.
    pub fn in_version(self, version: Version) -> bool {
        let (vertex, pixel) = self.versions();
        let range = match version.stage {
            Stage::Vertex => vertex,
            Stage::Pixel => pixel,
        };
        range.is_some_and(|(from, to)| (from..=to).contains(&(version.major, version.minor)))
    }

    /// The operands the opcode takes in `version` (which it must be an instruction of).
    pub(crate) fn shape(self, version: Version) -> Shape {
        use Opcode::*;
        let sm1 = version.major == 1;
        let sm3 = version.major == 3;
        let (destination, sources) = match self {
            Dcl => return Shape::Declaration,
            Def | DefI => return Shape::Definition { words: 4 },
            DefB => return Shape::Definition { words: 1 },
            Phase => return Shape::Phase,
            Nop | Ret | EndLoop | EndRep | Else | EndIf | Break => (false, 0),
            Call | Label | Rep | If | BreakP => (false, 1),
            CallNz | Loop | IfC | BreakC => (false, 2),
            TexKill | TexDepth => (true, 0),
            // `tex t0` and `texcoord t0` name only the register they write before pixel 1.4; `texld r0, t0` and
            // `texcrd r0, t0` read a texture coordinate register in 1.4; `texld r0, t0, s0` names the sampler from 2.0 on
            Tex if sm1 => (true, usize::from(version.minor == 4)),
            Tex => (true, 2),
            TexCoord => (true, usize::from(version.minor == 4)),
            Sgn | SinCos if !sm3 => (true, 3),
            Mov | Rcp | Rsq | Exp | Log | Lit | Frc | Abs | Nrm | Sgn | SinCos | Mova | ExpP | LogP | Dsx
            | Dsy | TexBem | TexBemL | TexReg2Ar | TexReg2Gb | TexM3x2Pad | TexM3x2Tex | TexM3x3Pad
            | TexM3x3Tex | TexM3x3VSpec | TexReg2Rgb | TexDp3Tex | TexM3x2Depth | TexDp3 | TexM3x3 => {
                (true, 1)
            }
            Add | Sub | Mul | Dp3 | Dp4 | Min | Max | Slt | Sge | Dst | M4x4 | M4x3 | M3x4 | M3x3 | M3x2
            | Pow | Crs | TexM3x3Spec | Bem | SetP | TexLdl => (true, 2),
            Mad | Lrp | Cnd | Cmp | Dp2Add => (true, 3),
            TexLdd => (true, 4),
        };
        Shape::Operands { destination, sources }
    }
}
