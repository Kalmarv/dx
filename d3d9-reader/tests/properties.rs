#![allow(clippy::unwrap_used)]
//! Properties of the reader and the disassembler over generated programs: the committed programs (`tests/disasm`,
//! `tests/assembled`) with words changed, at a fixed number of cases so a run takes the same time on every machine.
//!
//! - Any edit is read or refused, never a panic. Listing the same bytes twice gives the same text, and the listing is
//!   refused exactly when the read is, with the read's error. (A refusal's word is not bounded here: one for a
//!   constant table offset past its comment names the word the offset points to, which can lie past the stream.)
//! - `frame` finds the program in front of any other bytes: the program `read` reads, and its exact bytes.
//! - The listings under the flags words relate to the plain one as Microsoft's do. The relations are checked first on
//!   Microsoft's own listings of the programs in `tests/disasm`, so they are Microsoft's rules and not this
//!   disassembler's:
//!   - 0x02 changes nothing;
//!   - 0x04, 0x20 and 0x24 put a prefix of spaces, a number, an offset and colons before lines and change nothing else;
//!   - 0x40 leaves the program's lines as they are and drops comments;
//!   - 0x80 changes only `def` lines.
use std::path::{Path, PathBuf};
use std::sync::OnceLock;

use d3d9_reader::{Options, disassemble_with, frame, read};
use proptest::prelude::*;
use proptest::sample::Index;
use proptest::strategy::ValueTree;
use proptest::test_runner::TestRunner;

/// The flags words whose relation to the plain listing is checked.
const RELATED: [u32; 6] = [0x02, 0x04, 0x20, 0x24, 0x40, 0x80];

fn listing(bytes: &[u8], flags: u32) -> Result<String, d3d9_reader::Error> {
    disassemble_with(bytes, &Options::from_flags(flags).unwrap())
}

/// The lines that are neither empty nor comments.
fn code(text: &str) -> Vec<&str> {
    text.split('\n')
        .filter(|x| !x.trim().is_empty() && !x.trim_start().starts_with("//"))
        .collect()
}

/// Whether `flagged`, the listing under `flags`, relates to `plain` as Microsoft's listings do; the reason where it
/// does not.
fn relates(plain: &str, flagged: &str, flags: u32) -> Result<(), String> {
    let (p, f): (Vec<&str>, Vec<&str>) = (plain.split('\n').collect(), flagged.split('\n').collect());
    let same_length = || {
        (p.len() == f.len())
            .then_some(())
            .ok_or(format!("{} lines, {} plain", f.len(), p.len()))
    };
    match flags {
        0x02 => (p == f).then_some(()).ok_or("0x02 changed the listing".into()),
        0x04 | 0x20 | 0x24 => {
            same_length()?;
            for (a, b) in f.iter().zip(&p) {
                let prefix = a
                    .strip_suffix(b)
                    .ok_or(format!("{a:?} does not end with {b:?}"))?;
                if !prefix
                    .chars()
                    .all(|c| c == ' ' || c == ':' || c == 'x' || c.is_ascii_hexdigit())
                {
                    return Err(format!("{a:?}: a prefix {prefix:?}"));
                }
            }
            Ok(())
        }
        0x40 => (code(plain) == code(flagged))
            .then_some(())
            .ok_or("0x40 changed the program's lines".into()),
        0x80 => {
            same_length()?;
            match f
                .iter()
                .zip(&p)
                .find(|(a, b)| a != b && !b.trim_start().starts_with("def "))
            {
                Some((a, b)) => Err(format!("0x80 changed {b:?} to {a:?}")),
                None => Ok(()),
            }
        }
        _ => unreachable!("flags {flags:#x}"),
    }
}

