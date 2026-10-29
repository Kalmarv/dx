#![allow(clippy::unwrap_used)]
//! `sampling::texture_reads` on the `sampling` and `sampling_dynamic` fixtures (dxc 1.7 output). The expected reads are
//! the calls dxc's own listing (`-dumpbin`) prints, in its order, with the registers of the `createHandle` (or
//! `createHandleFromBinding`) call that makes each handle and the register space of the range it names: the listing of
//! `sampling.hlsl` has
//!
//! ```text
//! sample           t3 (space 0)  s1 (space 0)
//! sampleLevel      t4 (space 2)  s2 (space 1)
//! sampleBias       t5            s1
//! sampleCmp        t6            s4 (a comparison sampler)
//! sampleCmpLevelZero t6          s4
//! textureGather    t3            s2 (space 1)
//! textureGatherCmp t6            s4
//! sampleGrad       t9 (arr[1] of t8..t10)  s1
//! textureLoad      t20
//! bufferLoad       t21 (a typed buffer)
//! bufferLoad       t22 (a byte address buffer; rawBufferLoad when compiled for 6.6)
//! calculateLOD     t3            s2 (space 1)
//! ```
use dxil_reader::module::Module;
use dxil_reader::sampling::{Handle, texture_reads};

fn module(name: &str) -> Module {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures")
        .join(name);
    let bytes = std::fs::read(path).unwrap();
    let chunks = dxil_reader::parts(&bytes).unwrap();
    dxil_reader::module(&chunks, b"DXIL").unwrap().unwrap()
}

/// (class, space, register) of a handle.
fn key(h: Option<Handle>) -> Option<(u8, u32, Option<u32>)> {
    h.map(|h| (h.class, h.space, h.register))
}

type Read = (
    u16,
    Option<(u8, u32, Option<u32>)>,
    Option<(u8, u32, Option<u32>)>,
    bool,
);

fn reads(name: &str) -> Vec<Read> {
    texture_reads(&module(name))
        .unwrap()
        .into_iter()
        .map(|r| (r.opcode, key(r.texture), key(r.sampler), r.comparison))
        .collect()
}

fn expected(raw: u16) -> Vec<Read> {
    let srv = |space, register| Some((0, space, Some(register)));
    let sampler = |space, register| Some((3, space, Some(register)));
    vec![
        (60, srv(0, 3), sampler(0, 1), false),
        (62, srv(2, 4), sampler(1, 2), false),
        (61, srv(0, 5), sampler(0, 1), false),
        (64, srv(0, 6), sampler(0, 4), true),
        (65, srv(0, 6), sampler(0, 4), true),
        (73, srv(0, 3), sampler(1, 2), false),
        (74, srv(0, 6), sampler(0, 4), true),
        (63, srv(0, 9), sampler(0, 1), false),
        (66, srv(0, 20), None, false),
        (68, srv(0, 21), None, false),
        (raw, srv(0, 22), None, false),
        (81, srv(0, 3), sampler(1, 2), false),
    ]
}

#[test]
fn each_call_names_the_registers_of_its_handles() {
    // Shader Model 6.0: createHandle(class, range id, index); the buffer is read with bufferLoad
    assert_eq!(reads("sampling.dxil"), expected(68));
}

#[test]
fn handles_made_from_a_binding_and_annotated_resolve_alike() {
    // Shader Model 6.6: createHandleFromBinding({lower, upper, space, class}, index) then annotateHandle; the byte
    // address buffer is read with rawBufferLoad (139)
    assert_eq!(reads("sampling.66.dxil"), expected(139));
}

#[test]
fn a_createhandle_handle_names_its_range_and_a_binding_handle_does_not() {
    let by_range = texture_reads(&module("sampling.dxil")).unwrap();
    let by_binding = texture_reads(&module("sampling.66.dxil")).unwrap();
    // `sample` of t3: the 8 SRV ranges of the program are numbered in declaration order, t3 first
    assert_eq!(by_range[0].texture.unwrap().range, Some(0));
    assert_eq!(by_range[0].sampler.unwrap().range, Some(0));
    assert!(by_binding.iter().all(|r| r.texture.unwrap().range.is_none()));
    // the loads take no sampler; every other call does
    for r in by_range {
        assert_eq!(r.sampled, r.sampler.is_some(), "{r:?}");
    }
}

#[test]
fn a_computed_index_leaves_the_register_open_but_keeps_class_and_space() {
    // `arr[NonUniformResourceIndex(i)].Sample(pick[NonUniformResourceIndex(j & 1)], uv)` then `arr[2].Sample(linear_s, uv)`
    let srv = |register| Some((0, 0, register));
    let sampler = |register| Some((3, 0, register));
    assert_eq!(
        reads("sampling_dynamic.dxil"),
        [
            (60, srv(None), sampler(None), false),
            (60, srv(Some(10)), sampler(Some(1)), false),
        ]
    );
}

#[test]
fn a_program_that_samples_nothing_lists_none() {
    assert!(reads("compute_basic.dxil").is_empty());
}
