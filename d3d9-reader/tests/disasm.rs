#![allow(clippy::unwrap_used)]
//! The listings of `disassemble` against Microsoft's own, byte for byte: `tests/disasm/listings` holds
//! `D3DDisassemble`'s listing of every program in `tests/disasm` (built from the HLSL there by `generate.py`).
use d3d9_reader::disassemble;
use std::path::Path;

#[test]
fn listings_are_microsofts() {
    let here = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/disasm");
    let mut programs: Vec<_> = std::fs::read_dir(&here)
        .unwrap()
        .map(|entry| entry.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "bin"))
        .collect();
    programs.sort();
    let mut differing = Vec::new();
    for program in &programs {
        let stem = program.file_stem().unwrap().to_str().unwrap();
        let theirs = std::fs::read_to_string(here.join("listings").join(format!("{stem}.asm"))).unwrap();
        let ours = disassemble(&std::fs::read(program).unwrap()).unwrap();
        if ours != theirs {
            let line = ours
                .lines()
                .zip(theirs.lines())
                .position(|(a, b)| a != b)
                .unwrap_or(0);
            differing.push(format!(
                "{stem} line {}:\n  dx: {:?}\n  ms: {:?}",
                line + 1,
                ours.lines().nth(line).unwrap_or(""),
                theirs.lines().nth(line).unwrap_or("")
            ));
        }
    }
    assert!(
        differing.is_empty(),
        "{} of {} listings differ:\n{}",
        differing.len(),
        programs.len(),
        differing.join("\n")
    );
    // vs_2_0, vs_2_a, vs_3_0, ps_2_0, ps_2_a, ps_2_b and ps_3_0 programs
    assert_eq!(programs.len(), 25);
}
