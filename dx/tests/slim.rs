#![allow(clippy::unwrap_used)]
//! The slim shader set (tests/inputs/mod.rs) through what `dx` does with a program: its listing against Microsoft's,
//! byte for byte (`dx disasm --check`), and its `dx reflect` and `dx info` JSON. The set reaches every region and
//! branch side of the readers that the full pool of programs does, so this is the run before every push to main
//! (CONTRIBUTING.md). A program Microsoft's tools refuse (`microsoft-refused.tsv`) has no listing to compare and dx
//! must still read it without a panic, as it must the malformed Direct3D 9 programs it refuses ([`REFUSED`]). Each
//! family is one test, its programs read on `primase_testdata::threads()` threads from an archive and on one from a
//! folder ([`workers`]); a failure lists every program that failed, in name order.
mod inputs;

use std::collections::BTreeSet;
use std::panic::catch_unwind;
use std::sync::OnceLock;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::Instant;

use dx::check::{Outcome, compare, microsofts};
use dx::reflect::{info, reflect};
use inputs::{Game, OracleSet};
use primase_testdata::Tree;

/// The Direct3D 9 programs of the set that Microsoft lists and dx refuses as malformed (from wine's and vkd3d's tests
/// of malformed input), by their names, each with the start of the refusal dx must give.
const REFUSED: [(&str, &str); 4] = [
    (
        "0832613147876a56b0971ad801f911e08b408bd3244e516c94cabf5201c883b8.d3d9",
        "D3D9 at word 0: version token 0xffff02fe is not",
    ),
    (
        "6b7a521c96fb3da4fbe4d0a132f8055b393aba5a770c5da317729fdcc6087452.d3d9",
        "D3D9 at word 84: opcode 43776 is not",
    ),
    (
        "a2e41783507134be3f998a6e697f2dc950e9b824ffda64a32dfdc2e6ca6312fd.d3d9",
        "D3D9 at word 86: instruction token 0x80000005 sets reserved bit",
    ),
    (
        "ade98b606e90e5e19680a2138ae384884f577b694c52923fa02bd8dac7cb3761.d3d9",
        "D3D9 at word 1: opcode 49 is not",
    ),
];

/// What became of one program.
enum Verdict {
    /// Its listing is Microsoft's and its reflection and info were written.
    Identical,
    /// A program of [`REFUSED`], refused as it must be.
    Refused,
    /// A program Microsoft's tools refuse, read without a panic.
    Unlisted,
    /// Anything else, with what went wrong.
    Failed(String),
}

/// The counts of one family's run.
#[derive(Debug, Default, PartialEq, Eq)]
struct Counts {
    identical: usize,
    refused: usize,
    unlisted: usize,
}

/// The slim set as a tree of files, opened once for the tests of this file; `None` (after a line naming its key) when
/// it is not configured.
fn slim() -> Option<&'static Tree> {
    static SLIM: OnceLock<Option<Tree>> = OnceLock::new();
    SLIM.get_or_init(|| inputs::oracle_tree(OracleSet::Corpus, Game::General, "slim"))
        .as_ref()
}

/// One program, the file `name` of the set, against Microsoft's listing `listing` of it (`None` for a program
/// Microsoft's tools refuse).
fn one(set: &Tree, name: &str, listing: Option<&str>) -> Verdict {
    let read = |name: &str| set.read(name).map_err(|e| format!("{name}: {e}"));
    let (bytes, theirs) = match (read(name), listing.map(read).transpose()) {
        (Ok(bytes), Ok(theirs)) => (bytes, theirs.map(|t| microsofts(&t))),
        (Err(e), _) | (_, Err(e)) => return Verdict::Failed(e),
    };
    // what dx makes of the program; a panic in any of it is the failure
    let made = catch_unwind(|| {
        let outcome = theirs.as_deref().map(|t| compare(&bytes, t, 0));
        (outcome, reflect(&bytes), info(&bytes))
    });
    let Ok((outcome, reflected, contained)) = made else {
        return Verdict::Failed(format!("{name}: dx panicked"));
    };
    let file = name.rsplit('/').next().unwrap_or(name);
    let refusal = REFUSED.iter().find(|(n, _)| *n == file).map(|(_, r)| *r);
    match (outcome, refusal) {
        (None, _) => Verdict::Unlisted,
        (Some(Outcome::Failed(e)), Some(r)) if e.starts_with(r) => Verdict::Refused,
        (Some(Outcome::Failed(e)), Some(r)) => {
            Verdict::Failed(format!("{name}: refused with {e:?}, not {r:?}"))
        }
        (Some(outcome), Some(r)) => {
            Verdict::Failed(format!("{name}: read ({outcome:?}), not refused with {r:?}"))
        }
        (Some(Outcome::Failed(e)), None) => Verdict::Failed(format!("{name}: refused: {e}")),
        (Some(Outcome::Differing { line, ours, theirs }), None) => {
            Verdict::Failed(format!("{name} line {line}:\n  dx: {ours:?}\n  ms: {theirs:?}"))
        }
        (Some(Outcome::Identical), None) => match (reflected, contained) {
            (Ok(_), Ok(_)) => Verdict::Identical,
            (Err(e), _) => Verdict::Failed(format!("{name}: dx reflect: {e}")),
            (_, Err(e)) => Verdict::Failed(format!("{name}: dx info: {e}")),
        },
    }
}

