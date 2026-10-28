#![allow(clippy::unwrap_used)]
//! The per-opcode operand formats: which opcodes have one, a few entries worked from the instruction definitions, the
//! decoder refusing an instruction whose operand count is not its opcode's, and every committed fixture agreeing with the
//! table (the fixtures are Microsoft's fxc output).
use std::path::Path;

use dxbc_reader::{OperandClass::*, decode, opcode_name, operand_format};

/// The opcodes in 0 to 235 with no format: the declarations, the phase markers, `customdata` (read as a declaration), the
/// opcodes whose operand is not a register (`call`, `callc`, `label`, `interface_call`), and the reserved and
/// unimplemented numbers.
const NO_FORMAT: &[u16] = &[
    4, 5, 44, 53, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107,
    112, 113, 114, 115, 116, 120, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157,
    158, 159, 160, 161, 162, 206, 207, 208, 209, 218, 235,
];

#[test]
fn the_opcodes_without_a_format_are_the_documented_ones() {
    let none: Vec<u16> = (0..236).filter(|&op| operand_format(op).is_none()).collect();
    assert_eq!(none, NO_FORMAT);
    for op in [236, 300, 2047] {
        assert!(operand_format(op).is_none(), "{op}");
    }
}

#[test]
fn formats_are_the_instruction_definitions() {
    let f = |op: u16| {
        let format = operand_format(op).unwrap();
        (
            opcode_name(op),
            format.destinations.to_vec(),
            format.sources.to_vec(),
        )
    };
    assert_eq!(f(0), ("add", vec![Float], vec![Float, Float]));
    assert_eq!(f(50), ("mad", vec![Float], vec![Float, Float, Float]));
    assert_eq!(f(38), ("imul", vec![Integer, Integer], vec![Integer, Integer]));
    assert_eq!(f(77), ("sincos", vec![Float, Float], vec![Float]));
    assert_eq!(f(69), ("sample", vec![Varies], vec![Float, Resource, Resource]));
    assert_eq!(
        f(70),
        ("sample_c", vec![Float], vec![Float, Resource, Resource, Float])
    );
    assert_eq!(
        f(73),
        (
            "sample_d",
            vec![Varies],
            vec![Float, Resource, Resource, Float, Float]
        )
    );
    assert_eq!(f(164), ("store_uav_typed", vec![Resource], vec![Integer, Varies]));
    assert_eq!(
        f(180),
        ("imm_atomic_iadd", vec![Integer, Resource], vec![Integer, Integer])
    );
    assert_eq!(f(132), ("uaddc", vec![Integer, Integer], vec![Integer, Integer]));
    assert_eq!(f(142), ("swapc", vec![Float, Float], vec![Integer, Float, Float]));
    assert_eq!(f(191), ("dadd", vec![Double], vec![Double, Double]));
    assert_eq!(f(117), ("emit_stream", vec![], vec![Resource]));
    assert_eq!(f(190), ("sync", vec![], vec![]));
    assert_eq!(
        f(223),
        ("ld_feedback", vec![Varies, Integer], vec![Integer, Resource])
    );
}

fn fixtures() -> Vec<(String, Vec<u32>)> {
    let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures");
    let mut out = Vec::new();
    for entry in std::fs::read_dir(dir).unwrap() {
        let path = entry.unwrap().path();
        if path.extension().is_some_and(|e| e == "dxbc") {
            let bytes = std::fs::read(&path).unwrap();
            out.push((path.display().to_string(), dxbc_reader::code(&bytes).unwrap()));
        }
    }
    out.sort();
    out
}

#[test]
fn every_fixture_instruction_has_its_formats_operand_count() {
    let mut checked = 0;
    for (name, words) in fixtures() {
        for ins in decode(&words).unwrap().instructions {
            let Some(format) = ins.format() else { continue };
            assert_eq!(
                ins.operands.len(),
                format.operands(),
                "{name}: {} at word {}",
                ins.name(),
                ins.word
            );
            let (destinations, sources) = ins.destinations_and_sources().unwrap();
            assert_eq!(
                (destinations.len(), sources.len()),
                (format.destinations.len(), format.sources.len())
            );
            checked += 1;
        }
    }
    assert_eq!(checked, 418, "instructions with a format in the fixtures");
}

/// The first instruction of `name` with opcode `from` has its opcode token changed to `to`.
fn retarget(name: &str, from: u16, to: u16) -> Vec<u32> {
    let (_, mut words) = fixtures().into_iter().find(|(n, _)| n.ends_with(name)).unwrap();
    let program = decode(&words).unwrap();
    let at = program
        .instructions
        .iter()
        .find(|i| i.opcode == from)
        .unwrap()
        .word;
    words[at] = (words[at] & !0x7ff) | u32::from(to);
    words
}

#[test]
fn an_instruction_with_another_operand_count_is_refused_naming_its_word() {
    // `mov` (two operands) with `mad`'s opcode, and `mul` (three) with `mov`'s
    let words = retarget("tessellation.vs.dxbc", 54, 50);
    let at = decode(&retarget("tessellation.vs.dxbc", 54, 54))
        .unwrap()
        .instructions
        .iter()
        .find(|i| i.opcode == 54)
        .unwrap()
        .word;
    let e = decode(&words).unwrap_err();
    assert_eq!(e.word, at);
    assert_eq!(
        e.detail,
        "mad has 2 operands, its format is 1 destinations and 3 sources"
    );
    let e = decode(&retarget("tessellation.vs.dxbc", 56, 54)).unwrap_err();
    assert_eq!(
        e.detail,
        "mov has 3 operands, its format is 1 destinations and 1 sources"
    );
}

#[test]
fn an_opcode_with_no_format_is_not_checked() {
    // `mov` made `label`: no format, so the decoder does not count its operands (it refuses the operand it cannot read
    // only where that is the case)
    let words = retarget("tessellation.vs.dxbc", 54, 44);
    if let Err(e) = decode(&words) {
        assert!(!e.detail.contains("operands, its format"), "{e}");
    }
}
