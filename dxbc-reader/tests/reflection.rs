#![allow(clippy::unwrap_used)]
//! Reflection and signatures of fxc's own output (the HLSL is beside each fixture), compared with the other layouts of
//! the same source.
use dxbc_reader::{Rdef, RdefType};
use std::fmt::Write as _;
use std::path::Path;

fn fixture(name: &str) -> Vec<u8> {
    std::fs::read(
        Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/fixtures")
            .join(name),
    )
    .unwrap()
}

fn shape_type(out: &mut String, ty: &RdefType, depth: usize) {
    let pad = "  ".repeat(depth);
    writeln!(
        out,
        "{pad}type class {} scalar {} rows {} columns {} elements {}",
        ty.class, ty.scalar, ty.rows, ty.columns, ty.elements
    )
    .unwrap();
    for m in &ty.members {
        writeln!(out, "{pad} member {} at {}", m.name, m.offset).unwrap();
        shape_type(out, &m.ty, depth + 1);
    }
}

/// Everything an `Rdef` states except where its records lie (the layouts put them at different words).
fn shape(rdef: &Rdef) -> String {
    let mut out = String::new();
    for b in &rdef.bindings {
        writeln!(
            out,
            "binding {} kind {} returns {} dimension {} samples {} register {} count {} flags {}",
            b.name, b.kind, b.returns, b.dimension, b.samples, b.register, b.count, b.flags
        )
        .unwrap();
    }
    for buffer in &rdef.buffers {
        writeln!(
            out,
            "buffer {} kind {} size {}",
            buffer.name, buffer.kind, buffer.size
        )
        .unwrap();
        for v in &buffer.variables {
            writeln!(
                out,
                " variable {} at {} size {} default {:?}",
                v.name, v.offset, v.size, v.default
            )
            .unwrap();
            shape_type(&mut out, &v.ty, 2);
        }
    }
    out
}

#[test]
fn the_sm4_rdef_layout_states_what_the_sm5_layout_of_the_same_source_does() {
    let sm5 = dxbc_reader::rdef(&fixture("reflection_sm4.ps50.dxbc"))
        .unwrap()
        .unwrap();
    assert_eq!(sm5.target, 0xffff_0500);
    let expected = shape(&sm5);
    // the source has 2 constant buffers and 4 bindings (the texture pair, the sampler pair) besides: 6 in all
    assert_eq!(sm5.buffers.len(), 2);
    assert_eq!(sm5.bindings.len(), 6);
    assert_eq!(
        sm5.buffers[0]
            .variables
            .iter()
            .map(|v| v.name.as_str())
            .collect::<Vec<_>>(),
        [
            "view_projection",
            "skew",
            "eye",
            "time",
            "count",
            "lights",
            "weights"
        ]
    );
    for (name, target) in [
        ("reflection_sm4.ps40.dxbc", 0xffff_0400),
        ("reflection_sm4.ps41.dxbc", 0xffff_0401),
    ] {
        let sm4 = dxbc_reader::rdef(&fixture(name)).unwrap().unwrap();
        assert_eq!(sm4.target, target, "{name}");
        assert_eq!(shape(&sm4), expected, "{name}");
        // the records lie where the shorter layout puts them
        assert_ne!(sm4.bindings[0].word, sm5.bindings[0].word, "{name}");
    }
}

#[test]
fn a_patch_constant_signature_with_minimum_precision_is_read_from_psg1_as_it_is_from_pcsg() {
    for stage in ["hs", "ds"] {
        let min16 = fixture(&format!("min16_patch.{stage}.dxbc"));
        let plain = fixture(&format!("min16_patch.plain.{stage}.dxbc"));
        let kinds = |bytes: &[u8]| -> Vec<[u8; 4]> {
            dxbc_reader::parts(bytes)
                .unwrap()
                .iter()
                .map(|c| c.kind)
                .collect()
        };
        assert!(kinds(&min16).contains(b"PSG1") && !kinds(&min16).contains(b"PCSG"));
        assert!(kinds(&plain).contains(b"PCSG") && !kinds(&plain).contains(b"PSG1"));
        let from_psg1 = dxbc_reader::patch_signature_elements(&min16).unwrap();
        let from_pcsg = dxbc_reader::patch_signature_elements(&plain).unwrap();
        let names = |e: &[dxbc_reader::SignatureElement]| -> Vec<(String, u32, u8)> {
            e.iter().map(|e| (e.name.clone(), e.index, e.mask)).collect()
        };
        // the three edge factors, the inside factor and the 4-component PCDATA
        assert_eq!(from_psg1.len(), 5, "{stage}");
        assert_eq!(from_psg1.last().unwrap().name, "PCDATA");
        assert_eq!(from_psg1.last().unwrap().mask, 0b1111);
        assert_eq!(names(&from_psg1), names(&from_pcsg), "{stage}");
    }
}

#[test]
fn a_container_with_neither_patch_constant_part_names_the_first_it_looks_for() {
    let e = dxbc_reader::patch_signature_elements(&fixture("tessellation.vs.dxbc")).unwrap_err();
    assert!(e.detail.contains("PCSG"), "{e}");
}
