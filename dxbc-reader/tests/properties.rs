#![allow(clippy::unwrap_used)]
//! Properties of the disassembler over generated programs: the committed programs (`tests/disasm`, `tests/fixtures`)
//! with bytes of one of their parts changed, at a fixed number of cases so a run takes the same time on every machine.
//!
//! - Any edit is listed or refused, never a panic, under every flags word. Listed with no flags, it is listed under
//!   every flags word; refused, it is refused under every one but 0x40 and 0x10, which read no header part and no
//!   `SPDB` part. Listing the same bytes twice gives the same text. (A refusal's word is not bounded
//!   here: one for an offset past its part names the byte the offset points to, which can lie past the container.)
//! - The listings under the flags words relate to the plain one as Microsoft's do. The relations are checked first on
//!   Microsoft's own listings of every committed program (`tests/disasm/listings`), so they are Microsoft's rules and
//!   not this disassembler's:
//!   - 0x02 changes nothing;
//!   - 0x04, 0x20 and 0x24 put a prefix of spaces, a number, an offset and colons before lines and change nothing else;
//!   - 0x40 drops the header (comments, and the rest of a name with a newline in it, which is none) and comments, and
//!     leaves the program's lines as they are (except in a feature level 9 program, whose Direct3D 9 listing it drops
//!     too);
//!   - 0x80 changes only lines with literals (`l(`, `d(`, a Direct3D 9 `def`) and an immediate constant buffer.
use std::path::{Path, PathBuf};
use std::sync::OnceLock;

use dxbc_reader::{Options, disassemble_with, parts};
use proptest::prelude::*;
use proptest::sample::Index;
use proptest::strategy::ValueTree;
use proptest::test_runner::TestRunner;

/// The flags words whose relation to the plain listing is checked.
const RELATED: [u32; 5] = [0x02, 0x04, 0x20, 0x24, 0x40];

fn listing(bytes: &[u8], flags: u32) -> Result<String, dxbc_reader::Error> {
    disassemble_with(bytes, &Options::from_flags(flags).unwrap())
}

fn lines(text: &str) -> Vec<&str> {
    text.split('\n').collect()
}

fn comment(line: &str) -> bool {
    line.trim_start().starts_with("//")
}

