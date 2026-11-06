//! A text listing of a Shader Model 4 or 5 container in the dialect of Microsoft's disassembler (`D3DDisassemble` with
//! no flags, `fxc /dumpbin`): the reflection and signature tables as comments, the program's declarations and
//! instructions, and the instruction count of the `STAT` part.
use crate::reflection::{rdef, signature};
use crate::{Result, chunk, code, decode, error, parts, statistics};

mod header;
mod level9;
mod number;
mod program;

/// How the listing is written: the switches of Microsoft's `D3D_DISASM_*` flags that this disassembler writes.
/// [`Options::default`] is `D3DDisassemble` with no flags.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[non_exhaustive]
pub struct Options {
    /// The comment block before the program and the instruction count after it; off, only the program's lines
    /// (`D3D_DISASM_INSTRUCTION_ONLY`, 0x40).
    pub header: bool,
    /// Each instruction after its number, `  12: `, other lines after as many spaces; before an offset, `  12  `
    /// (`D3D_DISASM_ENABLE_INSTRUCTION_NUMBERING`, 0x04).
    pub numbering: bool,
    /// Each line after the byte offset of its token in the program, `0x0000001C: `, after the number
    /// (`D3D_DISASM_ENABLE_INSTRUCTION_OFFSET`, 0x20).
    pub offsets: bool,
    /// Every 32-bit value as eight hex digits, `l(0x3f800000)` (`D3D_DISASM_PRINT_HEX_LITERALS`, 0x80).
    pub hex_literals: bool,
    /// A `/Zi` build's source lines and variable locations: from the `SPDB` part, `#line` lines, the variables'
    /// initial locations before the first instruction with a line, and after an instruction the locations that start
    /// at the next; from a feature level 9 container's Direct3D 9 program, its own (cleared by
    /// `D3D_DISASM_DISABLE_DEBUG_INFO`, 0x10).
    pub debug_info: bool,
}

impl Default for Options {
    fn default() -> Self {
        Self {
            header: true,
            numbering: false,
            offsets: false,
            hex_literals: false,
            debug_info: true,
        }
    }
}

impl Options {
    /// The options of a `D3D_DISASM_*` flags word. `D3D_DISASM_ENABLE_DEFAULT_VALUE_PRINTS` (0x02) changes nothing
    /// (the default values are written either way). Refuses
    /// `D3D_DISASM_ENABLE_COLOR_CODE` (0x01, an HTML listing), `D3D_DISASM_ENABLE_INSTRUCTION_CYCLE` (0x08, which
    /// Microsoft's disassembler refuses too) and bits it does not define, naming the bit.
    pub fn from_flags(flags: u32) -> Result<Self> {
        for (bit, name) in [
            (0x01, "D3D_DISASM_ENABLE_COLOR_CODE (an HTML listing)"),
            (
                0x08,
                "D3D_DISASM_ENABLE_INSTRUCTION_CYCLE, which Microsoft's disassembler refuses too",
            ),
        ] {
            if flags & bit != 0 {
                return Err(error(0, format!("flag 0x{bit:02x}, {name}, is not written")));
            }
        }
        let unknown = flags & !0xf6;
        if unknown != 0 {
            return Err(error(
                0,
                format!(
                    "flag bit 0x{:x} is not a D3D_DISASM flag",
                    1u32 << unknown.trailing_zeros()
                ),
            ));
        }
        Ok(Self {
            header: flags & 0x40 == 0,
            numbering: flags & 0x04 != 0,
            offsets: flags & 0x20 != 0,
            hex_literals: flags & 0x80 != 0,
            debug_info: flags & 0x10 == 0,
        })
    }
}

/// The listing of a `DXBC` container's Shader Model 4 or 5 program as Microsoft's disassembler writes it with no
/// flags, its lines ending in `\n` (the disassembler's blob also ends in a zero byte, which is not part of the text).
///
/// Refuses a container [`parts`] refuses, one without a `SHDR` or `SHEX` part, a `DXIL` container and a program
/// [`decode()`] refuses.
pub fn disassemble(container: &[u8]) -> Result<String> {
    disassemble_with(container, &Options::default())
}

/// The listing of a `DXBC` container as [`disassemble`] writes it, with `options`.
pub fn disassemble_with(container: &[u8], options: &Options) -> Result<String> {
    let directory = parts(container)?;
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
    let stat = statistics(container)?;
    let mut out = String::new();
    if options.header {
        header::write(
            &mut out,
            &header::Header {
                program: &program,
                rdef: reflection.as_ref(),
                features: dxcontainer::feature_flags(container)
                    .map_err(|e| error(e.offset / 4, e.detail))?
                    .map_or(0, |f| f.bits),
                stat: stat.as_ref(),
                inputs: elements(&inputs),
                outputs: elements(&outputs),
                patch: elements(&patch),
                interfaces: crate::interfaces(container)?.as_ref(),
                debug_layer: dxcontainer::checksum(container).as_ref().map(|d| &d[..])
                    != container.get(4..20),
            },
        );
        if let Some(part) = crate::level9(container)? {
            level9::write(&mut out, &part, options)?;
        }
    }
    let annotations = match directory.iter().any(|c| &c.kind == b"SPDB") && options.debug_info {
        true => Some(crate::spdb::annotations(
            chunk(&directory, b"SPDB")?,
            (program.major, program.minor) >= (5, 1),
        )?),
        false => None,
    };
    program::write(&mut out, &program, options, annotations.as_ref());
    if !options.header {
        return Ok(out);
    }
    // Microsoft's disassembler writes the count of the STAT part, 0 without one
    let slots = stat.and_then(|s| s.instructions()).unwrap_or(0);
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
