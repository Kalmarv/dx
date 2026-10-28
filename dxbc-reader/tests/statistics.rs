#![allow(clippy::unwrap_used)]
//! The `STAT` counters: a hand-built part read word by word, what is refused, and the committed fixtures (fxc output)
//! against the decoder's own counts of the program.
use std::path::Path;

use dxbc_reader::decode::Declared;
use dxbc_reader::statistics;

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

fn words(w: &[u32]) -> Vec<u8> {
    w.iter().flat_map(|w| w.to_le_bytes()).collect()
}

#[test]
fn each_named_counter_is_its_word_and_a_short_part_lacks_the_later_ones() {
    // word n holds 100 + n
    let part = words(&(100..137).collect::<Vec<_>>());
    let s = statistics(&container(&[(b"STAT", &part), (b"SHEX", &[0; 4])]))
        .unwrap()
        .unwrap();
    assert_eq!(s.words.len(), 37);
    assert_eq!(
        [
            s.instructions(),
            s.temp_registers(),
            s.declarations(),
            s.float_instructions(),
            s.int_instructions(),
            s.uint_instructions(),
            s.static_flow_control(),
            s.dynamic_flow_control(),
            s.texture_normal(),
            s.texture_load(),
            s.texture_comparison(),
            s.texture_gradient(),
            s.movc_instructions(),
        ],
        [100, 101, 103, 104, 105, 106, 107, 108, 114, 115, 116, 118, 120].map(Some)
    );
    // the 29-word part of a Shader Model 4.0 program still has every named word; a part cut at word 15 lacks the rest
    let short = statistics(&container(&[(b"STAT", &part[..15 * 4])]))
        .unwrap()
        .unwrap();
    assert_eq!(
        (
            short.texture_normal(),
            short.texture_load(),
            short.movc_instructions()
        ),
        (Some(114), None, None)
    );
    let empty = statistics(&container(&[(b"STAT", &[])])).unwrap().unwrap();
    assert_eq!((empty.words.len(), empty.instructions()), (0, None));
}

#[test]
fn no_part_no_counters_and_a_bitcode_part_or_a_ragged_one_is_refused() {
    assert_eq!(statistics(&container(&[(b"SHEX", &[0; 4])])).unwrap(), None);
    let refused = |parts: &[(&[u8; 4], &[u8])]| statistics(&container(parts)).unwrap_err().to_string();
    assert!(refused(&[(b"STAT", &[0; 6]), (b"SHEX", &[0; 4])]).contains("6 bytes, not a multiple of 4"));
    assert!(refused(&[(b"STAT", &[0; 8]), (b"DXIL", &[0; 4])]).contains("bitcode module"));
    assert!(statistics(b"DXBC").is_err());
}

#[test]
fn the_counters_of_the_compilers_own_output_equal_the_decoders_counts() {
    let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures");
    let mut checked = 0;
    for entry in std::fs::read_dir(dir).unwrap() {
        let path = entry.unwrap().path();
        if !path.extension().is_some_and(|e| e == "dxbc") {
            continue;
        }
        let bytes = std::fs::read(&path).unwrap();
        let name = path.display();
        let Some(stat) = statistics(&bytes).unwrap() else {
            continue;
        };
        let program = dxbc_reader::decode(&dxbc_reader::code(&bytes).unwrap()).unwrap();
        let count = |op: &str| program.instructions.iter().filter(|i| i.name() == op).count();
        // a hull program declares its temporaries once a phase: the counter is the largest declaration
        let temps: u32 = program
            .declarations
            .iter()
            .map(|d| if let Declared::Temps(n) = d.kind { n } else { 0 })
            .max()
            .unwrap_or(0);
        assert_eq!(
            stat.instructions(),
            Some(program.instructions.len() as u32),
            "{name}"
        );
        assert_eq!(stat.temp_registers(), Some(temps), "{name}");
        assert_eq!(stat.texture_gradient(), Some(count("sample_d") as u32), "{name}");
        assert_eq!(stat.movc_instructions(), Some(count("movc") as u32), "{name}");
        checked += 1;
    }
    assert!(checked >= 10, "{checked} fixtures with a STAT part");
}
