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

/// The fixtures of `examples/patched_fixtures.rs` whose counters do not describe what the decoder reads: two with
/// their `dcl_temps` counts made negative, and edits of class programs (`classes_calls.ps50`,
/// `classes_resources.ps50.zi` and `classes_arrays2d.ps50` in `tests/disasm`), whose instruction counter fxc does not
/// write as the number of their instructions (41 of 51, 57 of 68, 58 of 66), nor for the /Zi build with subroutines
/// `zi_names.ps50.zi` (53 of 56).
const EDITED: [&str; 6] = [
    "indices_negated.ps50.dxbc",
    "indices_negated.ps51.dxbc",
    "interface_id.ps50.dxbc",
    "labels.ps50.zi.dxbc",
    "conditionals_continuec.ps50.dxbc",
    "saturated_calls.ps50.zi.dxbc",
];

#[test]
fn the_counters_of_the_compilers_own_output_equal_the_decoders_counts() {
    let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures");
    let mut checked = 0;
    for entry in std::fs::read_dir(dir).unwrap() {
        let path = entry.unwrap().path();
        if !path.extension().is_some_and(|e| e == "dxbc")
            || EDITED.iter().any(|e| path.file_name().is_some_and(|n| n == *e))
        {
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
        // fxc counts a shader message (`printf`, `errorf`) as an instruction, as its listing's slot count does, one
        // whose character count leaves no room for its string (custom data of class 4) too
        let messages = program
            .declarations
            .iter()
            .filter(|d| {
                matches!(
                    d.kind,
                    Declared::ShaderMessage { .. } | Declared::CustomData { class: 4 }
                )
            })
            .count();
        assert_eq!(
            stat.instructions(),
            Some((program.instructions.len() + messages) as u32),
            "{name}"
        );
        assert_eq!(stat.temp_registers(), Some(temps), "{name}");
        assert_eq!(stat.texture_gradient(), Some(count("sample_d") as u32), "{name}");
        assert_eq!(stat.movc_instructions(), Some(count("movc") as u32), "{name}");
        checked += 1;
    }
    assert!(checked >= 10, "{checked} fixtures with a STAT part");
}
