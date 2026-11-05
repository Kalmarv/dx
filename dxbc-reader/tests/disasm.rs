#![allow(clippy::unwrap_used)]
//! The listings of `disassemble_with` against Microsoft's own, byte for byte: `tests/disasm/listings` holds
//! `D3DDisassemble`'s listing of every container in `tests/disasm` (built from the HLSL there by `generate.py`) and
//! in `tests/fixtures`, with no flags (`NAME.asm`) and with each flag that changes the text (`NAME.flagNN.asm`).
use dxbc_reader::{Options, disassemble_with};
use std::path::{Path, PathBuf};

/// The programs whose listings differ for a reason this disassembler does not write yet. Each is checked to still
/// differ, so the list cannot go stale.
const GAPS: &[(&str, &str)] = &[
    ("interfaces.ps50", "the class linkage tables of an IFCE part"),
    (
        "ps_sm5.debug",
        "the source and variable locations of an SDBG part",
    ),
];

/// The flags words the listings were made with: no flags, and every flag Microsoft's disassembler accepts but the
/// HTML one.
const FLAGS: [u32; 7] = [0, 0x02, 0x04, 0x10, 0x20, 0x40, 0x80];

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

fn listing(container: &Path, flags: u32) -> Option<String> {
    let stem = container.file_stem().unwrap().to_str().unwrap();
    let name = if flags == 0 {
        format!("{stem}.asm")
    } else {
        format!("{stem}.flag{flags:02x}.asm")
    };
    let path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/disasm/listings")
        .join(name);
    std::fs::read_to_string(path).ok()
}

#[test]
fn listings_are_microsofts() {
    let mut compared = 0;
    let mut differing = Vec::new();
    for container in containers() {
        let stem = container.file_stem().unwrap().to_str().unwrap().to_owned();
        let bytes = std::fs::read(&container).unwrap();
        let gap = GAPS.iter().find(|(name, _)| *name == stem);
        for flags in FLAGS {
            let Some(theirs) = listing(&container, flags) else {
                continue;
            };
            let ours = disassemble_with(&bytes, &Options::from_flags(flags).unwrap()).unwrap();
            if gap.is_some() {
                if flags == 0 {
                    assert_ne!(ours, theirs, "{stem} now matches: take it off GAPS");
                }
                continue;
            }
            compared += 1;
            if ours != theirs {
                let line = ours
                    .lines()
                    .zip(theirs.lines())
                    .position(|(a, b)| a != b)
                    .unwrap_or(0);
                differing.push(format!(
                    "{stem} flags 0x{flags:02x} line {}:\n  dx: {:?}\n  ms: {:?}",
                    line + 1,
                    ours.lines().nth(line).unwrap_or(""),
                    theirs.lines().nth(line).unwrap_or("")
                ));
            }
        }
    }
    assert!(
        differing.is_empty(),
        "{} of {compared} listings differ:\n{}",
        differing.len(),
        differing.join("\n")
    );
    // 65 programs outside the gaps, each with seven listings
    assert_eq!(compared, 455);
}

#[test]
fn flags_outside_the_listing_are_refused() {
    for flags in [0x01, 0x08, 0x100] {
        assert!(Options::from_flags(flags).is_err(), "0x{flags:x}");
    }
}
