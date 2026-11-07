#![allow(clippy::unwrap_used)]
//! Properties of the reader and the writer over generated containers, at a fixed number of cases so a run takes the
//! same time on every machine:
//!
//! - the writer's container reads back as the parts it was given, with the digest `checksum` computes;
//! - the reader accepts only what the writer writes: any bytes `chunks` reads are `serialize` of what it read, digest
//!   aside, so no layout the writer cannot produce gets through (a gap, a trailing byte, a size off by one);
//! - `replace_part` changes the one part and keeps the others in their places;
//! - on any edit or truncation of a container (generated, or one of the committed fixtures) the reader returns a value
//!   or an error, never a panic, and an error names a byte inside the input or a header field the input is too short to
//!   hold.
use std::path::Path;
use std::sync::OnceLock;

use dxcontainer::{Chunk, checksum, chunks, repair_digest, replace_part, serialize};
use proptest::prelude::*;
use proptest::sample::Index;
use proptest::strategy::ValueTree;
use proptest::test_runner::TestRunner;

/// The header: `DXBC`, the digest, the version, the size and the part count.
const HEADER: usize = 32;

/// Up to six parts of distinct kinds with up to 48 bytes each.
fn parts() -> impl Strategy<Value = Vec<([u8; 4], Vec<u8>)>> {
    proptest::collection::vec(
        (any::<[u8; 4]>(), proptest::collection::vec(any::<u8>(), 0..48)),
        0..6,
    )
    .prop_map(|mut parts| {
        let mut seen = Vec::new();
        parts.retain(|(kind, _)| {
            let new = !seen.contains(kind);
            seen.push(*kind);
            new
        });
        parts
    })
}

fn written(parts: &[([u8; 4], Vec<u8>)]) -> Vec<u8> {
    let chunks: Vec<Chunk<'_>> = parts
        .iter()
        .map(|(kind, data)| Chunk { kind: *kind, data })
        .collect();
    serialize(&chunks).unwrap()
}

/// The committed fixtures of both bytecodes, read once.
fn fixtures() -> &'static [Vec<u8>] {
    static FIXTURES: OnceLock<Vec<Vec<u8>>> = OnceLock::new();
    FIXTURES.get_or_init(|| {
        let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("..");
        let mut paths = Vec::new();
        for crate_dir in ["dxbc-reader", "dxil-reader"] {
            for entry in std::fs::read_dir(root.join(crate_dir).join("tests/fixtures")).unwrap() {
                let path = entry.unwrap().path();
                if path.extension().is_some_and(|e| e == "dxbc" || e == "dxil") {
                    paths.push(path);
                }
            }
        }
        paths.sort();
        paths.iter().map(|p| std::fs::read(p).unwrap()).collect()
    })
}

/// Byte edits (where, as a fraction of the length, and the new value) and an optional truncation.
fn edits() -> impl Strategy<Value = (Vec<(Index, u8)>, Option<Index>)> {
    (
        proptest::collection::vec((any::<Index>(), any::<u8>()), 0..4),
        proptest::option::of(any::<Index>()),
    )
}

fn edit(bytes: &[u8], (changes, cut): &(Vec<(Index, u8)>, Option<Index>)) -> Vec<u8> {
    let mut out = bytes.to_vec();
    if !out.is_empty() {
        for (at, value) in changes {
            let at = at.index(out.len());
            out[at] = *value;
        }
    }
    if let Some(cut) = cut {
        out.truncate(cut.index(out.len() + 1));
    }
    out
}

/// What the reader must do with any bytes: read them to what the writer would write, or refuse them at a byte inside
/// them (or at a header field past their end).
fn read_or_refuse(bytes: &[u8]) -> Result<(), TestCaseError> {
    match chunks(bytes) {
        Ok(parts) => {
            let mut expected = bytes.to_vec();
            repair_digest(&mut expected).unwrap();
            prop_assert_eq!(
                serialize(&parts).unwrap(),
                expected,
                "accepted bytes the writer does not write"
            );
        }
        Err(e) => prop_assert!(
            e.offset <= bytes.len() || e.offset < HEADER,
            "an error at byte {} of {}: {}",
            e.offset,
            bytes.len(),
            e
        ),
    }
    Ok(())
}

