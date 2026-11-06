//! A disassembler of DXIL programs: the listing `dxc -dumpbin` (dxc 1.9.2609) prints of a container, byte for byte.
//!
//! The listing is dxc's comment header (`dxcdisassembler.cpp`: the feature flags, the signature parts, the debug name
//! and hash, the pipeline state validation runtime info, and from the program's metadata its signatures, buffer
//! layouts, resource bindings, view-id state and a library's subobjects), then the program's module as LLVM 3.7 prints
//! it, with dxc's comment after each call of a DXIL operation. What the reader can't read is an error, never a listing
//! that differs from dxc's.
//!
//! ```no_run
//! # fn main() -> Result<(), dxil_reader::Error> {
//! let container = std::fs::read("shader.dxil").expect("a compiled shader");
//! print!("{}", dxil_reader::disasm::disassemble(&container)?);
//! # Ok(()) }
//! ```
mod annotate;
mod asm;
mod header;
mod layout;
#[rustfmt::skip] // written by `cargo xtask dxil-ops`, as it is
mod ops;

use crate::{Module, Result, error, psv, rdat};

/// The listing `dxc -dumpbin` prints of a DXBC container holding a DXIL program, to the newline it ends with.
pub fn disassemble(container: &[u8]) -> Result<String> {
    let parts = crate::parts(container)?;
    let find = |kind: &[u8; 4]| parts.iter().find(|c| &c.kind == kind).map(|c| c.data);
    let mut s = String::new();
    if let Some(sfi0) = find(b"SFI0") {
        header::feature_info(&mut s, sfi0)?;
    }
    for (kind, name, input) in [
        (b"ISG1", "Input", true),
        (b"OSG1", "Output", false),
        (b"PSG1", "Patch Constant", false),
    ] {
        if let Some(part) = find(kind) {
            header::part_signature(&mut s, name, part, input)?;
        }
    }
    if let Some(ildn) = find(b"ILDN") {
        header::debug_name(&mut s, ildn);
    }
    if let Some(hash) = find(b"HASH") {
        header::hash(&mut s, hash)?;
    }
    // the debug module, where the container has one, is the one listed
    let program = find(b"ILDB")
        .or_else(|| find(b"DXIL"))
        .ok_or_else(|| error(0, "the container has no DXIL part"))?;
    let program = crate::program(program)?;
    if let Some(part) = find(b"PSV0") {
        header::psv_runtime(&mut s, &psv::read(part)?)?;
    }
    let module = read(program.bitcode)?;
    // the STAT part's module holds the reflection the program part's may be stripped of; dxc ignores one whose header
    // it can't read
    let reflection = match find(b"STAT").map(crate::program) {
        Some(Ok(part)) => Some(read(part.bitcode)?),
        _ => None,
    };
    if module.named_metadata.iter().any(|(n, _)| n == "dx.version") {
        let kind = crate::reflection::shader_model(&module)?
            .map(|(k, _, _)| k)
            .ok_or_else(|| error(module.at, "the module has no dx.shaderModel metadata"))?;
        if kind != "lib" {
            header::dxil_signatures(&mut s, &module, &kind)?;
        }
        header::reflection_sections(&mut s, reflection.as_ref().unwrap_or(&module))?;
        let subobjects = match find(b"RDAT") {
            Some(part) => rdat::subobjects(part)?,
            None => Vec::new(),
        };
        if subobjects.is_empty() && module.named_metadata.iter().any(|(n, _)| n == "dx.subobjects") {
            return Err(error(
                module.at,
                "subobjects in dx.subobjects metadata are not supported",
            ));
        }
        header::subobjects(&mut s, &subobjects);
    }
    asm::write(&mut s, &module)?;
    // dxc's console writer ends the text with a newline of its own
    s.push('\n');
    Ok(s)
}

/// The module part of the listing: from `target datalayout` on, the program's IR as dxc prints it.
pub fn module_text(m: &Module) -> Result<String> {
    let mut s = String::new();
    asm::write(&mut s, m)?;
    Ok(s)
}

fn read(bitcode: &[u8]) -> Result<Module> {
    Module::read(&crate::bitstream::read(bitcode, *b"BC\xc0\xde")?)
}