/// The committed programs, read once.
fn programs() -> &'static [(PathBuf, Vec<u8>)] {
    static PROGRAMS: OnceLock<Vec<(PathBuf, Vec<u8>)>> = OnceLock::new();
    PROGRAMS.get_or_init(|| {
        let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests");
        let mut out = Vec::new();
        for dir in ["disasm", "assembled"] {
            for entry in std::fs::read_dir(root.join(dir)).unwrap() {
                let path = entry.unwrap().path();
                if path.extension().is_some_and(|e| e == "bin") {
                    let bytes = std::fs::read(&path).unwrap();
                    out.push((path, bytes));
                }
            }
        }
        out.sort();
        out
    })
}

#[test]
fn the_flag_relations_hold_for_microsofts_listings() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/disasm");
    let mut checked = 0;
    for (path, _) in programs().iter().filter(|(p, _)| p.starts_with(&root)) {
        let stem = path.file_stem().unwrap().to_str().unwrap();
        let plain = std::fs::read_to_string(root.join(format!("listings/{stem}.asm"))).unwrap();
        for flags in RELATED {
            let flagged =
                std::fs::read_to_string(root.join(format!("listings/{stem}.flag{flags:02x}.asm"))).unwrap();
            if let Err(why) = relates(&plain, &flagged, flags) {
                panic!("Microsoft's {stem} under {flags:#04x}: {why}");
            }
            checked += 1;
        }
    }
    assert_eq!(checked, 6 * 74);
}

/// Changes to a committed program's words: which program, and the bytes (where, as a fraction of its length, and the
/// new value).
fn edited() -> impl Strategy<Value = Vec<u8>> {
    (
        any::<Index>(),
        proptest::collection::vec((any::<Index>(), any::<u8>()), 1..4),
    )
        .prop_map(|(which, changes)| {
            let programs = programs();
            let mut out = programs[which.index(programs.len())].1.clone();
            for (at, value) in changes {
                let at = at.index(out.len());
                out[at] = value;
            }
            out
        })
}

proptest! {
    #![proptest_config(ProptestConfig { cases: 512, failure_persistence: None, ..ProptestConfig::default() })]

    #[test]
    fn an_edited_program_is_read_or_refused_and_its_listings_relate(bytes in edited()) {
        let plain = listing(&bytes, 0);
        prop_assert_eq!(&plain, &listing(&bytes, 0), "listed twice, two texts");
        match (read(&bytes), &plain) {
            (Ok(_), Ok(plain)) => {
                for flags in RELATED.into_iter().chain([0x10, 0xf6]) {
                    let flagged = listing(&bytes, flags);
                    prop_assert!(flagged.is_ok(), "listed with no flags, refused under {:#04x}: {:?}", flags, flagged);
                    if RELATED.contains(&flags) && let Err(why) = relates(plain, &flagged.unwrap(), flags) {
                        prop_assert!(false, "under {:#04x}: {}", flags, why);
                    }
                }
            }
            (Err(e), Err(listed)) => {
                prop_assert_eq!(&e, listed, "the listing refuses as the read does");
            }
            (read, listed) => prop_assert!(false, "read {:?}, listed {:?}", read.map(|_| ()), listed.as_ref().map(|_| ())),
        }
    }

    #[test]
    fn frame_finds_a_program_in_front_of_other_bytes(which in any::<Index>(), after in proptest::collection::vec(any::<u8>(), 0..64)) {
        let programs = programs();
        let program = &programs[which.index(programs.len())].1;
        let mut bytes = program.clone();
        bytes.extend(&after);
        let (framed, span) = frame(&bytes).unwrap();
        prop_assert_eq!(span, &program[..]);
        prop_assert_eq!(framed, read(program).unwrap());
    }
}

/// The edits reach both outcomes, so the relations are tested on listings: of 512 edits drawn as the test draws them
/// (a fixed seed), at least an eighth are read and at least an eighth refused.
#[test]
fn the_edits_reach_both_outcomes() {
    let mut runner = TestRunner::deterministic();
    let mut read_ones = 0;
    for _ in 0..512 {
        let bytes = edited().new_tree(&mut runner).unwrap().current();
        read_ones += usize::from(read(&bytes).is_ok());
    }
    assert!((64..=448).contains(&read_ones), "{read_ones} of 512 read");
}
