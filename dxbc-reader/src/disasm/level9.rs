//! A feature level 9 container's part of the listing: the `Aon9` part's mapping tables, then its Direct3D 9 program
//! as `d3d9_reader` writes it, and the same for an XNA build's `XNAP` and `XNAS` parts. Each section is `//`, its
//! title, `//`, then its tables, each closed by `//`; a section with no rows is left out.
use crate::level9::{Level9, ScalarMapping};
use crate::{Result, error};
use std::fmt::Write;

const CONVERSIONS: [&str; 4] = ["FLT", "BOOL", "INT", "UINT"];

/// The listing of the part of kind `kind` (`Aon9`, `XNAP` or `XNAS`).
pub(super) fn write(out: &mut String, kind: &str, part: &Level9, options: &super::Options) -> Result<()> {
    if !(part.booleans.is_empty() && part.integers.is_empty() && part.constants.is_empty()) {
        out.push_str("//\n// Constant buffer to DX9 shader constant mappings:\n//\n");
        scalars(out, 'b', &part.booleans);
        scalars(out, 'i', &part.integers);
        if !part.constants.is_empty() {
            out.push_str("// Target Reg Buffer  Start Reg # of Regs        Data Conversion\n");
            out.push_str("// ---------- ------- --------- --------- ----------------------\n");
            for m in &part.constants {
                let mut conversion = Vec::new();
                for c in m.conversion {
                    let name = CONVERSIONS.get(usize::from(c)).ok_or_else(|| {
                        error(
                            0,
                            format!("a constant converts to {c}, where 0 to 3 are float, bool, int and uint"),
                        )
                    })?;
                    conversion.push(format!("{name:>4}"));
                }
                let _ = writeln!(
                    out,
                    "// {:<10} {:<7} {:>9} {:>9}  ({})",
                    format!("c{}", m.target),
                    format!("cb{}", m.buffer),
                    m.start,
                    m.count,
                    conversion.join(",")
                );
            }
            out.push_str("//\n");
        }
    }
    if !part.samplers.is_empty() {
        out.push_str("//\n// Sampler/Resource to DX9 shader sampler mappings:\n//\n");
        out.push_str("// Target Sampler Source Sampler  Source Resource\n");
        out.push_str("// -------------- --------------- ----------------\n");
        for m in &part.samplers {
            let _ = writeln!(
                out,
                "// {:<14} {:<15} {:<17}",
                format!("s{}", m.target),
                format!("s{}", m.sampler),
                format!("t{}", m.resource)
            );
        }
        out.push_str("//\n");
    }
    if !part.runtime.is_empty() {
        out.push_str("//\n// Runtime generated constant mappings:\n//\n");
        out.push_str("// Target Reg                               Constant Description\n");
        out.push_str("// ---------- --------------------------------------------------\n");
        for c in &part.runtime {
            let description = match c.kind {
                0 => "Vertex Shader position offset",
                kind => {
                    return Err(error(
                        0,
                        format!("a runtime constant of kind {kind}, where 0 is the only one known"),
                    ));
                }
            };
            let _ = writeln!(out, "// {:<10} {description:>50}", format!("c{}", c.target));
        }
        out.push_str("//\n");
    }
    let title = match kind {
        "XNAP" => "XNA Prepass shader bytecode",
        "XNAS" => "XNA shader bytecode",
        _ => "Level9 shader bytecode",
    };
    let _ = write!(out, "//\n// {title}:\n//\n");
    // the program's lines take the container listing's numbering, offsets, hex literals and debug information
    let mut d3d9 = d3d9_reader::Options::default();
    d3d9.numbering = options.numbering;
    d3d9.offsets = options.offsets;
    d3d9.hex_literals = options.hex_literals;
    d3d9.debug_info = options.debug_info;
    let listing = d3d9_reader::disassemble_with(&part.program, &d3d9).map_err(|e| {
        let word = usize::try_from(part.program_offset / 4).unwrap_or(usize::MAX);
        error(
            word.saturating_add(e.word),
            format!("the {kind} part's Direct3D 9 program: {}", e.detail),
        )
    })?;
    out.push_str(&listing);
    Ok(())
}

/// The int or bool constant table: a register's component copied into each `i#` or `b#` register.
fn scalars(out: &mut String, bank: char, rows: &[ScalarMapping]) {
    if rows.is_empty() {
        return;
    }
    out.push_str("// Target Reg Buffer  Source Reg Component\n");
    out.push_str("// ---------- ------- ---------- ---------\n");
    for m in rows {
        let _ = writeln!(
            out,
            "// {:<10} {:<7} {:>10} {:>9}",
            format!("{bank}{}", m.target),
            format!("cb{}", m.buffer),
            m.source,
            m.component
        );
    }
    out.push_str("//\n");
}
