#![allow(clippy::unwrap_used)]
//! The listings of programs Microsoft's `D3DAssemble` assembled, against `D3DDisassemble`'s, byte for byte: every
//! Shader Model 1 to 3 operation alone (the `slots_` programs, which pin each one's instruction slots in each version),
//! the one-feature programs of iridia-d3d9-ir's executor tests, and the cases Microsoft's listing writes oddly
//! (`probe_`: predication, `breakp`). `tests/assembled/assemble.py` makes the `.bin`, `.asm.ms` (no flags) and
//! `.flag04.ms` (instruction numbering) files from the `.asm` sources.
mod compare;

use compare::{difference, microsofts};
use d3d9_reader::{Options, disassemble_with};
use std::path::Path;

#[test]
fn assembled_programs_list_as_microsofts_disassembler_lists_them() {
    let here = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/assembled");
    let mut programs: Vec<_> = std::fs::read_dir(&here)
        .unwrap()
        .map(|entry| entry.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "bin"))
        .collect();
    programs.sort();
    let mut differing = Vec::new();
    let mut compared = 0;
    for program in &programs {
        let stem = program.file_stem().unwrap().to_str().unwrap();
        let bytes = std::fs::read(program).unwrap();
        for (flags, ending) in [(0u32, "asm.ms"), (0x04, "flag04.ms")] {
            let theirs = microsofts(&std::fs::read(here.join(format!("{stem}.{ending}"))).unwrap());
            let ours = disassemble_with(&bytes, &Options::from_flags(flags).unwrap()).unwrap();
            compared += 1;
            differing.extend(difference(&format!("{stem} flags 0x{flags:02x}"), &ours, &theirs));
        }
    }
    assert!(
        differing.is_empty(),
        "{} of {compared} listings differ:\n{}",
        differing.len(),
        differing.join("\n")
    );
    // 287 programs, each with two listings
    assert_eq!(compared, 574);
}
