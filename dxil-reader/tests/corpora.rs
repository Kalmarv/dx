#![allow(clippy::unwrap_used)]
//! The listing of a whole game's DXIL programs against dxc 1.9.2609's `-dumpbin`, byte for byte: the programs of one
//! oracle entry, each against its listing in another (`<path>.txt`, the same path below it). A test whose entries are
//! not configured skips with a line naming the key; a program without its listing fails, as one that differs or that
//! the disassembler refuses does. The programs are compared on `primase_testdata::threads()` threads, and the failures
//! are listed in path order whatever their number.
mod inputs;

use inputs::{Game, OracleSet};
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicUsize, Ordering};

/// The extensions of Elden Ring's programs, one a stage: compute (and the libraries), domain, geometry, hull, pixel
/// and vertex. The counts the test asserts take in every program, so a file this misses fails it.
const EXTENSIONS: [&str; 6] = ["cpo", "dpo", "gpo", "hpo", "ppo", "vpo"];

fn programs(dir: &Path, out: &mut Vec<PathBuf>) {
    let mut entries: Vec<PathBuf> = std::fs::read_dir(dir)
        .unwrap()
        .map(|e| e.unwrap().path())
        .collect();
    entries.sort();
    for p in entries {
        if p.is_dir() {
            programs(&p, out);
        } else if p
            .extension()
            .and_then(|e| e.to_str())
            .is_some_and(|e| EXTENSIONS.contains(&e))
        {
            out.push(p);
        }
    }
}

/// One program against its listing: its target when the two are the same, otherwise the failure's line.
fn compare(corpus: &Path, listings: &Path, program: &Path) -> Result<String, String> {
    let rel = program.strip_prefix(corpus).unwrap();
    let mut listing = listings.join(rel).into_os_string();
    listing.push(".txt");
    let bytes = std::fs::read(program).unwrap();
    let target = dxil_reader::part(&bytes)
        .ok()
        .and_then(|p| p.target())
        .unwrap_or_else(|| "unknown".to_owned());
    let Ok(theirs) = std::fs::read_to_string(&listing) else {
        return Err(format!("{}: no listing", rel.display()));
    };
    match dxil_reader::disasm::disassemble(&bytes) {
        Err(e) => Err(format!("{} ({target}): refused: {e}", rel.display())),
        Ok(ours) if ours == theirs => Ok(target),
        Ok(ours) => {
            let line = ours
                .lines()
                .zip(theirs.lines())
                .position(|(a, b)| a != b)
                .unwrap_or(0);
            Err(format!(
                "{} ({target}) line {}:
  dx:  {:?}
  dxc: {:?}",
                rel.display(),
                line + 1,
                ours.lines().nth(line).unwrap_or(""),
                theirs.lines().nth(line).unwrap_or("")
            ))
        }
    }
}

#[test]
fn elden_ring_programs() {
    let Some(corpus) = inputs::oracle(OracleSet::Corpus, Game::Elden, "shaders") else {
        return;
    };
    let Some(listings) = inputs::oracle(OracleSet::Dxc, Game::Elden, "shader-listings") else {
        return;
    };
    let mut found = Vec::new();
    programs(&corpus, &mut found);
    let next = AtomicUsize::new(0);
    let mut outcomes: Vec<(usize, Result<String, String>)> = std::thread::scope(|s| {
        let workers: Vec<_> = (0..primase_testdata::threads().get())
            .map(|_| {
                s.spawn(|| {
                    let mut done = Vec::new();
                    loop {
                        let at = next.fetch_add(1, Ordering::Relaxed);
                        let Some(program) = found.get(at) else {
                            break;
                        };
                        done.push((at, compare(&corpus, &listings, program)));
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
        "{} of {} programs:
{}",
        failures.len(),
        found.len(),
        failures.join(
            "
"
        )
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
