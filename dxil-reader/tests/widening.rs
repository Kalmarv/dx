#![allow(clippy::unwrap_used)]
//! The metadata the reader keeps beyond the lifter's needs: the string and flag attributes of a function, the metadata
//! attached to instructions, the entry point's property tags, the tail tags of signature elements and the optional
//! fields of resource records. The fixtures are dxc 1.7 output (the HLSL beside each, with the command in its first
//! comment, or the files of the ray tracing fixtures compiled with the options named here); every expected value is read
//! off dxc's own listing of the same compilation (`-Fc`: attribute lines, `!dx.entryPoints` records, the `!llvm.loop` and
//! `!dx.controlflow.hints` suffixes) and equals a second reader of the bitcode, written from the LLVM bitstream
//! description, on the same files. The PSV0 part states the same payload size, thread group and wave size where noted.
use dxil_reader::module::{Attachment, Attribute, Constant, Metadata, Module, Value, attribute_name};
use dxil_reader::reflection;

fn module(name: &str) -> Module {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures")
        .join(name);
    let bytes = std::fs::read(path).unwrap();
    let chunks = dxil_reader::parts(&bytes).unwrap();
    dxil_reader::module(&chunks, b"DXIL").unwrap().unwrap()
}

/// The value id of the function the module's symbol table names `name`.
fn function(m: &Module, name: &str) -> usize {
    m.names
        .iter()
        .find(|(_, n)| n == name)
        .map(|(v, _)| *v)
        .unwrap_or_else(|| panic!("no function {name}"))
}

/// The names of a function's flag attributes.
fn flags(m: &Module, name: &str) -> Vec<Option<&'static str>> {
    m.function_attributes(function(m, name))
        .into_iter()
        .map(|a| match a {
            Attribute::Enum(kind) => attribute_name(*kind),
            _ => None,
        })
        .collect()
}

#[test]
fn the_denormal_mode_is_the_entry_functions_string_attribute() {
    // the listings print `attributes #0 = { "fp32-denorm-mode"="preserve" }` on `define void @main() #0`, and no
    // attribute list on the function compiled without the option
    for (name, expected) in [
        ("denorm.any.ps.dxil", Some("any")),
        ("denorm.preserve.ps.dxil", Some("preserve")),
        ("denorm.ftz.ps.dxil", Some("ftz")),
        ("denorm.default.ps.dxil", None),
    ] {
        let m = module(name);
        assert_eq!(
            reflection::fp32_denorm_mode(&m).unwrap().as_deref(),
            expected,
            "{name}"
        );
    }
    let m = module("denorm.preserve.ps.dxil");
    let main = reflection::entry(&m).unwrap();
    assert_eq!(
        m.function_attributes(main),
        [&Attribute::String("fp32-denorm-mode".into(), "preserve".into())]
    );
    assert_eq!(m.string_attribute(main, "fp32-denorm-mode"), Some("preserve"));
    assert_eq!(m.string_attribute(main, "disable-tail-calls"), None);
    let m = module("denorm.default.ps.dxil");
    let main = reflection::entry(&m).unwrap();
    assert!(m.function_attributes(main).is_empty());
    assert!(matches!(m.values[main], Value::Function { attributes: None, .. }));
}

#[test]
fn the_declared_operations_carry_their_flag_attributes() {
    // `declare float @dx.op.loadInput.f32(...) #1` with `#1 = { nounwind readnone }`, `storeOutput` `#2 = { nounwind }`
    let m = module("denorm.preserve.ps.dxil");
    assert_eq!(
        flags(&m, "dx.op.loadInput.f32"),
        [Some("nounwind"), Some("readnone")]
    );
    assert_eq!(flags(&m, "dx.op.storeOutput.f32"), [Some("nounwind")]);
    // the barrier is `#1 = { noduplicate nounwind }` and the handle creation `#2 = { nounwind readonly }`
    let m = module("barrier.cs.dxil");
    assert_eq!(
        flags(&m, "dx.op.barrier"),
        [Some("noduplicate"), Some("nounwind")]
    );
    assert_eq!(
        flags(&m, "dx.op.createHandle"),
        [Some("nounwind"), Some("readonly")]
    );
    // the kinds the listings confirm have names, the others none: skate.'s `define void @...(%struct.InstanceIdPayload*
    // noalias nocapture %payload)` is the group [9, 11] in the slot of the first parameter, and a `noreturn nounwind`
    // function the group [17, 18] in the function slot
    assert_eq!(attribute_name(9), Some("noalias"));
    assert_eq!(attribute_name(11), Some("nocapture"));
    assert_eq!(attribute_name(17), Some("noreturn"));
    assert_eq!(attribute_name(39), Some("nonnull"));
    assert_eq!(attribute_name(10), None);
}