/// The programs Microsoft's tools refuse, by their paths in the set (`programs/d3d9/<sha256>.d3d9`).
fn microsoft_refused(set: &Tree) -> BTreeSet<String> {
    let text = set.read("microsoft-refused.tsv").unwrap();
    String::from_utf8(text)
        .unwrap()
        .lines()
        .skip(1)
        .filter_map(|l| l.split('\t').next())
        .map(str::to_owned)
        .collect()
}

/// The threads that read `set`: `primase_testdata::threads()` for an archive, one positional read after another of a
/// single open file; one for a folder, whose files opened at once on several threads over the NAS's SMB share fail at random with Windows error 1450
/// (`ERROR_NO_SYSTEM_RESOURCES`), where one at a time they do not.
fn workers(set: &Tree) -> usize {
    if set.as_folder().is_some() {
        1
    } else {
        primase_testdata::threads().get()
    }
}

/// Every program of the family `family` (`programs/<family>/*.<family>`), its Microsoft listing `NAME.<ending>`
/// beside it; the counts, after failing on any program that failed.
fn family(family: &str, ending: &str) -> Option<Counts> {
    let set = slim()?;
    let started = Instant::now();
    let refused = microsoft_refused(set);
    let folder = format!("programs/{family}/");
    let names: Vec<&str> = set
        .names()
        .into_iter()
        .filter(|n| n.starts_with(&folder) && n.ends_with(&format!(".{family}")))
        .collect();
    let next = AtomicUsize::new(0);
    let mut results: Vec<(usize, Verdict)> = std::thread::scope(|scope| {
        let workers: Vec<_> = (0..workers(set))
            .map(|_| {
                scope.spawn(|| {
                    let mut out = Vec::new();
                    loop {
                        let at = next.fetch_add(1, Ordering::Relaxed);
                        let Some(name) = names.get(at) else {
                            break;
                        };
                        let listing = (!refused.contains(*name)).then(|| format!("{name}.{ending}"));
                        out.push((at, one(set, name, listing.as_deref())));
                    }
                    out
                })
            })
            .collect();
        workers.into_iter().flat_map(|w| w.join().unwrap()).collect()
    });
    results.sort_by_key(|(n, _)| *n);
    let mut counts = Counts::default();
    let mut failures = Vec::new();
    for (_, result) in results {
        match result {
            Verdict::Identical => counts.identical += 1,
            Verdict::Refused => counts.refused += 1,
            Verdict::Unlisted => counts.unlisted += 1,
            Verdict::Failed(f) => failures.push(f),
        }
    }
    assert!(
        failures.is_empty(),
        "{} of {} {family} programs failed:\n{}",
        failures.len(),
        names.len(),
        failures.join("\n")
    );
    println!(
        "slim {family}: {} programs, {} identical, 0 differing, {} refused as malformed, {} without a Microsoft listing \
         ({:.1} s)",
        names.len(),
        counts.identical,
        counts.refused,
        counts.unlisted,
        started.elapsed().as_secs_f64()
    );
    Some(counts)
}

#[test]
fn slim_d3d9() {
    let Some(counts) = family("d3d9", "asm") else {
        return;
    };
    assert_eq!(
        counts,
        Counts {
            identical: 548,
            refused: 4,
            unlisted: 5
        }
    );
}

#[test]
fn slim_dxbc() {
    let Some(counts) = family("dxbc", "asm") else {
        return;
    };
    assert_eq!(
        counts,
        Counts {
            identical: 3670,
            refused: 0,
            unlisted: 1
        }
    );
}

#[test]
fn slim_dxil() {
    let Some(counts) = family("dxil", "txt") else {
        return;
    };
    assert_eq!(
        counts,
        Counts {
            identical: 4055,
            refused: 0,
            unlisted: 4
        }
    );
}

/// Every file of the set is a program of one of the three families, Microsoft's listing of one, or one of the two
/// tables: a file of another kind would go unread.
#[test]
fn slim_files() {
    let Some(set) = slim() else {
        return;
    };
    let names = set.names();
    let others: Vec<&&str> = names
        .iter()
        .filter(|n| {
            !["slim.tsv", "microsoft-refused.tsv"].contains(n)
                && ![("d3d9", ".asm"), ("dxbc", ".asm"), ("dxil", ".txt")]
                    .iter()
                    .any(|(family, ending)| {
                        n.strip_prefix(&format!("programs/{family}/"))
                            .is_some_and(|file| {
                                let program = file.strip_suffix(ending).unwrap_or(file);
                                program.ends_with(&format!(".{family}")) && !program.contains('/')
                            })
                    })
        })
        .collect();
    assert!(others.is_empty(), "files of no family: {others:?}");
    assert_eq!(names.len(), 16_566);
}
