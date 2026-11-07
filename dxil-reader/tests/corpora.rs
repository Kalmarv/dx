#![allow(clippy::unwrap_used)]
//! The listing of a whole game's DXIL programs against dxc 1.9.2609's `-dumpbin`, byte for byte: the programs of one
//! oracle entry, each against its listing in another (`<path>.txt`, the same path below it), each entry read as a tree
//! of files whether the store holds it as a folder or as one archive. A test whose entries are not configured skips
//! with a line naming the key; a program without its listing fails, as one that differs or that the disassembler
//! refuses does. The programs are compared on `primase_testdata::threads()` threads when both entries are archives, on
//! one when either is a folder ([`workers`]), and the failures are listed in path order whatever their number.
mod inputs;

use inputs::{Game, OracleSet};
use primase_testdata::Tree;
use std::collections::BTreeMap;
use std::sync::atomic::{AtomicUsize, Ordering};

/// The extensions of Elden Ring's programs, one a stage: compute (and the libraries), domain, geometry, hull, pixel
/// and vertex. The counts the test asserts take in every program, so a file this misses fails it.
const EXTENSIONS: [&str; 6] = ["cpo", "dpo", "gpo", "hpo", "ppo", "vpo"];

/// The threads that read `corpus` and `listings`: `primase_testdata::threads()` when both are archives, each read
/// with positional reads of a single open file; one when either is a folder, whose files opened at once on several threads over the NAS's SMB share fail at random with Windows error 1450
/// (`ERROR_NO_SYSTEM_RESOURCES`), where one at a time they do not.
fn workers(corpus: &Tree, listings: &Tree) -> usize {
    if corpus.as_folder().is_some() || listings.as_folder().is_some() {
        1
    } else {
        primase_testdata::threads().get()
    }
}

/// One program, the file `name` of `corpus`, against its listing in `listings`: its target when the two are the same,
/// otherwise the failure's line.
fn compare(corpus: &Tree, listings: &Tree, name: &str) -> Result<String, String> {
    let bytes = corpus.read(name).unwrap();
    let target = dxil_reader::part(&bytes)
        .ok()
        .and_then(|p| p.target())
        .unwrap_or_else(|| "unknown".to_owned());
    let theirs = match listings.read(&format!("{name}.txt")) {
        Ok(theirs) => theirs,
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Err(format!("{name}: no listing")),
        Err(e) => return Err(format!("{name}: {e}")),
    };
    let theirs = String::from_utf8_lossy(&theirs);
    match dxil_reader::disasm::disassemble(&bytes) {
        Err(e) => Err(format!("{name} ({target}): refused: {e}")),
        Ok(ours) if ours == theirs => Ok(target),
        Ok(ours) => {
            let line = ours
                .lines()
                .zip(theirs.lines())
                .position(|(a, b)| a != b)
                .unwrap_or(0);
            Err(format!(
                "{name} ({target}) line {}:\n  dx:  {:?}\n  dxc: {:?}",
                line + 1,
                ours.lines().nth(line).unwrap_or(""),
                theirs.lines().nth(line).unwrap_or("")
            ))
        }
    }
}

#[test]
fn elden_ring_programs() {
    let Some(corpus) = inputs::oracle_tree(OracleSet::Corpus, Game::Elden, "shaders") else {
        return;
    };
    let Some(listings) = inputs::oracle_tree(OracleSet::Dxc, Game::Elden, "shader-listings") else {
        return;
    };
    let found: Vec<&str> = corpus
        .names()
        .into_iter()
        .filter(|n| n.rsplit_once('.').is_some_and(|(_, e)| EXTENSIONS.contains(&e)))
        .collect();
    let next = AtomicUsize::new(0);
    let mut outcomes: Vec<(usize, Result<String, String>)> = std::thread::scope(|s| {
        let workers: Vec<_> = (0..workers(&corpus, &listings))
            .map(|_| {
                s.spawn(|| {
                    let mut done = Vec::new();
                    loop {
                        let at = next.fetch_add(1, Ordering::Relaxed);
                        let Some(name) = found.get(at) else {
                            break;
                        };
                        done.push((at, compare(&corpus, &listings, name)));
                    }
                    done
                })
            })
            .collect();
        workers.into_iter().flat_map(|w| w.join().unwrap()).collect()
    });
    outcomes.sort_by_key(|(at, _)| *at);
    let mut identical: BTreeMap<String, usize> = BTreeMap::new();
    let mut failures = Vec::new();
    for (_, outcome) in outcomes {
        match outcome {
            Ok(target) => *identical.entry(target).or_default() += 1,
            Err(failure) => failures.push(failure),
        }
    }
    assert!(
        failures.is_empty(),
        "{} of {} programs:\n{}",
        failures.len(),
        found.len(),
        failures.join("\n")
    );
    let counts: Vec<(&str, usize)> = identical.iter().map(|(t, n)| (t.as_str(), *n)).collect();
    assert_eq!(
        counts,
        [
            ("cs_6_0", 1731),
            ("ds_6_0", 150),
            ("gs_6_0", 33),
            ("hs_6_0", 136),
            ("lib_6_3", 4281),
            ("ps_6_0", 25183),
            ("vs_6_0", 18769),
        ]
    );
}