proptest! {
    #![proptest_config(ProptestConfig { cases: 512, failure_persistence: None, ..ProptestConfig::default() })]

    #[test]
    fn a_written_container_reads_back_as_its_parts(parts in parts()) {
        let bytes = written(&parts);
        let read = chunks(&bytes).unwrap();
        let read: Vec<([u8; 4], Vec<u8>)> = read.iter().map(|c| (c.kind, c.data.to_vec())).collect();
        prop_assert_eq!(&read, &parts);
        prop_assert_eq!(&checksum(&bytes).unwrap()[..], &bytes[4..20]);
        prop_assert_eq!(bytes.len(), HEADER + parts.iter().map(|(_, d)| 4 + 8 + d.len()).sum::<usize>());
    }

    #[test]
    fn a_replaced_part_is_the_only_change(parts in parts(), kind in any::<[u8; 4]>(), data in proptest::collection::vec(any::<u8>(), 0..48)) {
        let bytes = written(&parts);
        let changed = replace_part(&bytes, kind, &data).unwrap();
        let read = chunks(&changed).unwrap();
        prop_assert_eq!(&checksum(&changed).unwrap()[..], &changed[4..20]);
        let mut expected: Vec<([u8; 4], Vec<u8>)> = parts.clone();
        match expected.iter_mut().find(|(k, _)| *k == kind) {
            Some(part) => part.1.clone_from(&data),
            None => expected.push((kind, data.clone())),
        }
        let read: Vec<([u8; 4], Vec<u8>)> = read.iter().map(|c| (c.kind, c.data.to_vec())).collect();
        prop_assert_eq!(read, expected);
    }

    #[test]
    fn an_edited_container_is_read_as_written_or_refused(parts in parts(), edits in edits()) {
        read_or_refuse(&edit(&written(&parts), &edits))?;
    }

    #[test]
    fn an_edited_fixture_is_read_as_written_or_refused(which in any::<Index>(), edits in edits()) {
        let fixtures = fixtures();
        read_or_refuse(&edit(&fixtures[which.index(fixtures.len())], &edits))?;
    }

    #[test]
    fn a_random_directory_is_read_as_written_or_refused(
        digest in any::<[u8; 16]>(),
        count in 0u32..5,
        rest in proptest::collection::vec(any::<u8>(), 0..96),
    ) {
        // a well-formed header (its size the bytes' own) over a directory and parts of random bytes
        let mut bytes = b"DXBC".to_vec();
        bytes.extend(digest);
        bytes.extend(1u32.to_le_bytes());
        bytes.extend(((HEADER + rest.len()) as u32).to_le_bytes());
        bytes.extend(count.to_le_bytes());
        bytes.extend(&rest);
        read_or_refuse(&bytes)?;
    }
}

/// The edits reach both outcomes, so the property on what is read is tested on reads: of 512 edits drawn as the tests
/// draw them (a fixed seed), at least an eighth of each kind are read and at least an eighth refused.
#[test]
fn the_edits_reach_both_outcomes() {
    let mut runner = TestRunner::deterministic();
    let mut read = [0; 2];
    let mut refused = [0; 2];
    for _ in 0..512 {
        let (parts, generated) = (parts(), edits()).new_tree(&mut runner).unwrap().current();
        let (which, fixture) = (any::<Index>(), edits()).new_tree(&mut runner).unwrap().current();
        let fixtures = fixtures();
        let cases = [
            edit(&written(&parts), &generated),
            edit(&fixtures[which.index(fixtures.len())], &fixture),
        ];
        for (n, bytes) in cases.iter().enumerate() {
            if chunks(bytes).is_ok() {
                read[n] += 1;
            } else {
                refused[n] += 1;
            }
        }
    }
    for n in 0..2 {
        assert!(
            read[n] >= 64 && refused[n] >= 64,
            "read {read:?}, refused {refused:?}"
        );
    }
}
