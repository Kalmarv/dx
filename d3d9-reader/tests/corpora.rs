#![allow(clippy::unwrap_used)]
//! The listings of a whole game's Direct3D 9 programs against Microsoft's, byte for byte: the oracle entries of
//! tests/inputs/mod.rs, each program beside the listing Microsoft's disassembler wrote of it with no flags. A test
//! whose entry is not configured skips with a line naming its key.
mod compare;
mod inputs;

use compare::{difference, microsofts};
use d3d9_reader::disassemble;
use inputs::{Game, OracleSet};
use std::path::{Path, PathBuf};

/// Every program in `folder` (each file but the listings) against the listing `listing` names; the number compared.
fn compare(folder: &Path, listing: impl Fn(&Path) -> PathBuf) -> usize {
    let mut programs: Vec<PathBuf> = std::fs::read_dir(folder)
        .unwrap()
        .map(|entry| entry.unwrap().path())
        .filter(|p| p.extension().is_none_or(|e| e != "asm"))
        .collect();
    programs.sort();
    let mut differing = Vec::new();
    for program in &programs {
        let path = listing(program);
        let theirs = microsofts(&std::fs::read(&path).unwrap_or_else(|e| panic!("{}: {e}", path.display())));
        let ours = disassemble(&std::fs::read(program).unwrap()).unwrap();
        differing.extend(difference(&program.display().to_string(), &ours, &theirs));
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
    let Some(folder) = inputs::oracle(OracleSet::D3dDisassembler, Game::ShaunWhite, "sdb2") else {
        return;
    };
    let beside = |program: &Path| {
        let mut name = program.as_os_str().to_owned();
        name.push(".asm");
        PathBuf::from(name)
    };
    // 6,207 ps_3_0 and 1,099 vs_3_0 programs
    assert_eq!(compare(&folder, beside), 7306);
}

#[test]
fn general_sm3_programs() {
    let Some(folder) = inputs::oracle(OracleSet::D3dDisassembler, Game::General, "sm3") else {
        return;
    };
    assert_eq!(compare(&folder, |program| program.with_extension("asm")), 3);
}
