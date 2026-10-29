//! A reader of Shader Model 4 and 5 programs as Direct3D stores them in a `DXBC` container: the token stream of any
//! stage ([`mod@decode`]), the reflection and signature chunks as the records the file holds ([`reflection`]), and the
//! compiler's own counters ([`statistics`]).
//!
//! It reads and checks bytes and never interprets them for an API: a register binding is the RDEF record's own
//! numbers, a signature element its stored name, index and masks. Mapping those into a graphics API's vocabulary is
//! the caller's choice. Everything it can't read (a truncated instruction, an out-of-range table, a cyclic type) is an
//! [`Error`] naming the 32-bit word where it happened; it never panics on untrusted input.
//!
//! ```no_run
//! # fn main() -> Result<(), dxbc_reader::Error> {
//! let container = std::fs::read("shader.dxbc").expect("a compiled shader");
//! let code = dxbc_reader::code(&container)?;
//! let program = dxbc_reader::decode(&code)?;
//! println!("{} with {} instructions", program.target(), program.instructions.len());
//! # Ok(()) }
//! ```
#![deny(
    clippy::arithmetic_side_effects,
    clippy::indexing_slicing,
    clippy::cast_possible_truncation
)]
#![deny(missing_docs)]
#![deny(clippy::disallowed_methods, clippy::disallowed_types)]

mod controls;
pub mod decode;
mod format;
mod opcodes;
pub mod reflection;
mod sampling;
pub mod statistics;

pub use controls::{GlobalFlags, InfoReturn, SyncFlags};
pub use decode::{
    Declaration, Declared, Decoded, Index, Instruction, Operand, ProgramType, Register, Selection, decode,
    opcode_name,
};
pub use format::{OperandClass, OperandFormat, operand_format};
pub use reflection::{
    Rdef, RdefBinding, RdefBuffer, RdefMember, RdefType, RdefVariable, SignatureElement,
    patch_signature_elements, program_type, rdef, rdef_target, signature, signature_elements,
};
pub use sampling::{TextureRead, texture_reads};
pub use statistics::{Statistics, statistics};

/// Something the reader can't read: the 32-bit word of the container's chunk or token stream where it is, and what.
#[derive(Clone, Debug, PartialEq, Eq, thiserror::Error)]
#[error("DXBC at word {word}: {detail}")]
pub struct Error {
    /// The word offset, counted from the start of the chunk or token stream being read.
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

/// The container's parts (its `DXBC` directory).
pub fn parts(bytes: &[u8]) -> Result<Vec<dxcontainer::Chunk<'_>>> {
    dxcontainer::chunks(bytes).map_err(|e| error(e.offset / 4, e.detail))
}

/// The container's one part of kind `tag`: an error where it has none, or more than one.
pub fn chunk<'a>(directory: &[dxcontainer::Chunk<'a>], tag: &[u8; 4]) -> Result<&'a [u8]> {
    let shown = String::from_utf8_lossy(tag);
    let mut matching = directory.iter().filter(|c| &c.kind == tag);
    let data = matching
        .next()
        .ok_or_else(|| error(0, format!("the container has no {shown} part")))?
        .data;
    if matching.next().is_some() {
        return Err(error(
            0,
            format!("the container has the {shown} part more than once"),
        ));
    }
    Ok(data)
}

/// The program's token stream (its `SHEX` or `SHDR` part) as 32-bit little-endian words, for [`decode()`].
pub fn code(bytes: &[u8]) -> Result<Vec<u32>> {
    let directory = parts(bytes)?;
    let code = directory
        .iter()
        .find(|c| matches!(&c.kind, b"SHDR" | b"SHEX"))
        .ok_or_else(|| error(0, "missing shader code chunk"))?;
    if code.data.len() % 4 != 0 {
        return Err(error(
            code.data.len() / 4,
            format!(
                "the code part is {} bytes, expected a multiple of 4 (32-bit tokens)",
                code.data.len()
            ),
        ));
    }
    Ok(code
        .data
        .as_chunks::<4>()
        .0
        .iter()
        .map(|b| u32::from_le_bytes(*b))
        .collect())
}
