#![allow(clippy::unwrap_used)]
//! Metadata the reflection reader keeps that the lifter does not need: the entry point's shader flags and the usage
//! mask of a signature element. The fixtures are dxc 1.7 output (`precise_cs.hlsl` as `cs_6_0`, `precise.hlsl` as
//! `vs_6_0`, `usage.hlsl` as `ps_6_0`); the expected values are read off dxc's own listing of the same compilation
//! (`-Fc`): the `!{i32 0, i64 N, ...}` entry properties and the signature table's Used column (`xy`, `x`, `w`).
use dxil_reader::module::Module;
use dxil_reader::reflection;

fn module(name: &str) -> Module {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures")
        .join(name);
    let bytes = std::fs::read(path).unwrap();
    let chunks = dxil_reader::parts(&bytes).unwrap();
    dxil_reader::module(&chunks, b"DXIL").unwrap().unwrap()
}

#[test]
fn the_shader_flags_are_the_entry_properties_tag_0() {
    // `!9 = !{i32 0, i64 16, i32 4, !10}` in the compute program's listing; the vertex and pixel programs have no
    // properties
    assert_eq!(
        reflection::shader_flags(&module("precise.cs.dxil")).unwrap(),
        Some(16)
    );
    assert_eq!(
        reflection::shader_flags(&module("precise.vs.dxil")).unwrap(),
        None
    );
    assert_eq!(reflection::shader_flags(&module("usage.ps.dxil")).unwrap(), None);
}

#[test]
fn a_signature_element_states_the_components_the_program_uses() {
    let m = module("usage.ps.dxil");
    // the listing's Used column: TEXCOORD0 xy, TEXCOORD1 x, COLOR0 w; SV_Target xyzw
    let [inputs, outputs, patch] = reflection::usage_masks(&m).unwrap();
    assert_eq!(inputs, [Some(0b0011), Some(0b0001), Some(0b1000)]);
    assert_eq!(outputs, [Some(0b1111)]);
    assert!(patch.is_empty());
    // the lists run in the order of the elements
    let (elements, _) = reflection::elements(&m).unwrap();
    assert_eq!(elements.len(), inputs.len());
    // the mask counts from the element's first component, not from x: B is packed into w and states 1, A reads y of
    // its xyz (2) and C reads y of its xy (2); dxc's Used column prints them as w, y and y
    let [inputs, ..] = reflection::usage_masks(&module("usage2.ps.dxil")).unwrap();
    assert_eq!(inputs, [Some(0b010), Some(0b001), Some(0b010)]);
    // a program with no signatures has no masks
    let [inputs, outputs, patch] = reflection::usage_masks(&module("precise.cs.dxil")).unwrap();
    assert!(inputs.is_empty() && outputs.is_empty() && patch.is_empty());
}
