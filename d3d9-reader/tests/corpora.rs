#![allow(clippy::unwrap_used)]
//! The listings of a whole game's Direct3D 9 programs against Microsoft's, byte for byte: the oracle entries of
//! tests/inputs/mod.rs, each program beside the listing Microsoft's disassembler wrote of it with no flags, read as a
//! tree of files whether the store holds the entry as a folder or as one archive. A test whose entry is not configured
//! skips with a line naming its key.
mod compare;
mod inputs;

use compare::{difference, microsofts};
use d3d9_reader::disassemble;
use inputs::{Game, OracleSet};
use primase_testdata::Tree;

/// Every program of `tree` (each file but the listings) against the listing `listing` names; the number compared.
fn compare(tree: &Tree, listing: impl Fn(&str) -> String) -> usize {
    let programs: Vec<&str> = tree
        .names()
        .into_iter()
        .filter(|n| !n.ends_with(".asm"))
        .collect();
    let mut differing = Vec::new();
    for program in &programs {
        let read = |name: &str| tree.read(name).unwrap_or_else(|e| panic!("{name}: {e}"));
        let theirs = microsofts(&read(&listing(program)));
        match disassemble(&read(program)) {
            Ok(ours) => differing.extend(difference(program, &ours, &theirs)),
            Err(e) => differing.push(format!("{program}: refused: {e}")),
        }
    }
    assert!(
        differing.is_empty(),
        "{} of {} listings differ:\n{}",
        differing.len(),
        programs.len(),
        differing.join("\n")
    );
    programs.len()
}

#[test]
fn shaun_white_sdb2_programs() {
    let Some(tree) = inputs::oracle_tree(OracleSet::D3dDisassembler, Game::ShaunWhite, "sdb2") else {
        return;
    };
    // 6,207 ps_3_0 and 1,099 vs_3_0 programs, each with `NAME.asm` beside it
    assert_eq!(compare(&tree, |program| format!("{program}.asm")), 7306);
}

#[test]
fn general_sm3_programs() {
    let Some(tree) = inputs::oracle_tree(OracleSet::D3dDisassembler, Game::General, "sm3") else {
        return;
    };
    // `NAME.asm` beside `NAME.EXT`
    let listing = |program: &str| {
        let stem = program.rsplit_once('.').map_or(program, |(stem, _)| stem);
        format!("{stem}.asm")
    };
    assert_eq!(compare(&tree, listing), 3);
}
