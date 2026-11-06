//! `cargo xtask dxil-ops`: `dxil-reader/src/disasm/ops.rs`, the name and operand list dxc's listing gives each DXIL
//! operation (`; Sample(srv,sampler,...)`), from dxc's own operation tables.
//!
//! dxc's disassembler prints `GetOpCodeName(op)` and then `OpCodeSignatures[table][index]`, a table its build makes
//! from `utils/hct/hctdb.py`. The same database is committed in C++ form, written by hctdb into the files it
//! generates, and this reads those at the pinned tag:
//!
//! - `include/dxc/DXIL/DxilConstants.h`, the `OpCodeTableID` enumeration: each table's name and id;
//! - `lib/DXIL/DxilOperations.cpp`, `<table>_OpCodeProps`: each operation's name and class, by index;
//! - `include/dxc/DXIL/DxilInstructions.h`, `DxilInst_<name>`: the helper hctdb writes for every operation that is
//!   not reserved, whose `OperandIdx` enumeration lists the operands after the opcode, in order. These are the
//!   operands `OpCodeSignatures` lists (hctdb's `get_opsigs_for_table`); a reserved operation has none.
use std::collections::BTreeMap;
use std::path::Path;
use std::process::Command;
use std::{fmt::Write as _, fs};

use crate::generated;

/// The DirectXShaderCompiler release the listings are compared with.
pub(crate) const TAG: &str = "v1.9.2609";

const CONSTANTS: &str = "include/dxc/DXIL/DxilConstants.h";
const OPERATIONS: &str = "lib/DXIL/DxilOperations.cpp";
const INSTRUCTIONS: &str = "include/dxc/DXIL/DxilInstructions.h";

/// The committed file, from the workspace root.
pub(crate) const OUTPUT: &str = "dxil-reader/src/disasm/ops.rs";

/// One operation table: its name (`CoreOps`), id (the opcode's upper 16 bits) and operations (name, operands).
#[derive(Debug)]
struct Table {
    name: String,
    id: u32,
    operations: Vec<(String, String)>,
}

pub(crate) fn run(source: &Path, check: bool) -> Result<String, String> {
    let described = Command::new("git")
        .arg("-C")
        .arg(source)
        .args(["describe", "--tags", "--exact-match"])
        .output()
        .map_err(|e| format!("git describe in {}: {e}", source.display()))?;
    let described = String::from_utf8_lossy(&described.stdout).trim().to_owned();
    if described != TAG {
        return Err(format!(
            "the checkout is at {}, not {TAG}",
            if described.is_empty() {
                "no tag"
            } else {
                &described
            }
        ));
    }
    let read = |path: &str| fs::read(source.join(path)).map_err(|e| format!("{path}: {e}"));
    let (constants, operations, instructions) = (read(CONSTANTS)?, read(OPERATIONS)?, read(INSTRUCTIONS)?);
    let text = |bytes: &[u8], path: &str| {
        String::from_utf8(bytes.to_vec()).map_err(|_| format!("{path}: not UTF-8"))
    };
    let tables = tables(
        &text(&constants, CONSTANTS)?,
        &text(&operations, OPERATIONS)?,
        &text(&instructions, INSTRUCTIONS)?,
    )?;
    let file = generated::file(
        "dxil-ops",
        &format!("DirectXShaderCompiler {TAG}"),
        &[
            (OPERATIONS, &operations),
            (INSTRUCTIONS, &instructions),
            (CONSTANTS, &constants),
        ],
        &render(&tables),
    );
    generated::write_or_check(&crate::root().join(OUTPUT), &file, check)?;
    let counts: Vec<String> = tables
        .iter()
        .map(|t| format!("{} {}", t.name, t.operations.len()))
        .collect();
    Ok(format!(
        "{}{OUTPUT}: {}",
        if check { "unchanged " } else { "" },
        counts.join(", ")
    ))
}

/// The lines from the one after `begin` to the one before the first `end` after it.
fn between<'a>(text: &'a str, begin: &str, end: &str, what: &str) -> Result<&'a str, String> {
    let start = text.find(begin).ok_or_else(|| format!("{what}: no `{begin}`"))? + begin.len();
    let length = text[start..]
        .find(end)
        .ok_or_else(|| format!("{what}: `{begin}` has no `{end}`"))?;
    Ok(&text[start..start + length])
}

