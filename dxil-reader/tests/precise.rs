#![allow(clippy::unwrap_used)]
//! The `dx.precise` attachment of an instruction. The fixture is dxc 1.7 output (`precise.hlsl` as `vs_6_0`); the
//! expected instructions are the ones dxc's own listing of the same compilation (`-Fc`) prints `!dx.precise` on,
//! numbered from 0 in the order the listing prints them, which is how the attachment block numbers them.
use dxil_reader::module::{Module, Op};

fn module(name: &str) -> Module {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures")
        .join(name);
    let bytes = std::fs::read(path).unwrap();
    let chunks = dxil_reader::parts(&bytes).unwrap();
    dxil_reader::module(&chunks, b"DXIL").unwrap().unwrap()
}

#[test]
fn an_instruction_marked_precise_is_flagged_where_the_compilers_listing_marks_it() {
    let m = module("precise.vs.dxil");
    let f = m.functions.first().unwrap();
    // 43 instructions in dxc's listing, with `!dx.precise` on 1 to 4
    assert_eq!(f.instructions.len(), 43);
    let flagged: Vec<usize> = f
        .instructions
        .iter()
        .enumerate()
        .filter_map(|(i, inst)| inst.precise.then_some(i))
        .collect();
    assert_eq!(flagged, [1, 2, 3, 4]);
    // the four are the calls the listing shows: loadInput of the four components
    assert!(m.precise_kind.is_some());
    for i in &f.instructions[1..=4] {
        let Op::Call { function, .. } = &i.op else {
            panic!("{:?}", i.op);
        };
        assert!(m.name(*function).unwrap().starts_with("dx.op.loadInput"));
    }
    // programs the listing shows no attachment on
    for name in [
        "precise.cs.dxil",
        "usage.ps.dxil",
        "compute_basic.dxil",
        "draw_vs.dxil",
    ] {
        let m = module(name);
        let any = m
            .functions
            .iter()
            .flat_map(|f| &f.instructions)
            .any(|i| i.precise);
        assert!(!any, "{name}");
    }
}
