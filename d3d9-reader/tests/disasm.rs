#![allow(clippy::unwrap_used)]
//! The listings of `disassemble_with` against Microsoft's own, byte for byte: `tests/disasm/listings` holds
//! `D3DDisassemble`'s listing of every program in `tests/disasm` (built from the HLSL there, or the tokens of a Shader
//! Model 1 program, by `generate.py`), with no flags (`NAME.asm`) and with the flags that change the text alone, in
//! pairs and all together (`NAME.flagNN.asm`).
mod compare;

use compare::{difference, flag_words};
use d3d9_reader::{Options, disassemble_with};
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
    let mut compared = 0;
    for (program, flags) in programs
        .iter()
        .flat_map(|p| flag_words().into_iter().map(move |f| (p, f)))
    {
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
        differing.extend(difference(&format!("{stem} flags 0x{flags:02x}"), &ours, &theirs));
    }
    assert!(
        differing.is_empty(),
        "{} of {compared} listings differ:\n{}",
        differing.len(),
        differing.join("\n")
    );
    // 36 vs_2_0, vs_2_a, vs_3_0, ps_2_0, ps_2_a, ps_2_b and ps_3_0 programs (10 of them /Zi builds) and 8 vs_1_1 and
    // ps_1_1 to ps_1_4 ones, each with 23 listings
    assert_eq!(compared, 1012);
}
