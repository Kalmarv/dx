//! A text listing of a Shader Model 4 or 5 container in the dialect of Microsoft's disassembler (`D3DDisassemble` with
//! no flags, `fxc /dumpbin`): the reflection and signature tables as comments, the program's declarations and
//! instructions, and the instruction count of the `STAT` part.
use crate::reflection::{rdef, signature};
use crate::{Result, chunk, code, decode, error, parts, statistics};

mod header;
mod number;
mod program;

/// The listing of a `DXBC` container's Shader Model 4 or 5 program as Microsoft's disassembler writes it, its lines
/// ending in `\n` (the disassembler's blob also ends in a zero byte, which is not part of the text).
///
/// Refuses a container [`parts`] refuses, one without a `SHDR` or `SHEX` part, a `DXIL` container and a program
/// [`decode()`] refuses.
pub fn disassemble(container: &[u8]) -> Result<String> {
    let directory = parts(container)?;
    if directory.iter().any(|c| &c.kind == b"DXIL") {
        return Err(error(
            0,
            "a DXIL container: its program is LLVM bitcode, not a Shader Model 4 or 5 token stream",
        ));
    }
    let program = decode(&code(container)?)?;
    let reflection = rdef(container)?;
    let read = |tags: &[&[u8; 4]]| -> Result<Option<(Vec<crate::SignatureElement>, bool)>> {
        match tags.iter().find(|t| directory.iter().any(|c| &&c.kind == *t)) {
            Some(tag) => {
                let elements = signature(chunk(&directory, tag)?, tag)?;
                // the rows name their streams where any is not stream 0
                let streams = elements.iter().any(|e| e.stream != 0);
                Ok(Some((elements, streams)))
            }
            None => Ok(None),
        }
    };
    let inputs = read(&[b"ISGN", b"ISG1"])?;
    let outputs = read(&[b"OSGN", b"OSG1", b"OSG5"])?;
    let patch = read(&[b"PCSG", b"PSG1"])?;
    let mut out = String::new();
    header::write(
        &mut out,
        &header::Header {
            program: &program,
            rdef: reflection.as_ref(),
            features: dxcontainer::feature_flags(container)
                .map_err(|e| error(e.offset / 4, e.detail))?
                .map_or(0, |f| f.bits),
            inputs: elements(&inputs),
            outputs: elements(&outputs),
            patch: elements(&patch),
        },
    );
    program::write(&mut out, &program);
    // Microsoft's disassembler writes the count of the STAT part, 0 without one
    let slots = statistics(container)?.and_then(|s| s.instructions()).unwrap_or(0);
    out.push_str(&format!("// Approximately {slots} instruction slots used\n"));
    Ok(out)
}

/// A signature part as the header reads it.
fn elements(part: &Option<(Vec<crate::SignatureElement>, bool)>) -> Option<header::Elements<'_>> {
    part.as_ref().map(|(elements, streams)| header::Elements {
        elements,
        streams: *streams,
    })
}
