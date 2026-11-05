#![allow(clippy::unwrap_used)]
//! The listings of `disassemble_with` against Microsoft's own, byte for byte: `tests/disasm/listings` holds
//! `D3DDisassemble`'s listing of every program in `tests/disasm` (built from the HLSL there by `generate.py`), with
//! no flags (`NAME.asm`) and with each flag Microsoft's disassembler accepts but the HTML one (`NAME.flagNN.asm`).
use d3d9_reader::{Options, disassemble_with};
use std::path::Path;

const FLAGS: [u32; 7] = [0, 0x02, 0x04, 0x10, 0x20, 0x40, 0x80];

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
    let mut compared = 0;
    for (program, flags) in programs.iter().flat_map(|p| FLAGS.map(|f| (p, f))) {
        let stem = program.file_stem().unwrap().to_str().unwrap();
        let name = if flags == 0 {
            format!("{stem}.asm")
        } else {
            format!("{stem}.flag{flags:02x}.asm")
        };
        let theirs = std::fs::read_to_string(here.join("listings").join(name)).unwrap();
        let ours = disassemble_with(
            &std::fs::read(program).unwrap(),
            &Options::from_flags(flags).unwrap(),
        )
        .unwrap();
        compared += 1;
        if ours != theirs {
            let line = ours
                .lines()
                .zip(theirs.lines())
                .position(|(a, b)| a != b)
                .unwrap_or(0);
            differing.push(format!(
                "{stem} flags 0x{flags:02x} line {}:\n  dx: {:?}\n  ms: {:?}",
                line + 1,
                ours.lines().nth(line).unwrap_or(""),
                theirs.lines().nth(line).unwrap_or("")
            ));
        }
    }
    assert!(
        differing.is_empty(),
        "{} of {compared} listings differ:\n{}",
        differing.len(),
        differing.join("\n")
    );
    // 26 vs_2_0, vs_2_a, vs_3_0, ps_2_0, ps_2_a, ps_2_b and ps_3_0 programs, each with seven listings
    assert_eq!(compared, 182);
}