#[test]
fn an_attribute_group_keeps_its_slot() {
    // the ray generation fixture's `declare void @llvm.lifetime.start(i64, i8* nocapture) #0`: nocapture sits in the
    // slot of the second parameter, the function attributes in the function slot
    let m = module("ray_tracing.raygen.dxil");
    let groups: Vec<(u64, Vec<Attribute>)> = m
        .attribute_groups
        .iter()
        .map(|g| (g.slot, g.attributes.clone()))
        .collect();
    assert!(groups.contains(&(2, vec![Attribute::Enum(11)])));
    assert!(groups.contains(&(
        dxil_reader::module::FUNCTION_SLOT,
        vec![Attribute::Enum(18), Attribute::Enum(20)]
    )));
    // every list names groups the module has
    for list in &m.attribute_lists {
        for id in list {
            assert!(m.attribute_groups.iter().any(|g| g.id == *id));
        }
    }
}

/// The attachments of a function's instructions as (instruction index, kind name) pairs.
fn attached(m: &Module, function: usize) -> Vec<(usize, String)> {
    m.functions[function]
        .instructions
        .iter()
        .enumerate()
        .flat_map(|(i, inst)| {
            inst.attachments
                .iter()
                .map(move |a| (i, m.kind_name(a.kind).unwrap().to_owned()))
        })
        .collect()
}

#[test]
fn the_metadata_attached_to_instructions_is_kept() {
    // the listing of hints.hlsl (58 instructions) prints `!llvm.loop` on the 24th instruction line, the loop's back
    // edge, and `!dx.controlflow.hints` on the 31st, the `[branch]` condition
    let m = module("hints.ps.dxil");
    assert_eq!(m.functions[0].instructions.len(), 58);
    assert_eq!(
        attached(&m, 0),
        [
            (23, "llvm.loop".to_owned()),
            (30, "dx.controlflow.hints".to_owned())
        ]
    );
    // the hints attachment is `distinct !{!22, !"dx.controlflow.hints", i32 1}`: a node naming itself, a string, an integer
    let inst = &m.functions[0].instructions[30];
    assert!(!inst.precise);
    let node = m.attachment(&inst.attachments, "dx.controlflow.hints").unwrap();
    let Metadata::Node(ops) = &m.metadata[node] else {
        panic!("{:?}", m.metadata[node]);
    };
    assert_eq!(ops.len(), 3);
    assert_eq!(ops[0], Some(node));
    assert_eq!(
        m.metadata[ops[1].unwrap()],
        Metadata::String(b"dx.controlflow.hints".to_vec())
    );
    let Metadata::Value { value, .. } = &m.metadata[ops[2].unwrap()] else {
        panic!("not a value");
    };
    assert_eq!(m.values[*value], Value::Constant(Constant::Integer(1)));
    assert_eq!(m.attachment(&inst.attachments, "llvm.loop"), None);
    // nothing is attached to the function itself
    assert!(m.functions[0].attachments.is_empty());
    // the store of the amplification program is the sixth instruction of its listing and carries `!tbaa`
    let m = module("amplify.as.dxil");
    assert_eq!(attached(&m, 0), [(5, "tbaa".to_owned())]);
}

#[test]
fn the_precise_marker_is_one_of_the_attachments() {
    // precise.vs.dxil: `!dx.precise` on the instructions 1 to 4 (precise.rs), now also as attachments
    let m = module("precise.vs.dxil");
    let kind = m.precise_kind.unwrap();
    assert_eq!(m.kind_name(kind), Some("dx.precise"));
    for (i, inst) in m.functions[0].instructions.iter().enumerate() {
        let has = inst.attachments.iter().any(|a: &Attachment| a.kind == kind);
        assert_eq!(has, inst.precise, "instruction {i}");
        assert_eq!(has, (1..=4).contains(&i), "instruction {i}");
    }
    // the fixed LLVM kinds are named in every module
    for (id, name) in [
        (0, "dbg"),
        (1, "tbaa"),
        (4, "range"),
        (7, "alias.scope"),
        (8, "noalias"),
    ] {
        assert_eq!(m.kind_name(id), Some(name));
    }
    assert_eq!(m.kind_name(u64::MAX), None);
}

#[test]
fn the_properties_of_the_entry_point_are_listed_as_stored() {
    let tags = |name: &str| -> Vec<i64> {
        reflection::entry_properties(&module(name))
            .unwrap()
            .iter()
            .map(|p| p.tag)
            .collect()
    };
    // `!{i32 0, i64 524304, i32 4, !{32, 1, 1}, i32 11, !{32}}`
    assert_eq!(tags("wave_size.cs.dxil"), [0, 4, 11]);
    // `!{i32 10, !{!{8, 1, 1}, i32 20}}`
    assert_eq!(tags("amplify.as.dxil"), [10]);
    // `!{i32 8, i32 10, i32 6, i32 20, i32 7, i32 8, i32 5, !{i32 0}}`
    assert_eq!(tags("ray_tracing.closest_hit.dxil"), [8, 6, 7, 5]);
    assert_eq!(tags("ray_tracing.raygen.dxil"), [8, 5]);
    assert_eq!(tags("precise.cs.dxil"), [0, 4]);
    // the vertex program states none
    assert_eq!(tags("precise.vs.dxil"), Vec::<i64>::new());
}