fn tables(constants: &str, operations: &str, instructions: &str) -> Result<Vec<Table>, String> {
    let operands = operands(instructions)?;
    let enumeration = between(
        constants,
        "enum class OpCodeTableID : unsigned {",
        "};",
        CONSTANTS,
    )?;
    let mut tables = Vec::new();
    for line in enumeration.lines().map(str::trim).filter(|l| !l.is_empty()) {
        let (name, rest) = line
            .split_once(" = ")
            .ok_or_else(|| format!("{CONSTANTS}: table `{line}`"))?;
        let id = rest.split_once(',').map_or(rest, |(id, _)| id).trim();
        let id = id
            .parse()
            .map_err(|_| format!("{CONSTANTS}: table {name} has id `{id}`"))?;
        let what = format!("{OPERATIONS}, {name}");
        let props = between(
            operations,
            &format!("static const OP::OpCodeProperty {name}_OpCodeProps[] = {{"),
            "\n};",
            &what,
        )?;
        let mut table = Table {
            name: name.to_owned(),
            id,
            operations: Vec::new(),
        };
        // each entry is `{OC::<id>, "<name>", OCC::<class>, ...}`
        for entry in props.split("{OC::").skip(1) {
            let mut fields = entry.splitn(4, ',').map(str::trim);
            let (_, quoted, class) = (fields.next(), fields.next(), fields.next());
            let op = quoted
                .and_then(|q| q.strip_prefix('"')?.strip_suffix('"'))
                .ok_or_else(|| {
                    format!(
                        "{what}: an entry with no name: `{}`",
                        entry.lines().next().unwrap_or("")
                    )
                })?;
            let class = class
                .and_then(|c| c.strip_prefix("OCC::"))
                .ok_or_else(|| format!("{what}: {op} has no class"))?;
            let list = match (class, operands.get(op)) {
                ("Reserved", None) => String::new(),
                ("Reserved", Some(_)) => {
                    return Err(format!("{what}: {op} is reserved but has a DxilInst_{op}"));
                }
                (_, Some(list)) => list.join(","),
                (_, None) => return Err(format!("{INSTRUCTIONS}: no DxilInst_{op} for {name}'s {op}")),
            };
            table.operations.push((op.to_owned(), format!("({list})")));
        }
        tables.push(table);
    }
    if tables.is_empty() {
        return Err(format!("{CONSTANTS}: OpCodeTableID lists no tables"));
    }
    Ok(tables)
}

/// Each `DxilInst_<operation>` helper's operands after the opcode, in order (its `OperandIdx`: `arg_<name> = <n>`).
fn operands(instructions: &str) -> Result<BTreeMap<&str, Vec<&str>>, String> {
    let mut all = BTreeMap::new();
    for chunk in instructions.split("\nstruct DxilInst_").skip(1) {
        let (op, body) = chunk
            .split_once(" {")
            .ok_or_else(|| format!("{INSTRUCTIONS}: struct DxilInst_{chunk:.40}"))?;
        let body = &body[..body
            .find("\n};")
            .ok_or_else(|| format!("{INSTRUCTIONS}: DxilInst_{op} does not end"))?];
        let mut list = Vec::new();
        if let Ok(enumeration) = between(body, "enum OperandIdx {", "};", INSTRUCTIONS) {
            for (n, line) in enumeration
                .lines()
                .map(str::trim)
                .filter(|l| !l.is_empty())
                .enumerate()
            {
                let parsed = line
                    .strip_prefix("arg_")
                    .and_then(|l| l.strip_suffix(','))
                    .and_then(|l| l.split_once(" = "))
                    .filter(|(_, index)| *index == (n + 1).to_string());
                let (name, _) = parsed
                    .ok_or_else(|| format!("{INSTRUCTIONS}: DxilInst_{op} operand {}: `{line}`", n + 1))?;
                list.push(name);
            }
        }
        if all.insert(op, list).is_some() {
            return Err(format!("{INSTRUCTIONS}: DxilInst_{op} twice"));
        }
    }
    Ok(all)
}

