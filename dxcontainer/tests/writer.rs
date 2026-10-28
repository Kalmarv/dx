#![allow(clippy::unwrap_used)]
//! The container writer: the committed fixtures of both bytecodes (`dxbc-reader`'s and `dxil-reader`'s, real compilers'
//! output) re-serialize byte-identical, an edit is written with the digest the reader's `checksum` computes, and the
//! refusals are by name.
use std::path::Path;

use dxcontainer::{Chunk, ReplaceError, checksum, chunks, repair_digest, replace_part, serialize};

fn fixtures() -> Vec<(String, Vec<u8>)> {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("..");
    let mut out = Vec::new();
    for crate_dir in ["dxbc-reader", "dxil-reader"] {
        for entry in std::fs::read_dir(root.join(crate_dir).join("tests/fixtures")).unwrap() {
            let path = entry.unwrap().path();
            if path.extension().is_some_and(|e| e == "dxbc" || e == "dxil") {
                out.push((path.display().to_string(), std::fs::read(&path).unwrap()));
            }
        }
    }
    assert!(out.len() > 100, "{} fixtures", out.len());
    out
}

#[test]
fn every_committed_fixture_reserializes_byte_identical() {
    for (name, bytes) in fixtures() {
        let parts = chunks(&bytes).unwrap();
        assert_eq!(serialize(&parts).unwrap(), bytes, "{name}");
    }
}

#[test]
fn a_part_keeps_the_padding_it_was_given_or_none() {
    // parts of 3 and 5 bytes with nothing between them (Shader Model 6 parts are not padded), and one padded to four
    let parts = [
        Chunk {
            kind: *b"AAAA",
            data: &[1, 2, 3],
        },
        Chunk {
            kind: *b"BBBB",
            data: &[4, 5, 6, 7, 8],
        },
        Chunk {
            kind: *b"CCCC",
            data: &[9, 0, 0, 0],
        },
    ];
    let bytes = serialize(&parts).unwrap();
    assert_eq!(bytes.len(), 32 + 12 + (8 + 3) + (8 + 5) + (8 + 4));
    let read = chunks(&bytes).unwrap();
    assert_eq!(
        read.iter().map(|p| (p.kind, p.data.len())).collect::<Vec<_>>(),
        [(*b"AAAA", 3), (*b"BBBB", 5), (*b"CCCC", 4)]
    );
    assert_eq!(serialize(&read).unwrap(), bytes);
    // the directory stores the offsets of the parts as they follow one another
    let offset = |i: usize| u32::from_le_bytes(bytes[32 + 4 * i..36 + 4 * i].try_into().unwrap()) as usize;
    assert_eq!((offset(0), offset(1), offset(2)), (44, 44 + 11, 44 + 11 + 13));
}

#[test]
fn an_edited_part_is_written_with_a_digest_that_reads_back() {
    for (name, bytes) in fixtures().into_iter().take(40) {
        let parts = chunks(&bytes).unwrap();
        let Some(last) = parts.last() else { continue };
        // one more byte at the end of the last part: a different size, offsets and digest
        let mut longer = last.data.to_vec();
        longer.push(0x5a);
        let edited = replace_part(&bytes, last.kind, &longer).unwrap();
        assert_eq!(edited.len(), bytes.len() + 1, "{name}");
        let stored: [u8; 16] = edited[4..20].try_into().unwrap();
        assert_eq!(checksum(&edited), Some(stored), "{name}");
        assert_ne!(stored, bytes[4..20], "{name}");
        let reread = chunks(&edited).unwrap();
        assert_eq!(reread.len(), parts.len());
        assert_eq!(reread.last().unwrap().data, longer.as_slice());
        // the other parts are as they were, in their places
        for (a, b) in parts.iter().zip(&reread).take(parts.len() - 1) {
            assert_eq!((a.kind, a.data), (b.kind, b.data), "{name}");
        }
    }
}

#[test]
fn a_part_that_is_not_there_is_appended_and_a_stale_digest_is_repaired() {
    let (_, bytes) = fixtures().into_iter().next().unwrap();
    let extra = replace_part(&bytes, *b"ZZZZ", &[1, 2, 3]).unwrap();
    let parts = chunks(&extra).unwrap();
    assert_eq!(parts.last().unwrap().kind, *b"ZZZZ");
    assert_eq!(parts.last().unwrap().data, [1, 2, 3]);

    let mut stale = bytes.clone();
    let last = stale.len() - 1;
    stale[last] ^= 1;
    assert_ne!(checksum(&stale).unwrap()[..], stale[4..20]);
    repair_digest(&mut stale).unwrap();
    assert_eq!(checksum(&stale).unwrap()[..], stale[4..20]);
    // an edit that changes nothing leaves the digest as it was
    let mut same = bytes.clone();
    repair_digest(&mut same).unwrap();
    assert_eq!(same, bytes);
}

#[test]
fn what_cannot_be_written_is_refused_by_name() {
    let part = |kind: &[u8; 4]| Chunk {
        kind: *kind,
        data: &[1],
    };
    let twice = serialize(&[part(b"AAAA"), part(b"BBBB"), part(b"AAAA")]).unwrap_err();
    assert!(
        twice.to_string().contains("parts 0 and 2 are both AAAA"),
        "{twice}"
    );

    assert!(
        repair_digest(&mut [0; 19])
            .unwrap_err()
            .to_string()
            .contains("not a DXBC container")
    );
    let mut wrong = [0u8; 40];
    assert!(repair_digest(&mut wrong).is_err());

    let refused = replace_part(&[1, 2, 3], *b"AAAA", &[]).unwrap_err();
    assert!(matches!(refused, ReplaceError::Read(_)), "{refused}");

    // an empty container is a header and nothing else
    let empty = serialize(&[]).unwrap();
    assert_eq!(empty.len(), 32);
    assert!(chunks(&empty).unwrap().is_empty());
}
