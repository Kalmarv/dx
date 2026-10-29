#![allow(clippy::unwrap_used)]
//! `texture_reads` on the `sampling` fixture (fxc `ps_5_0` output of `sampling.hlsl`). The expected reads are the ones
//! fxc's own disassembly of the same file prints, in its order:
//!
//! ```text
//! sample_indexable(texture2d)(float,float,float,float) r0.xyzw, v1.xyxx, t3.xyzw, s1
//! sample_l_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t4.xyzw, s2, l(0.000000)
//! sample_b_indexable(texture2darray)(float,float,float,float) r1.xyzw, r1.xyzx, t5.xyzw, s1, l(1.000000)
//! sample_c_indexable(texture2d)(float,float,float,float) r1.x, v1.xyxx, t6.xxxx, s4, l(0.500000)
//! sample_c_lz_indexable(texture2d)(float,float,float,float) r1.x, v1.xyxx, t6.xxxx, s4, l(0.500000)
//! gather4_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t3.xyzw, s2.x
//! gather4_c_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t6.xyzw, s4.x, l(0.500000)
//! sample_d_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t9.xyzw, s1, r1.xyxx, r1.zwzz
//! ld_indexable(texture2d)(float,float,float,float) r1.xyzw, r1.xyzw, t20.xyzw
//! ld_indexable(buffer)(float,float,float,float) r1.xyzw, v2.xxxx, t21.xyzw
//! ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r1.xyzw, r1.x, t22.xyzw
//! lod r1.x, v1.xyxx, t3.x, s2
//! ```
//!
//! and its declarations `dcl_sampler s1, mode_default`, `s2, mode_default`, `s4, mode_comparison`.
use dxbc_reader::{decode, opcode_name, texture_reads};

fn reads(name: &str) -> Vec<(&'static str, u32, Option<u32>, bool, Option<u32>)> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures")
        .join(name);
    let bytes = std::fs::read(path).unwrap();
    let program = decode(&dxbc_reader::code(&bytes).unwrap()).unwrap();
    texture_reads(&program)
        .into_iter()
        .map(|r| {
            assert!(!r.texture_indexed && !r.sampler_indexed);
            (
                opcode_name(r.opcode),
                r.texture,
                r.sampler,
                r.comparison,
                r.sampler_mode,
            )
        })
        .collect()
}

#[test]
fn each_texture_read_names_the_texture_and_sampler_registers_the_listing_prints() {
    assert_eq!(
        reads("sampling.dxbc"),
        [
            ("sample", 3, Some(1), false, Some(0)),
            ("sample_l", 4, Some(2), false, Some(0)),
            ("sample_b", 5, Some(1), false, Some(0)),
            ("sample_c", 6, Some(4), true, Some(1)),
            ("sample_c_lz", 6, Some(4), true, Some(1)),
            ("gather4", 3, Some(2), false, Some(0)),
            ("gather4_c", 6, Some(4), true, Some(1)),
            ("sample_d", 9, Some(1), false, Some(0)),
            ("ld", 20, None, false, None),
            ("ld", 21, None, false, None),
            ("ld_raw", 22, None, false, None),
            ("lod", 3, Some(2), false, Some(0)),
        ]
    );
}

#[test]
fn a_program_without_texture_reads_lists_none() {
    // `compute_basic` reads and writes buffers through `u` and `g` registers and samples nothing
    assert!(reads("compute_basic.dxbc").is_empty());
}

#[test]
fn a_comparison_instruction_names_a_comparison_sampler() {
    // fxc refuses to compile a comparison on a default sampler, so the instruction and the declaration agree
    for (name, _, sampler, comparison, mode) in reads("sampling.dxbc") {
        if sampler.is_some() {
            assert_eq!(comparison, mode == Some(1), "{name}");
        }
    }
}

#[test]
fn the_three_shader_models_of_one_source_read_alike() {
    // `reflection_sm4.hlsl` as fxc lists it for `ps_4_0`, `ps_4_1` and `ps_5_0`: `sample_c_lz` of t0 with the comparison
    // sampler s4, then `sample` of t3 and of t0 with s0
    for name in [
        "reflection_sm4.ps40.dxbc",
        "reflection_sm4.ps41.dxbc",
        "reflection_sm4.ps50.dxbc",
    ] {
        assert_eq!(
            reads(name),
            [
                ("sample_c_lz", 0, Some(4), true, Some(1)),
                ("sample", 3, Some(0), false, Some(0)),
                ("sample", 0, Some(0), false, Some(0)),
            ],
            "{name}"
        );
    }
}
