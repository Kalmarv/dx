#![allow(clippy::unwrap_used)]
//! The `SFI0` shader feature flags: refusals on hand-built containers, and the names of the bits against what `fxc` and
//! `dxc` themselves list for programs that need one feature each (`tests/fixtures/features`, the sources beside the
//! compiled containers, the compilers' own lists in `features.txt`).
use std::path::Path;

use dxcontainer::{Bytecode, FeatureFlags, feature_flags, feature_name};

/// A container of these parts, directory first and the parts one after another.
fn container(parts: &[(&[u8; 4], &[u8])]) -> Vec<u8> {
    let directory = 32 + 4 * parts.len();
    let mut offsets = Vec::new();
    let mut body = Vec::new();
    for (kind, data) in parts {
        offsets.push((directory + body.len()) as u32);
        body.extend_from_slice(*kind);
        body.extend_from_slice(&(data.len() as u32).to_le_bytes());
        body.extend_from_slice(data);
    }
    let mut out = b"DXBC".to_vec();
    out.extend_from_slice(&[0; 16]);
    out.extend_from_slice(&1u32.to_le_bytes());
    out.extend_from_slice(&((directory + body.len()) as u32).to_le_bytes());
    out.extend_from_slice(&(parts.len() as u32).to_le_bytes());
    for offset in offsets {
        out.extend_from_slice(&offset.to_le_bytes());
    }
    out.extend_from_slice(&body);
    out
}

fn flags(bits: u64, program: &[u8; 4]) -> Option<FeatureFlags> {
    feature_flags(&container(&[(b"SFI0", &bits.to_le_bytes()), (program, &[0; 4])])).unwrap()
}

#[test]
fn the_flags_are_the_eight_bytes_of_the_sfi0_part_and_the_program_part_says_what_they_mean() {
    let dxbc = flags(0x12, b"SHEX").unwrap();
    assert_eq!(
        dxbc,
        FeatureFlags {
            bytecode: Bytecode::Dxbc,
            bits: 0x12
        }
    );
    assert_eq!(
        dxbc.names(),
        ["Raw and Structured buffers", "Minimum-precision data types"]
    );
    assert_eq!(flags(0x12, b"SHDR").unwrap().bytecode, Bytecode::Dxbc);
    // the same bits in a DXIL container, and a bit only DXIL names
    let dxil = flags(0x12 | 1 << 21, b"DXIL").unwrap();
    assert_eq!(dxil.bytecode, Bytecode::Dxil);
    assert_eq!(
        dxil.names(),
        ["Raw and Structured buffers", "Minimum-precision data types", "Sampler feedback"]
    );
    assert_eq!(dxil.unnamed(), 0);
    assert_eq!(flags(1 << 21, b"SHEX").unwrap().unnamed(), 1 << 21);
    assert!(dxil.has(1) && dxil.has(4) && !dxil.has(0) && !dxil.has(64));
    // the high bits of a 64-bit value
    let high = flags(1 << 63 | 1 << 14, b"DXIL").unwrap();
    assert_eq!(high.names(), ["Wave level operations"]);
    assert_eq!(high.unnamed(), 1 << 63);
    assert_eq!(flags(0, b"DXIL").unwrap().names(), Vec::<&str>::new());
}

#[test]
fn a_container_without_sfi0_has_no_flags_and_a_bad_one_is_refused() {
    assert_eq!(feature_flags(&container(&[(b"SHEX", &[0; 4])])).unwrap(), None);
    assert_eq!(feature_flags(&container(&[])).unwrap(), None);
    let refused = |parts: &[(&[u8; 4], &[u8])]| feature_flags(&container(parts)).unwrap_err().to_string();
    assert!(refused(&[(b"SFI0", &[0; 4]), (b"SHEX", &[0; 4])]).contains("4 bytes, not 8"));
    assert!(refused(&[(b"SFI0", &[0; 12]), (b"DXIL", &[0; 4])]).contains("12 bytes, not 8"));
    // no program part, or both kinds: the bits cannot be read
    assert!(refused(&[(b"SFI0", &[0; 8])]).contains("no single kind of program part"));
    assert!(
        refused(&[(b"SFI0", &[0; 8]), (b"SHEX", &[0; 4]), (b"DXIL", &[0; 4])]).contains("no single kind")
    );
    // a container the part reader refuses
    assert!(feature_flags(b"DXBC").is_err());
    // the offset of the part is reported
    let error = feature_flags(&container(&[(b"SFI0", &[0; 4]), (b"SHEX", &[0; 4])])).unwrap_err();
    assert_eq!(error.offset, 32 + 4 * 2 + 8);
}

