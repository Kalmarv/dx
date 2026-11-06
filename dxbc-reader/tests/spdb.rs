#![allow(clippy::unwrap_used)]
//! The `SPDB` part is read from untrusted bytes: a part with any of its bytes changed is written or refused, never a
//! panic, and the refusals name the part's word.
use dxbc_reader::{disassemble, parts};
use std::path::Path;

#[test]
fn a_changed_spdb_part_is_written_or_refused() {
    // a pixel program with structs, arrays, loops and inlined calls, and a class linkage program
    for name in ["ps_sm5.ps50.zi.dxbc", "classes_calls.ps50.zi.dxbc"] {
        let path = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/disasm")
            .join(name);
        let bytes = std::fs::read(&path).unwrap();
        let directory = parts(&bytes).unwrap();
        let part = directory.iter().find(|c| &c.kind == b"SPDB").unwrap();
        let start = part.data.as_ptr() as usize - bytes.as_ptr() as usize;
        let end = start + part.data.len();
        assert!(disassemble(&bytes).is_ok());
        let mut refused = 0;
        // every byte of the part, set to 0x00 and to 0xff
        for at in start..end {
            for value in [0x00, 0xff] {
                let mut changed = bytes.clone();
                changed[at] = value;
                if let Err(e) = disassemble(&changed) {
                    assert!(
                        e.detail.contains("SPDB") || e.detail.contains("MSF"),
                        "{name} byte {at}: {e}"
                    );
                    refused += 1;
                }
            }
        }
        assert!(refused > 0, "{name}: no change was refused");
    }
}
