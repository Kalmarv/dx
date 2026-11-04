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
            "binding {} kind {} returns {} dimension {} samples {} register {} count {} flags {} space {} id {:?}",
            b.name, b.kind, b.returns, b.dimension, b.samples, b.register, b.count, b.flags, b.space, b.id
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
                " variable {} at {} size {} flags {} default {:?}",
                v.name, v.offset, v.size, v.flags, v.default
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

#[test]
fn the_sm51_rdef_layout_puts_bindings_in_register_spaces_and_numbers_them() {
    let sm51 = dxbc_reader::rdef(&fixture("reflection_sm51.ps51.dxbc"))
        .unwrap()
        .unwrap();
    assert_eq!(sm51.target, 0xffff_0501);
    let bindings = |rdef: &Rdef| -> Vec<(String, u32, u32, u32, u32, Option<u32>)> {
        rdef.bindings
            .iter()
            .map(|b| (b.name.clone(), b.kind, b.register, b.count, b.space, b.id))
            .collect()
    };
    // name, kind (3 sampler, 2 texture, 0 cbuffer), register, count, space, id: the spaces and the array of four are
    // the source's, and the ids number each kind's resources from 0
    assert_eq!(
        bindings(&sm51),
        [
            ("linear_wrap".to_owned(), 3, 2, 1, 3, Some(0)),
            ("albedo".to_owned(), 2, 3, 1, 1, Some(0)),
            ("detail".to_owned(), 2, 4, 4, 1, Some(1)),
            ("Params".to_owned(), 0, 1, 1, 2, Some(0)),
        ]
    );
    // the 40-byte records lie 8 bytes apart more than the 32-byte ones
    assert_eq!(sm51.bindings[1].word - sm51.bindings[0].word, 10);

    // Shader Model 5.0 has no spaces, and binds only the element of the array the program reads
    let sm50 = dxbc_reader::rdef(&fixture("reflection_sm51.ps50.dxbc"))
        .unwrap()
        .unwrap();
    assert_eq!(sm50.target, 0xffff_0500);
    assert_eq!(
        bindings(&sm50),
        [
            ("linear_wrap".to_owned(), 3, 2, 1, 0, None),
            ("albedo".to_owned(), 2, 3, 1, 0, None),
            ("detail[2]".to_owned(), 2, 6, 1, 0, None),
            ("Params".to_owned(), 0, 1, 1, 0, None),
        ]
    );
    assert_eq!(sm50.bindings[1].word - sm50.bindings[0].word, 8);
}

#[test]
fn a_variable_the_program_never_reads_has_its_used_flag_clear() {
    let flags = |name: &str| -> Vec<(String, u32)> {
        let rdef = dxbc_reader::rdef(&fixture(name)).unwrap().unwrap();
        rdef.buffers[0]
            .variables
            .iter()
            .map(|v| (v.name.clone(), v.flags))
            .collect()
    };
    // D3D_SVF_USED is 2; the 5.0 build indexes the array with a literal, so it never reads `layer` either
    assert_eq!(
        flags("reflection_sm51.ps51.dxbc"),
        [
            ("tint".to_owned(), 2),
            ("unused_scale".to_owned(), 0),
            ("layer".to_owned(), 2)
        ]
    );
    assert_eq!(
        flags("reflection_sm51.ps50.dxbc"),
        [
            ("tint".to_owned(), 2),
            ("unused_scale".to_owned(), 0),
            ("layer".to_owned(), 0)
        ]
    );
}