/// Whether `flagged`, the listing under `flags`, relates to `plain` as Microsoft's listings do; `level9` for a feature
/// level 9 program. The reason where it does not.
fn relates(plain: &str, flagged: &str, flags: u32, level9: bool) -> Result<(), String> {
    let (p, f) = (lines(plain), lines(flagged));
    match flags {
        0x02 => (p == f).then_some(()).ok_or("0x02 changed the listing".into()),
        0x04 | 0x20 | 0x24 => {
            if p.len() != f.len() {
                return Err(format!("{} lines, {} plain", f.len(), p.len()));
            }
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
        0x40 => {
            let code = |l: &[&str]| -> Vec<String> {
                l.iter()
                    .filter(|x| !x.trim().is_empty() && !comment(x))
                    .map(|x| (*x).to_owned())
                    .collect()
            };
            // the program starts at its version line, the first line 0x40 writes: the header before it can hold lines
            // that are no comment, the rest of a name with a newline in it
            let program = f
                .first()
                .and_then(|version| p.iter().position(|l| l == version))
                .map_or(&p[..], |start| &p[start..]);
            if level9 || code(program) == code(&f) {
                Ok(())
            } else {
                Err("0x40 changed the program's lines".into())
            }
        }
        0x80 => {
            if p.len() != f.len() {
                return Err(format!("{} lines, {} plain", f.len(), p.len()));
            }
            let mut buffer = false;
            for (a, b) in f.iter().zip(&p) {
                if b.starts_with("dcl_immediateConstantBuffer") {
                    buffer = true;
                }
                let literal = b.contains("l(") || b.contains("d(") || b.trim_start().starts_with("def ");
                if a != b && !buffer && !literal {
                    return Err(format!("0x80 changed {b:?} to {a:?}"));
                }
                if b.trim_end().ends_with("} }") {
                    buffer = false;
                }
            }
            Ok(())
        }
        _ => unreachable!("flags {flags:#x}"),
    }
}

fn level9(bytes: &[u8]) -> bool {
    parts(bytes).is_ok_and(|p| p.iter().any(|c| &c.kind == b"Aon9"))
}

/// The committed programs, read once.
fn programs() -> &'static [(PathBuf, Vec<u8>)] {
    static PROGRAMS: OnceLock<Vec<(PathBuf, Vec<u8>)>> = OnceLock::new();
    PROGRAMS.get_or_init(|| {
        let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests");
        let mut out = Vec::new();
        for dir in ["disasm", "fixtures"] {
            for entry in std::fs::read_dir(root.join(dir)).unwrap() {
                let path = entry.unwrap().path();
                if path.extension().is_some_and(|e| e == "dxbc") {
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
    let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/disasm/listings");
    let mut checked = 0;
    for (path, bytes) in programs() {
        let stem = path.file_stem().unwrap().to_str().unwrap();
        let plain = std::fs::read_to_string(dir.join(format!("{stem}.asm"))).unwrap();
        for flags in RELATED.into_iter().chain([0x80]) {
            let flagged = std::fs::read_to_string(dir.join(format!("{stem}.flag{flags:02x}.asm"))).unwrap();
            if let Err(why) = relates(&plain, &flagged, flags, level9(bytes)) {
                panic!("Microsoft's {stem} under {flags:#04x}: {why}");
            }
            checked += 1;
        }
    }
    assert_eq!(checked, 6 * programs().len());
}

/// Changes to the bytes of one part of a committed program: which program, which part, and the bytes (where, as a
/// fraction of the part, and the new value).
fn edited() -> impl Strategy<Value = Vec<u8>> {
    (
        any::<Index>(),
        any::<Index>(),
        proptest::collection::vec((any::<Index>(), any::<u8>()), 1..4),
    )
        .prop_map(|(which, part, changes)| {
            let programs = programs();
            let bytes = &programs[which.index(programs.len())].1;
            let directory = parts(bytes).unwrap();
            let chunk = directory[part.index(directory.len())];
            let start = chunk.data.as_ptr() as usize - bytes.as_ptr() as usize;
            let mut out = bytes.clone();
            if !chunk.data.is_empty() {
                for (at, value) in changes {
                    out[start + at.index(chunk.data.len())] = value;
                }
            }
            out
        })
}

proptest! {
    #![proptest_config(ProptestConfig { cases: 256, failure_persistence: None, ..ProptestConfig::default() })]

    #[test]
    fn an_edited_program_is_listed_or_refused_and_its_listings_relate(bytes in edited()) {
        let plain = listing(&bytes, 0);
        prop_assert_eq!(&plain, &listing(&bytes, 0), "listed twice, two texts");
        match &plain {
            Ok(plain) => {
                for flags in RELATED.into_iter().chain([0x80, 0x10, 0xf6]) {
                    let flagged = listing(&bytes, flags);
                    prop_assert!(flagged.is_ok(), "listed with no flags, refused under {:#04x}: {:?}", flags, flagged);
                    if !RELATED.contains(&flags) && flags != 0x80 {
                        continue;
                    }
                    if let Err(why) = relates(plain, &flagged.unwrap(), flags, level9(&bytes)) {
                        prop_assert!(false, "under {:#04x}: {}", flags, why);
                    }
                }
            }
            Err(_) => {
                // 0x40 reads no header part and 0x10 no SPDB part, so they may list what the others refuse
                for flags in [0x02, 0x04, 0x20, 0x24, 0x80, 0xa6] {
                    prop_assert!(listing(&bytes, flags).is_err(), "refused with no flags, listed under {:#04x}", flags);
                }
            }
        }
    }
}

/// The edits reach both outcomes, so the relations are tested on listings: of 256 edits drawn as the test draws them
/// (a fixed seed), at least an eighth are listed and at least an eighth refused.
#[test]
fn the_edits_reach_both_outcomes() {
    let mut runner = TestRunner::deterministic();
    let mut listed = 0;
    for _ in 0..256 {
        let bytes = edited().new_tree(&mut runner).unwrap().current();
        listed += usize::from(listing(&bytes, 0).is_ok());
    }
    assert!((32..=224).contains(&listed), "{listed} of 256 listed");
}