#[test]
fn a_required_wave_size_and_an_amplification_state_are_read() {
    // wave_size.hlsl: `[WaveSize(32)] [numthreads(32, 1, 1)]`; the PSV0 part states 32 and 32 as the lowest and highest
    // lane counts
    let m = module("wave_size.cs.dxil");
    assert_eq!(reflection::wave_size(&m).unwrap(), Some(vec![32]));
    assert_eq!(reflection::num_threads(&m).unwrap(), Some([32, 1, 1]));
    assert_eq!(reflection::shader_flags(&m).unwrap(), Some(524_304));
    assert_eq!(reflection::amplification_payload_size(&m).unwrap(), None);
    let bytes = std::fs::read(
        std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures/wave_size.cs.dxil"),
    )
    .unwrap();
    let chunks = dxil_reader::parts(&bytes).unwrap();
    let psv = dxil_reader::psv::part(&chunks).unwrap().unwrap();
    assert_eq!([psv.runtime.min_wave_lanes, psv.runtime.max_wave_lanes], [32, 32]);
    // amplify.hlsl: eight threads, a payload of a float4 and a uint (20 bytes); the PSV0 part states the 20 as the first
    // word of its stage data and the thread group
    let m = module("amplify.as.dxil");
    assert_eq!(reflection::num_threads(&m).unwrap(), Some([8, 1, 1]));
    assert_eq!(reflection::amplification_payload_size(&m).unwrap(), Some(20));
    assert_eq!(reflection::wave_size(&m).unwrap(), None);
    let bytes = std::fs::read(
        std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures/amplify.as.dxil"),
    )
    .unwrap();
    let chunks = dxil_reader::parts(&bytes).unwrap();
    let psv = dxil_reader::psv::part(&chunks).unwrap().unwrap();
    assert_eq!(psv.runtime.stage_words[0], 20);
    assert_eq!(psv.runtime.num_threads, Some([8, 1, 1]));
    // a program that states neither
    let m = module("precise.cs.dxil");
    assert_eq!(reflection::wave_size(&m).unwrap(), None);
    assert_eq!(reflection::amplification_payload_size(&m).unwrap(), None);
}

#[test]
fn a_ray_tracing_entry_states_its_payload_and_attribute_sizes() {
    // the listings: closest hit `6, 20, 7, 8` (a 20-byte payload and the 8 bytes of the triangle's barycentrics), any hit
    // the same, miss `6, 20`, callable `6, 4`, ray generation and intersection neither
    for (name, payload, attributes, kind) in [
        ("ray_tracing.closest_hit.dxil", Some(20), Some(8), 10),
        ("ray_tracing.any_hit.dxil", Some(20), Some(8), 9),
        ("ray_tracing.miss.dxil", Some(20), None, 11),
        ("ray_tracing.callable.dxil", Some(4), None, 12),
        ("ray_tracing.raygen.dxil", None, None, 7),
        ("ray_tracing.intersection.dxil", None, None, 8),
    ] {
        let m = module(name);
        assert_eq!(reflection::ray_payload_size(&m).unwrap(), payload, "{name}");
        assert_eq!(reflection::ray_attribute_size(&m).unwrap(), attributes, "{name}");
        assert_eq!(reflection::library_kind(&m).unwrap(), kind, "{name}");
    }
}

#[test]
fn the_auto_binding_space_is_stated_by_the_function_and_by_the_library_record() {
    // default: the function's record states `5, !{i32 0}` and the library's own record (no function) states none
    let m = module("ray_tracing.closest_hit.dxil");
    assert_eq!(reflection::auto_binding_space(&m).unwrap(), Some(0));
    assert_eq!(reflection::library_binding_space(&m).unwrap(), None);
    // compiled with -auto-binding-space 3: the library's record states `i32 5, !{i32 3}`, the function's is unchanged
    let m = module("ray_tracing.closest_hit.space3.dxil");
    assert_eq!(reflection::auto_binding_space(&m).unwrap(), Some(0));
    assert_eq!(reflection::library_binding_space(&m).unwrap(), Some(3));
    // a program that is not a library has no such record
    let m = module("wave_size.cs.dxil");
    assert_eq!(reflection::auto_binding_space(&m).unwrap(), None);
    assert_eq!(reflection::library_binding_space(&m).unwrap(), None);
}

