#![allow(clippy::unwrap_used)]
//! The listings of `disassemble_with` against Microsoft's own, byte for byte: `tests/disasm/listings` holds
//! `D3DDisassemble`'s listing of every container in `tests/disasm` (built from the HLSL there by `generate.py`) and
//! in `tests/fixtures`, with no flags (`NAME.asm`) and with the flags that change the text alone, in pairs and all
//! together (`NAME.flagNN.asm`).
use dxbc_reader::{Options, disassemble_with};
use std::path::{Path, PathBuf};

/// The programs whose listings differ for a reason this disassembler does not write yet. Each is checked to still
/// differ, so the list cannot go stale.
const GAPS: &[(&str, &str)] = &[(
    "ps_sm5.debug",
    "the source and variable locations of an SPDB part (the PDB fxc /Zi embeds)",
)];

/// The flags words the listings were made with (`generate.py`'s `FLAGS`): no flags, and the flags that change the text
/// alone, in pairs and all together.
fn flag_words() -> Vec<u32> {
    const TEXT: [u32; 6] = [0x02, 0x04, 0x10, 0x20, 0x40, 0x80];
    let mut words = vec![0, TEXT.iter().sum()];
    for (i, a) in TEXT.iter().enumerate() {
        words.push(*a);
        words.extend(TEXT[i + 1..].iter().map(|b| a | b));
    }
    words.sort_unstable();
    words
}

fn containers() -> Vec<PathBuf> {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests");
    let mut found: Vec<PathBuf> = ["disasm", "fixtures"]
        .iter()
        .flat_map(|folder| std::fs::read_dir(root.join(folder)).unwrap())
        .map(|entry| entry.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "dxbc"))
        .collect();
    found.sort();
    found
}

fn listing(container: &Path, flags: u32) -> String {
    let stem = container.file_stem().unwrap().to_str().unwrap();
    let name = if flags == 0 {
        format!("{stem}.asm")
    } else {
        format!("{stem}.flag{flags:02x}.asm")
    };
    let path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/disasm/listings")
        .join(name);
    std::fs::read_to_string(&path).unwrap_or_else(|e| panic!("{}: {e}", path.display()))
}

/// Where `ours` first differs from `theirs`, for a failure message naming `what`; `None` when they are the same.
fn difference(what: &str, ours: &str, theirs: &str) -> Option<String> {
    if ours == theirs {
        return None;
    }
    let line = ours
        .lines()
        .zip(theirs.lines())
        .position(|(a, b)| a != b)
        .unwrap_or(0);
    Some(format!(
        "{what} line {}:\n  dx: {:?}\n  ms: {:?}",
        line + 1,
        ours.lines().nth(line).unwrap_or(""),
        theirs.lines().nth(line).unwrap_or("")
    ))
}

#[test]
fn listings_are_microsofts() {
    let mut compared = 0;
    let mut differing = Vec::new();
    for container in containers() {
        let stem = container.file_stem().unwrap().to_str().unwrap().to_owned();
        let bytes = std::fs::read(&container).unwrap();
        let gap = GAPS.iter().find(|(name, _)| *name == stem);
        for flags in flag_words() {
            let theirs = listing(&container, flags);
            let ours = disassemble_with(&bytes, &Options::from_flags(flags).unwrap()).unwrap();
            if gap.is_some() {
                if flags == 0 {
                    assert_ne!(ours, theirs, "{stem} now matches: take it off GAPS");
                }
                continue;
            }
            compared += 1;
            differing.extend(difference(&format!("{stem} flags 0x{flags:02x}"), &ours, &theirs));
        }
    }
    assert!(
        differing.is_empty(),
        "{} of {compared} listings differ:\n{}",
        differing.len(),
        differing.join("\n")
    );
    // 82 programs outside the gaps, each with 23 listings
    assert_eq!(compared, 1886);
}

/// The programs of another disassembler's tests (`tests/third-party/t7_dxbc`, see its README), against the listings
/// Microsoft's disassembler wrote of them with no flags.
#[test]
fn third_party_listings_are_microsofts() {
    let folder = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/third-party/t7_dxbc");
    let mut containers: Vec<PathBuf> = std::fs::read_dir(&folder)
        .unwrap()
        .map(|entry| entry.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "dxbc"))
        .collect();
    containers.sort();
    let mut differing = Vec::new();
    for container in &containers {
        let theirs = std::fs::read_to_string(container.with_extension("asm")).unwrap();
        let ours = disassemble_with(&std::fs::read(container).unwrap(), &Options::default()).unwrap();
        differing.extend(difference(&container.display().to_string(), &ours, &theirs));
    }
    assert!(differing.is_empty(), "{}", differing.join("\n"));
    assert_eq!(containers.len(), 19);
}

#[test]
fn flags_outside_the_listing_are_refused() {
    for flags in [0x01, 0x08, 0x100] {
        assert!(Options::from_flags(flags).is_err(), "0x{flags:x}");
    }
}