/// The file's text after its header.
fn render(tables: &[Table]) -> String {
    let mut out = String::from(
        "//! Each table lists, by operation index, the name and the operands (after the opcode) dxc's listing annotates a\n\
         //! call with.\n",
    );
    for table in tables {
        let _ = write!(
            out,
            "\n/// The `{}` table (table id {:#x}, the opcode's upper 16 bits).\n\
             pub(crate) const {}: [(&str, &str); {}] = [\n",
            table.name,
            table.id,
            constant(&table.name),
            table.operations.len()
        );
        for (name, operands) in &table.operations {
            let _ = writeln!(out, "    (\"{name}\", \"{operands}\"),");
        }
        out.push_str("];\n");
    }
    out.push_str(
        "\n/// The name and operands of an encoded opcode (the table id in its upper 16 bits, the index in the lower), where\n\
         /// dxc's tables have it.\n\
         pub(crate) fn operation(opcode: u32) -> Option<(&'static str, &'static str)> {\n    \
             let index = usize::try_from(opcode & 0xFFFF).ok()?;\n    \
             match opcode >> 16 {\n",
    );
    for table in tables {
        let _ = writeln!(
            out,
            "        {:#x} => {}.get(index).copied(),",
            table.id,
            constant(&table.name)
        );
    }
    out.push_str("        _ => None,\n    }\n}\n");
    out
}

/// A table's constant: its name in upper snake case (`CoreOps` as `CORE_OPS`).
fn constant(name: &str) -> String {
    let mut out = String::new();
    for (n, c) in name.chars().enumerate() {
        if c.is_ascii_uppercase() && n > 0 {
            out.push('_');
        }
        out.push(c.to_ascii_uppercase());
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The committed table is what the generator wrote: its body is the one its header records.
    #[test]
    fn the_committed_table_is_as_generated() {
        let text = fs::read_to_string(crate::root().join(OUTPUT)).unwrap();
        generated::verify(&text).unwrap_or_else(|why| panic!("{OUTPUT}: {why}; run `cargo xtask dxil-ops`"));
        assert!(text.contains(&format!("from DirectXShaderCompiler {TAG};")));
    }

    #[test]
    fn tables_come_from_the_three_files() {
        let constants =
            "enum class OpCodeTableID : unsigned {\n  CoreOps = 0, // Core\n  ExtraOps = 32768, // x\n};\n";
        let operations = "static const OP::OpCodeProperty CoreOps_OpCodeProps[] = {\n    {OC::A,\n     \"A\",\n     \
                          OCC::A,\n     \"a\"},\n    {OC::R, \"R\", OCC::Reserved, \"r\"},\n};\n\
                          static const OP::OpCodeProperty ExtraOps_OpCodeProps[] = {\n    {OC::B, \"B\", OCC::B, \"b\"},\n};\n";
        let instructions = "x\nstruct DxilInst_A {\n  enum OperandIdx {\n    arg_srv = 1,\n    arg_coord = 2,\n  };\n};\n\
                            \nstruct DxilInst_B {\n  bool isAllowed() const { return true; }\n};\n";
        let read = tables(constants, operations, instructions).unwrap();
        let listed: Vec<_> = read
            .iter()
            .map(|t| (t.name.as_str(), t.id, t.operations.clone()))
            .collect();
        let pair = |a: &str, b: &str| (a.to_owned(), b.to_owned());
        assert_eq!(
            listed,
            [
                ("CoreOps", 0, vec![pair("A", "(srv,coord)"), pair("R", "()")]),
                ("ExtraOps", 0x8000, vec![pair("B", "()")]),
            ]
        );
        assert!(render(&read).contains("        0x8000 => EXTRA_OPS.get(index).copied(),\n"));
        let missing = instructions.replace("DxilInst_B", "DxilInst_C");
        assert!(
            tables(constants, operations, &missing)
                .unwrap_err()
                .contains("no DxilInst_B")
        );
    }

    #[test]
    fn constants_are_upper_snake_case() {
        assert_eq!(constant("CoreOps"), "CORE_OPS");
        assert_eq!(constant("ExperimentalOps"), "EXPERIMENTAL_OPS");
    }
}
