#![allow(clippy::unwrap_used)]
//! The listing of a whole game's DXIL programs against dxc 1.9.2609's `-dumpbin`, byte for byte: the programs of one
//! oracle entry, each against its listing in another (`<path>.txt`, the same path below it). A test whose entries are
//! not configured skips with a line naming the key; a program without its listing fails, as one that differs or that
//! the disassembler refuses does.
mod inputs;

use inputs::{Game, OracleSet};
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

fn programs(dir: &Path, out: &mut Vec<PathBuf>) {
    let mut entries: Vec<PathBuf> = std::fs::read_dir(dir)
        .unwrap()
        .map(|e| e.unwrap().path())
        .collect();
    entries.sort();
    for p in entries {
        if p.is_dir() {
            programs(&p, out);
        } else if std::fs::read(&p).unwrap().starts_with(b"DXBC") {
            out.push(p);
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
    let mut identical: BTreeMap<String, usize> = BTreeMap::new();
    let mut failures = Vec::new();
    for program in &found {
        let rel = program.strip_prefix(&corpus).unwrap();
        let mut listing = listings.join(rel).into_os_string();
        listing.push(".txt");
        let bytes = std::fs::read(program).unwrap();
        let target = dxil_reader::part(&bytes)
            .ok()
            .and_then(|p| p.target())
            .unwrap_or_else(|| "unknown".to_owned());
        let Ok(theirs) = std::fs::read_to_string(&listing) else {
            failures.push(format!("{}: no listing", rel.display()));
            continue;
        };
        match dxil_reader::disasm::disassemble(&bytes) {
            Err(e) => failures.push(format!("{} ({target}): refused: {e}", rel.display())),
            Ok(ours) if ours == theirs => *identical.entry(target).or_default() += 1,
            Ok(ours) => {
                let line = ours
                    .lines()
                    .zip(theirs.lines())
                    .position(|(a, b)| a != b)
                    .unwrap_or(0);
                failures.push(format!(
                    "{} ({target}) line {}:\n  dx:  {:?}\n  dxc: {:?}",
                    rel.display(),
                    line + 1,
                    ours.lines().nth(line).unwrap_or(""),
                    theirs.lines().nth(line).unwrap_or("")
                ));
            }
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