#[test]
fn bit_names_depend_on_the_bytecode() {
    for bit in 0..=13 {
        assert_eq!(
            feature_name(Bytecode::Dxbc, bit),
            feature_name(Bytecode::Dxil, bit),
            "bit {bit}"
        );
        assert!(feature_name(Bytecode::Dxbc, bit).is_some(), "bit {bit}");
    }
    assert_eq!(
        feature_name(Bytecode::Dxbc, 7),
        Some("Comparison filtering for feature level 9")
    );
    assert_eq!(feature_name(Bytecode::Dxbc, 14), None);
    assert_eq!(feature_name(Bytecode::Dxil, 14), Some("Wave level operations"));
    assert_eq!(feature_name(Bytecode::Dxil, 64), None);
}

#[test]
fn the_dxil_names_are_what_dxc_lists_for_each_bit() {
    // bits.txt: what dxc's listing names each bit of SFI0, set alone (written by bits.py)
    let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures/features");
    let table = std::fs::read_to_string(dir.join("bits.txt")).unwrap();
    let mut listed = std::collections::BTreeMap::new();
    for line in table.lines().filter(|l| !l.starts_with('#')) {
        let (bit, name) = line.split_once('\t').unwrap();
        listed.insert(bit.parse::<u32>().unwrap(), name);
    }
    assert_eq!(listed.len(), 36);
    for bit in 0..64 {
        assert_eq!(
            feature_name(Bytecode::Dxil, bit),
            listed.get(&bit).copied(),
            "bit {bit}"
        );
    }
}

#[test]
fn the_names_are_what_the_compilers_list_for_their_own_output() {
    let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures/features");
    let table = std::fs::read_to_string(dir.join("features.txt")).unwrap();
    let (mut checked, mut dxil, mut dxbc, mut bits_seen) = (0, 0, 0, 0u64);
    for line in table.lines().filter(|l| !l.starts_with('#')) {
        let [file, stored, listed] = line.splitn(3, '\t').collect::<Vec<_>>()[..] else {
            panic!("{line}");
        };
        let bytes = std::fs::read(dir.join(file)).unwrap();
        let read = feature_flags(&bytes).unwrap_or_else(|e| panic!("{file}: {e}"));
        let expected_bytecode = if file.ends_with(".dxil") {
            Bytecode::Dxil
        } else {
            Bytecode::Dxbc
        };
        if stored == "-" {
            assert_eq!(read, None, "{file}");
            checked += 1;
            continue;
        }
        let read = read.unwrap_or_else(|| panic!("{file}: no SFI0"));
        assert_eq!(read.bytecode, expected_bytecode, "{file}");
        assert_eq!(
            read.bits,
            u64::from_str_radix(stored.trim_start_matches("0x"), 16).unwrap(),
            "{file}"
        );
        assert_eq!(read.unnamed(), 0, "{file}");
        // fxc lists nothing for the raw-buffer bit; every other line is the compiler's own list
        if listed.starts_with('[') {
            assert_eq!(read.names(), ["Raw and Structured buffers"], "{file}");
        } else {
            assert_eq!(read.names().join(" | "), listed, "{file}");
        }
        bits_seen |= read.bits;
        match read.bytecode {
            Bytecode::Dxil => dxil += 1,
            Bytecode::Dxbc => dxbc += 1,
        }
        checked += 1;
    }
    assert_eq!((checked, dxil, dxbc), (44, 27, 16), "fixtures read");
    // every bit fxc names is covered by one of the compiled programs (dxc's are checked against its listing of each
    // bit, in bits.txt)
    let named_dxbc: u64 = (0..64)
        .filter(|b| feature_name(Bytecode::Dxbc, *b).is_some())
        .fold(0, |m, b| m | 1 << b);
    assert_eq!(named_dxbc & !bits_seen, 0, "a named bit no fixture sets");
}