#[test]
fn the_tail_tags_of_signature_elements_are_typed() {
    use reflection::ElementTags;
    let usage = |mask| ElementTags {
        usage_mask: Some(mask),
        ..ElementTags::default()
    };
    // streams.hlsl, the listing's elements: the inputs `{3, 15}` and `{3, 3}`; the outputs of stream 0 `{3, 15}` and
    // `{3, 3}`, those of stream 1 `{0, 1, 3, 15}` and `{0, 1, 3, 1}` (tag 0 the stream, tag 3 the usage mask)
    let [inputs, outputs, patch] = reflection::element_tags(&module("streams.gs.dxil")).unwrap();
    assert_eq!(inputs, [usage(15), usage(3)]);
    let stream_one = |mask| ElementTags {
        stream: Some(1),
        usage_mask: Some(mask),
        ..ElementTags::default()
    };
    assert_eq!(outputs, [usage(15), usage(3), stream_one(15), stream_one(1)]);
    assert!(patch.is_empty());
    // dynidx.hlsl: `float4 a[3]` indexed with a run-time value: `{2, 15, 3, 15}`
    let [inputs, outputs, _] = reflection::element_tags(&module("dynidx.ps.dxil")).unwrap();
    assert_eq!(
        inputs,
        [
            ElementTags {
                dynamic_index_mask: Some(15),
                usage_mask: Some(15),
                ..ElementTags::default()
            },
            usage(1)
        ]
    );
    assert_eq!(outputs, [usage(15)]);
    // the usage masks are the same lists as before
    let [inputs, outputs, patch] = reflection::usage_masks(&module("streams.gs.dxil")).unwrap();
    assert_eq!(inputs, [Some(15), Some(3)]);
    assert_eq!(outputs, [Some(15), Some(3), Some(15), Some(1)]);
    assert!(patch.is_empty());
}

#[test]
fn the_optional_fields_of_resource_records_are_read() {
    let m = module("extras.ps.dxil");
    let extras = reflection::resource_extras(&m).unwrap();
    // in the order of `ranges`: the SRVs, the UAVs, the constant buffer, the samplers
    let ranges = reflection::ranges(&m).unwrap();
    assert_eq!(extras.len(), ranges.len());
    for (e, (r, ..)) in extras.iter().zip(&ranges) {
        assert_eq!((e.class, e.id), (r.class, r.id));
    }
    // the listing's records:
    //   !6  SRV 0 Texture2DMS<float4, 4>      `..., i32 3, i32 4, !{i32 0, i32 9}`   sample count 4
    //   !8  SRV 1 Texture2D<float4>           `..., i32 2, i32 0, !{i32 0, i32 9}`   sample count 0
    //   !9  SRV 2 StructuredBuffer<uint2>     `..., i32 12, i32 0, !{i32 1, i32 8}`  stride 8
    //   !12 UAV 0 globallycoherent RWBuffer   `..., i32 10, i1 true, i1 false, i1 false, !{i32 0, i32 5}`
    //   !14 UAV 1 RasterizerOrdered           `..., i32 2, i1 false, i1 false, i1 true, !{i32 0, i32 9}`
    //   !15 UAV 2 RWByteAddressBuffer         `..., i32 11, i1 false, i1 false, i1 false, !{i32 3, i32 1}`
    //   !17 UAV 3 RWStructuredBuffer<float>   `..., i32 12, i1 false, i1 true, i1 false, !{i32 1, i32 4}` (counter)
    //   !20 CBV 0, !22 and !23 the samplers: no tag list
    let srv = |i: usize| (&extras[i].sample_count, &extras[i].tags);
    assert_eq!(srv(0), (&Some(4), &vec![(0, 9)]));
    assert_eq!(srv(1), (&Some(0), &vec![(0, 9)]));
    assert_eq!(srv(2), (&Some(0), &vec![(1, 8)]));
    let uav = |i: usize| {
        let e = &extras[i];
        (
            e.globally_coherent,
            e.rasterizer_ordered,
            e.atomic64,
            e.sample_count,
        )
    };
    assert_eq!(uav(3), (true, false, false, None));
    assert_eq!(uav(4), (false, true, false, None));
    assert_eq!(uav(5), (false, false, true, None));
    assert_eq!(uav(6), (false, false, false, None));
    assert_eq!(extras[5].tags, [(3, 1)]);
    assert_eq!(extras[6].tags, [(1, 4)]);
    // the unordered-access view with the hidden counter is the one `Range::counter` flags
    assert!(ranges[6].0.counter && !ranges[3].0.counter);
    assert_eq!(extras[6].sampler_feedback, None);
    for e in &extras[7..] {
        assert!(
            e.tags.is_empty() && e.sample_count.is_none() && !e.atomic64,
            "{e:?}"
        );
    }
    assert_eq!(extras.len(), 10);
}
