//! A reader of Direct3D 9 shader bytecode: the token stream a Direct3D 9 compiler or assembler writes for a vertex or
//! pixel program of Shader Model 1.x, 2.x or 3.0, from its version token to `END`, with no container around it.
//!
//! [`read`] decodes the stream into typed records in stream order ([`Program::items`]): every comment, every
//! declaration (`dcl`), every literal definition (`def`, `defi`, `defb`) and every instruction with its opcode, control
//! bits, co-issue and predicate, destination (register, write mask, saturate, partial precision, centroid, the pixel 1.x
//! result shift) and sources (register, swizzle, modifier, relative address). The `CTAB` comment D3DX writes is decoded
//! as well ([`ConstantTable`]), and so is the `DBUG` comment of a `/Zi` build ([`DebugInfo`]). [`frame`] reads the first program of a buffer that holds more after it.
//!
//! It reads and checks bytes and never interprets them for an API: registers are Direct3D's register types and numbers,
//! modifiers and usages Direct3D's own values. An instruction, register type or operand flag of another version (a
//! pixel instruction in a vertex program, `i0` in vs_1_1, predication in 2.0) is read, as Microsoft's disassembler lists
//! it. Whatever the format does not define (an opcode or register type with no name, a version that is none of 1.0 to
//! 3.0, a reserved bit set, an instruction whose length disagrees with its operands) is an [`Error`] naming the 32-bit
//! word where it is, where Microsoft's disassembler lists such a stream as garbage (`???`, `ps_2_254`); it never panics
//! on untrusted input.
//!
//! ```
//! # fn main() -> Result<(), d3d9_reader::Error> {
//! // ps_2_0: dcl t0.xy; dcl_2d s0; texld r0, t0, s0; mov oC0, r0; end
//! let words: [u32; 14] = [
//!     0xffff_0200,
//!     0x0200_001f, 0x8000_0000, 0xb003_0000,
//!     0x0200_001f, 0x9000_0000, 0xa00f_0800,
//!     0x0300_0042, 0x800f_0000, 0xb0e4_0000, 0xa0e4_0800,
//!     0x0200_0001, 0x800f_0800, 0x80e4_0000,
//! ];
//! let bytes: Vec<u8> = words.iter().chain(&[0xffff]).flat_map(|w| w.to_le_bytes()).collect();
//! let program = d3d9_reader::read(&bytes)?;
//! assert_eq!(program.version.to_string(), "ps_2_0");
//! assert_eq!(program.declarations().count(), 2);
//! let names: Vec<_> = program.instructions().map(|i| i.opcode.name()).collect();
//! assert_eq!(names, ["tex", "mov"]);
//! # Ok(()) }
//! ```
#![deny(
    clippy::arithmetic_side_effects,
    clippy::indexing_slicing,
    clippy::cast_possible_truncation
)]
#![deny(missing_docs)]
#![deny(clippy::disallowed_methods, clippy::disallowed_types)]

mod ctab;
mod debug;
mod disasm;
mod opcodes;
mod program;

pub use ctab::{Constant, ConstantTable, Type, TypeMember};
pub use debug::{DebugInfo, Location, SourceLine, Variable};
pub use disasm::{Options, disassemble, disassemble_with};
pub use opcodes::Opcode;
pub use program::{
    Comment, Comparison, Declaration, Declared, Definition, Destination, Instruction, Item, Literal,
    Modifier, Precision, Program, Records, Register, RegisterType, Relative, Source, TextureType, frame,
    read, records,
};

/// Something the reader can't read: the 32-bit word of the token stream where it is (the version token is word 0), and
/// what was expected there or found instead.
#[derive(Clone, Debug, PartialEq, Eq, thiserror::Error)]
#[error("D3D9 at word {word}: {detail}")]
pub struct Error {
    /// The word offset from the version token.
    pub word: usize,
    /// What was expected there, or what was found instead.
    pub detail: String,
}

/// The reader's result: an [`Error`] naming the word where reading failed.
pub type Result<T> = std::result::Result<T, Error>;

pub(crate) fn error(word: usize, detail: impl Into<String>) -> Error {
    Error {
        word,
        detail: detail.into(),
    }
}

/// The stage a program is for: the high 16 bits of its version token, `0xfffe` vertex and `0xffff` pixel.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Stage {
    /// A vertex program (`vs_*`).
    Vertex,
    /// A pixel program (`ps_*`).
    Pixel,
}

/// A program's version token: the stage, and the major and minor version in its low 16 bits.
///
/// The versions read are vertex 1.0, 1.1, 2.0, 2.1 (`vs_2_x`, which `vs_2_a` compiles to), 3.0 and the software
/// versions 2.255 and 3.255 (`vs_2_sw`, `vs_3_sw`), and pixel 1.0 to 1.4, 2.0, 2.1 (`ps_2_x`: `ps_2_a` and `ps_2_b`
/// compile to it), 3.0, 2.255 and 3.255.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Version {
    /// Vertex or pixel.
    pub stage: Stage,
    /// Bits 8 to 15 of the token.
    pub major: u8,
    /// Bits 0 to 7 of the token; 255 for a software version.
    pub minor: u8,
}

impl Version {
    /// The version of a version token, `None` for a token that is not one of the versions this reader reads.
    pub fn from_token(token: u32) -> Option<Self> {
        let [minor, major, ..] = token.to_le_bytes();
        let stage = match token >> 16 {
            0xfffe => Stage::Vertex,
            0xffff => Stage::Pixel,
            _ => return None,
        };
        let known = matches!(
            (stage, major, minor),
            (Stage::Vertex, 1, 0 | 1) | (Stage::Pixel, 1, 0..=4) | (_, 2, 0 | 1 | 255) | (_, 3, 0 | 255)
        );
        known.then_some(Self { stage, major, minor })
    }

    /// The version token.
    pub fn token(self) -> u32 {
        let stage: u32 = match self.stage {
            Stage::Vertex => 0xfffe,
            Stage::Pixel => 0xffff,
        };
        (stage << 16) | (u32::from(self.major) << 8) | u32::from(self.minor)
    }
}

impl std::fmt::Display for Version {
    /// The profile name as Microsoft's disassembler writes it: `vs_1_1`, `ps_2_x`, `vs_3_sw`.
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let stage = match self.stage {
            Stage::Vertex => "vs",
            Stage::Pixel => "ps",
        };
        match (self.major, self.minor) {
            (2, 1) => write!(f, "{stage}_2_x"),
            (major, 255) => write!(f, "{stage}_{major}_sw"),
            (major, minor) => write!(f, "{stage}_{major}_{minor}"),
        }
    }
}
