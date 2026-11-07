#![allow(clippy::unwrap_used)]
//! The listings of whole games' programs against Microsoft's, byte for byte: the oracle entries of
//! tests/inputs/mod.rs, each program beside the listings Microsoft's disassembler wrote of it, read as a tree of files
//! whether the store holds the entry as a folder or as one archive. A test whose entry is not configured skips with a
//! line naming its key. The programs are compared on `primase_testdata::threads()` threads, a folder's files read one
//! at a time ([`read`]), and the listings that differ are listed in name order.
mod compare;
mod inputs;

use compare::{difference, flag_words, microsofts};
use dxbc_reader::{Options, disassemble_with, parts};
use inputs::{Game, OracleSet};
use primase_testdata::Tree;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Mutex, PoisonError};

/// Held while a file of a folder is read, by every thread of every test here.
static FOLDER_READS: Mutex<()> = Mutex::new(());

/// The file `name` of `tree`, from any thread: an archive's files are read at once, each a positional read of its one
/// open file; a folder's one at a time ([`FOLDER_READS`]), because on the desktop's SMB share files opened at once on
/// several threads failed at random with Windows error 1450 (`ERROR_NO_SYSTEM_RESOURCES`), where one at a time they
/// do not.
fn read(tree: &Tree, name: &str) -> std::io::Result<Vec<u8>> {
    let _turn = tree
        .as_folder()
        .map(|_| FOLDER_READS.lock().unwrap_or_else(PoisonError::into_inner));
    tree.read(name)
}

/// What one entry's comparison found.
#[derive(Default)]
struct Tally {
    /// Listings compared.
    compared: usize,
    /// Of them, listings of programs with an `SPDB` part (the PDB `fxc /Zi` embeds) written with its annotations.
    debug: usize,
    /// The first differing line of each listing that differs, and each refusal.
    differing: Vec<String>,
}

/// One program, the file `name` of `tree`, against its listings under each of `flags`, named by `listing`.
fn one(tree: &Tree, name: &str, flags: &[u32], listing: &impl Fn(&str, u32) -> String) -> Tally {
    let mut tally = Tally::default();
    let bytes = match read(tree, name) {
        Ok(bytes) => bytes,
        Err(e) => {
            tally.differing.push(format!("{name}: {e}"));
            return tally;
        }
    };
    let debug = parts(&bytes).unwrap().iter().any(|c| &c.kind == b"SPDB");
    for &word in flags {
        let what = format!("{name} flags 0x{word:02x}");
        let theirs = match read(tree, &listing(name, word)) {
            Ok(theirs) => microsofts(&theirs),
            Err(e) => {
                tally.differing.push(format!("{what}: {e}"));
                continue;
            }
        };
        if debug && word & 0x10 == 0 {
            tally.debug += 1;
        }
        tally.compared += 1;
        match disassemble_with(&bytes, &Options::from_flags(word).unwrap()) {
            Ok(ours) => tally.differing.extend(difference(&what, &ours, &theirs)),
            Err(e) => tally.differing.push(format!("{what}: refused: {e}")),
        }
    }
    tally
}

/// Every program of `tree`, the files with one of the extensions `programs`, against its listings under each of
/// `flags`, named by `listing`. The programs are told by their names, not by opening every file of a set that holds
/// far more listings than programs.
fn compare(
    tree: &Tree,
    programs: &[&str],
    flags: &[u32],
    listing: impl Fn(&str, u32) -> String + Sync,
) -> Tally {
    let names: Vec<&str> = tree
        .names()
        .into_iter()
        .filter(|n| n.rsplit_once('.').is_some_and(|(_, e)| programs.contains(&e)))
        .collect();
    let next = AtomicUsize::new(0);
    let mut tallies: Vec<(usize, Tally)> = std::thread::scope(|scope| {
        let workers: Vec<_> = (0..primase_testdata::threads().get())
            .map(|_| {
                scope.spawn(|| {
                    let mut done = Vec::new();
                    loop {
                        let at = next.fetch_add(1, Ordering::Relaxed);
                        let Some(name) = names.get(at) else {
                            break;
                        };
                        done.push((at, one(tree, name, flags, &listing)));
                    }
                    done
                })
            })
            .collect();
        workers.into_iter().flat_map(|w| w.join().unwrap()).collect()
    });
    tallies.sort_by_key(|(at, _)| *at);
    let mut tally = Tally::default();
    for (_, t) in tallies {
        tally.compared += t.compared;
        tally.debug += t.debug;
        tally.differing.extend(t.differing);
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
fn beside(program: &str, flags: u32) -> String {
    if flags == 0 {
        format!("{program}.asm")
    } else {
        format!("{program}.flag{flags:02x}.asm")
    }
}

#[test]
fn riders_republic_shader_pack() {
    let Some(tree) = inputs::oracle_tree(OracleSet::D3dDisassembler, Game::Riders, "shader-pack") else {
        return;
    };
    // `NNNN.txt` beside `NNNN.dxbc`
    let tally = compare(&tree, &["dxbc"], &[0], |program, _| {
        format!("{}.txt", program.strip_suffix(".dxbc").unwrap())
    });
    assert_eq!((tally.compared, tally.debug), (2443, 0));
}

#[test]
fn sekiro_programs_under_every_flags_word() {
    let Some(tree) = inputs::oracle_tree(OracleSet::D3dDisassembler, Game::Sekiro, "programs") else {
        return;
    };
    let tally = compare(&tree, &["ppo", "vpo"], &flag_words(), beside);
    // 432 programs, each with 23 listings
    assert_eq!((tally.compared, tally.debug), (9936, 0));
}

#[test]
fn sledding_game_unity_player() {
    let Some(tree) = inputs::oracle_tree(OracleSet::D3dDisassembler, Game::Sledding, "corpus-unity") else {
        return;
    };
    let tally = compare(&tree, &["dxbc"], &[0], beside);
    // 3,316 ps_4_0 and 1,538 ps_5_0 programs, 16 of them with an SPDB part
    assert_eq!((tally.compared, tally.debug), (4854, 16));
}

#[test]
fn fxc_sweep_zi_under_every_flags_word() {
    let Some(tree) = inputs::oracle_tree(OracleSet::D3dDisassembler, Game::General, "fxc-sweep-zi") else {
        return;
    };
    let tally = compare(&tree, &["dxbc"], &flag_words(), beside);
    // 4,613 programs, each with 23 listings, 16 of them with the SPDB part's annotations
    assert_eq!((tally.compared, tally.debug), (106_099, 73_808));
}

#[test]
fn fxc_sweep_zod_under_every_flags_word() {
    let Some(tree) = inputs::oracle_tree(OracleSet::D3dDisassembler, Game::General, "fxc-sweep-zod") else {
        return;
    };
    let tally = compare(&tree, &["dxbc"], &flag_words(), beside);
    // 4,614 programs
    assert_eq!((tally.compared, tally.debug), (106_122, 73_824));
}
