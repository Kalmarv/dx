//! The debug information fxc writes with `/Zi` as a comment (`DBUG`): the source files, the source line of each
//! instruction, and which components of which variables each instruction writes. A Direct3D 9 program compiled on its
//! own carries it, and so does the Direct3D 9 program of a feature level 9 container.
//!
//! The layout below was read from programs fxc 10.0.26100.4654 built with `/Zi`, with and without `/Od`: pixel and
//! vertex programs of Shader Model 2 and 3, an included file, structs, matrices, arrays, loops and branches, each checked
//! against `D3DDisassemble`'s printing of them. Offsets are from the byte after the FourCC. The header is ten words:
//!
//! - 0 and 1: the offsets of the main source file's path and of the compiler's name;
//! - 2: 0 in every program seen;
//! - 3 and 4: the number of source files and the offset of their table (a word each: the offset of a path);
//! - 5 and 6: the number of line records and the offset of their table (8 bytes a record), one record for every
//!   declaration, definition and instruction, in stream order;
//! - 7 and 8: the number of variables and the offset of their table (20 bytes a record), in name order;
//! - 9: the offset of the entry point's name.
use crate::ctab::Reader;
use crate::{Result, Type, error};

/// The source line of one declaration, definition or instruction.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct SourceLine {
    /// The line number (u16 at offset 0 of the record); 0 where `file` is `None`.
    pub line: u16,
    /// The source file, by its place in [`DebugInfo::files`] (u16 at offset 2); `None` (`0xffff`) for a record with
    /// no source line, as a declaration has.
    pub file: Option<u16>,
    /// The byte offset of the record's token from the program's version token (u32 at offset 4).
    pub offset: u32,
}

/// Where an instruction writes a variable: the variable's components in its four destination lanes.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Location {
    /// The instruction, by its place in [`DebugInfo::lines`] (u32 at offset 0 of the 12-byte record).
    pub instruction: u32,
    /// The variable's component each of the lanes x, y, z and w holds (u16 at offsets 4 to 10), counting the
    /// components of a struct's members in member order; `None` (`0xffff`) for a lane that holds none of it.
    pub components: [Option<u16>; 4],
}

/// A variable: a parameter, a local, the function's return value or a constant.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Variable {
    /// The name of the function or constant buffer it is in (offset at 0 of the record); `None` (offset 0) for a
    /// local of the entry point and the return value of a function, named by the function's name.
    pub scope: Option<String>,
    /// The variable's name (offset at 4).
    pub name: String,
    /// The variable's type (offset at 8), in the layout of the constant table's types.
    pub ty: Type,
    /// The instructions that write it (the count at 12 and the table's offset at 16).
    pub locations: Vec<Location>,
}

/// The `DBUG` comment decoded.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DebugInfo {
    /// The main source file's path (header word 0).
    pub path: String,
    /// The compiler's name (header word 1).
    pub creator: String,
    /// Header word 2.
    pub reserved: u32,
    /// The source files' paths.
    pub files: Vec<String>,
    /// The source lines, a record for each declaration, definition and instruction in stream order.
    pub lines: Vec<SourceLine>,
    /// The variables, in name order.
    pub variables: Vec<Variable>,
    /// The entry point's name (header word 9).
    pub entry: String,
}

/// The comment's bytes after the FourCC, whose byte 0 lies in program word `word`. Refuses tables outside the
/// comment, a line record naming a file that isn't in the table, and a location naming an instruction that has no
/// line record.
pub(crate) fn read(data: &[u8], word: usize) -> Result<DebugInfo> {
    let r = Reader {
        data,
        word,
        tag: "DBUG",
    };
    let header = |n: usize| r.offset(n.saturating_mul(4));
    let table = |count: usize, size: usize| -> Result<usize> {
        let at = header(count.saturating_add(1))?;
        r.range(at, r.bytes(at, header(count)?, size)?)?;
        Ok(at)
    };
    let (file_count, files_at) = (header(3)?, table(3, 4)?);
    let mut files = Vec::new();
    for n in 0..file_count {
        files.push(r.string(r.offset(r.plus(files_at, r.bytes(files_at, n, 4)?)?)?)?);
    }
    let (line_count, lines_at) = (header(5)?, table(5, 8)?);
    let mut lines = Vec::new();
    for n in 0..line_count {
        let at = r.plus(lines_at, r.bytes(lines_at, n, 8)?)?;
        let file = r.u16(r.plus(at, 2)?)?;
        if file != 0xffff && usize::from(file) >= file_count {
            return Err(error(
                r.word_of(at),
                format!("DBUG line record {n} names file {file}, where there are {file_count}"),
            ));
        }
        lines.push(SourceLine {
            line: r.u16(at)?,
            file: (file != 0xffff).then_some(file),
            offset: r.u32(r.plus(at, 4)?)?,
        });
    }
    let (variable_count, variables_at) = (header(7)?, table(7, 20)?);
    let mut variables = Vec::new();
    let mut budget = 4096;
    for n in 0..variable_count {
        let at = r.plus(variables_at, r.bytes(variables_at, n, 20)?)?;
        let scope = r.offset(at)?;
        let location_count = r.offset(r.plus(at, 12)?)?;
        let locations_at = r.offset(r.plus(at, 16)?)?;
        r.range(locations_at, r.bytes(locations_at, location_count, 12)?)?;
        let mut locations = Vec::new();
        for l in 0..location_count {
            let record = r.plus(locations_at, r.bytes(locations_at, l, 12)?)?;
            let instruction = r.u32(record)?;
            if usize::try_from(instruction).map_or(true, |i| i >= line_count) {
                return Err(error(
                    r.word_of(record),
                    format!(
                        "DBUG location of variable {n} names instruction {instruction}, where there are {line_count}"
                    ),
                ));
            }
            let mut components = [None; 4];
            for (lane, slot) in components.iter_mut().enumerate() {
                let c = r.u16(r.plus(record, lane.saturating_mul(2).saturating_add(4))?)?;
                *slot = (c != 0xffff).then_some(c);
            }
            locations.push(Location {
                instruction,
                components,
            });
        }
        variables.push(Variable {
            scope: if scope == 0 { None } else { Some(r.string(scope)?) },
            name: r.string(r.offset(r.plus(at, 4)?)?)?,
            ty: r.ty(r.offset(r.plus(at, 8)?)?, 0, &mut budget)?,
            locations,
        });
    }
    Ok(DebugInfo {
        path: r.string(header(0)?)?,
        creator: r.string(header(1)?)?,
        reserved: r.u32(8)?,
        files,
        lines,
        variables,
        entry: r.string(header(9)?)?,
    })
}
