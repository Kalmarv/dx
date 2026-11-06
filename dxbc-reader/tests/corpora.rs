#![allow(clippy::unwrap_used)]
//! The listings of whole games' programs against Microsoft's, byte for byte: the oracle entries of
//! tests/inputs/mod.rs, each program beside the listings Microsoft's disassembler wrote of it. A test whose entry is
//! not configured skips with a line naming its key.
mod compare;
mod inputs;

use compare::{difference, flag_words, microsofts};
use dxbc_reader::{Options, disassemble_with, parts};
use inputs::{Game, OracleSet};
use std::path::{Path, PathBuf};

/// What one entry's comparison found.
#[derive(Default)]
struct Tally {
    /// Listings compared.
    compared: usize,
    /// Listings of programs with an `SPDB` part, whose annotations the listing does not write, each checked to
    /// differ so that the count cannot go stale.
    debug: usize,
    /// The first differing line of each listing that differs.
    differing: Vec<String>,
}

/// Every container in `folder` against its listings under each of `flags`, found by `listing`.
fn compare(folder: &Path, flags: &[u32], listing: impl Fn(&Path, u32) -> PathBuf) -> Tally {
    let mut containers: Vec<PathBuf> = std::fs::read_dir(folder)
        .unwrap()
        .map(|entry| entry.unwrap().path())
        .filter(|p| std::fs::read(p).is_ok_and(|b| b.starts_with(b"DXBC")))
        .collect();
    containers.sort();
    let mut tally = Tally::default();
    for container in &containers {
        let bytes = std::fs::read(container).unwrap();
        let debug = parts(&bytes).unwrap().iter().any(|c| &c.kind == b"SPDB");
        for &word in flags {
            let path = listing(container, word);
            let theirs =
                microsofts(&std::fs::read(&path).unwrap_or_else(|e| panic!("{}: {e}", path.display())));
            let ours = disassemble_with(&bytes, &Options::from_flags(word).unwrap()).unwrap();
            let what = format!("{} flags 0x{word:02x}", container.display());
            if debug && word & 0x10 == 0 {
                assert_ne!(ours, theirs, "{what} now matches: count it with the others");
                tally.debug += 1;
                continue;
            }
            tally.compared += 1;
            tally.differing.extend(difference(&what, &ours, &theirs));
        }
    }
    assert!(
        tally.differing.is_empty(),
        "{} of {} listings differ:\n{}",
        tally.differing.len(),
        tally.compared,
        tally.differing.join("\n")
    );
    tally
}

/// `NAME.EXT.asm` with no flags, `NAME.EXT.flagNN.asm` with flags.
fn beside(program: &Path, flags: u32) -> PathBuf {
    let mut name = program.as_os_str().to_owned();
    if flags == 0 {
        name.push(".asm");
    } else {
        name.push(format!(".flag{flags:02x}.asm"));
    }
    PathBuf::from(name)
}

#[test]
fn riders_republic_shader_pack() {
    let Some(folder) = inputs::oracle(OracleSet::D3dDisassembler, Game::Riders, "shader-pack") else {
        return;
    };
    let tally = compare(&folder, &[0], |program, _| program.with_extension("txt"));
    assert_eq!((tally.compared, tally.debug), (2443, 0));
}

#[test]
fn sekiro_programs_under_every_flags_word() {
    let Some(folder) = inputs::oracle(OracleSet::D3dDisassembler, Game::Sekiro, "programs") else {
        return;
    };
    let tally = compare(&folder, &flag_words(), beside);
    // 432 programs, each with 23 listings
    assert_eq!((tally.compared, tally.debug), (9936, 0));
}

#[test]
fn sledding_game_unity_player() {
    let Some(folder) = inputs::oracle(OracleSet::D3dDisassembler, Game::Sledding, "corpus-unity") else {
        return;
    };
    let tally = compare(&folder, &[0], beside);
    // 3,316 ps_4_0 and 1,538 ps_5_0 programs, 16 of them with an SPDB part
    assert_eq!((tally.compared, tally.debug), (4838, 16));
}
