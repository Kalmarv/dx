#![allow(clippy::unwrap_used)]
//! The typed views of an opcode token's control bits. The fixtures are Microsoft's fxc output for the HLSL beside each
//! (`controls.hlsl`, `geometry_decls.hlsl`, `pixel_flags.hlsl`, and the committed tessellation and compute fixtures);
//! every expected value is read off the listing of Microsoft's disassembler for the same container (the `[precise(x)]`
//! annotations, the `_uint` and `_g_t` suffixes, `dcl_globalFlags refactoringAllowed | forceEarlyDepthStencil`,
//! `dcl_inputprimitive triangle`, `dcl_maxout 4`, `dcl_hs_max_tessfactor l(16.000000)`, ...).
use dxbc_reader::{Decoded, GlobalFlags, InfoReturn, SyncFlags, decode};
use std::path::Path;

fn program(name: &str) -> Decoded {
    let path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures")
        .join(name);
    let bytes = std::fs::read(path).unwrap();
    decode(&dxbc_reader::code(&bytes).unwrap()).unwrap()
}

fn flags(program: &Decoded) -> Vec<GlobalFlags> {
    program
        .declarations
        .iter()
        .filter_map(|d| d.global_flags())
        .collect()
}

#[test]
fn the_precise_mask_the_sync_flags_and_the_size_query_type_are_read_from_the_control_bits() {
    let p = program("controls.cs.dxbc");
    // the listing: `ld_structured_indexable [precise(x)]`, `mul [precise(x)]`, `iadd [precise(y)]`,
    // `ld_structured_indexable [precise(y)]`, `add [precise(x)]`, and no other instruction is marked
    let precise: Vec<(&str, u8)> = p
        .instructions
        .iter()
        .filter(|i| i.precise_mask() != 0)
        .map(|i| (i.name(), i.precise_mask()))
        .collect();
    assert_eq!(
        precise,
        [
            ("ld_structured", 1),
            ("mul", 1),
            ("iadd", 2),
            ("ld_structured", 2),
            ("add", 1)
        ]
    );
    // the listing: `sync_uglobal`, `sync_uglobal_g`, `sync_uglobal_g_t`, `sync_g`
    let sync = |threads_in_group, group_shared_memory, uav_group, uav_global| SyncFlags {
        threads_in_group,
        group_shared_memory,
        uav_group,
        uav_global,
    };
    let syncs: Vec<SyncFlags> = p.instructions.iter().filter_map(|i| i.sync_flags()).collect();
    assert_eq!(
        syncs,
        [
            sync(false, false, false, true),
            sync(false, true, false, true),
            sync(true, true, false, true),
            sync(false, true, false, false)
        ]
    );
    // the listing: `resinfo_indexable(texture2d)(...)_uint` then `resinfo_indexable(texture2d)(...)`
    let info: Vec<Option<InfoReturn>> = p
        .instructions
        .iter()
        .filter(|i| i.name() == "resinfo")
        .map(|i| i.info_return())
        .collect();
    assert_eq!(info, [Some(InfoReturn::Uint), Some(InfoReturn::Float)]);
    // an instruction of another opcode has none of them
    let add = p.instructions.iter().find(|i| i.name() == "add").unwrap();
    assert_eq!((add.sync_flags(), add.info_return()), (None, None));
    let sync_instruction = p.instructions.iter().find(|i| i.name() == "sync").unwrap();
    assert_eq!(sync_instruction.info_return(), None);
    assert_eq!(sync_instruction.precise_mask(), 0);
    // the listing's `dcl_globalFlags refactoringAllowed`
    assert_eq!(
        flags(&p),
        [GlobalFlags {
            refactoring_allowed: true,
            ..GlobalFlags::default()
        }]
    );
}

#[test]
fn a_sample_count_query_and_the_global_flags_of_the_pixel_programs() {
    // `sampleinfo o0.x, rasterizer.x` (a float) and `resinfo_indexable(texture2dms)(...)_uint`
    let p = program("pixel_flags.samples.dxbc");
    let sample_info = p.instructions.iter().find(|i| i.name() == "sample_info").unwrap();
    assert_eq!(sample_info.info_return(), Some(InfoReturn::Float));
    let resinfo = p.instructions.iter().find(|i| i.name() == "resinfo").unwrap();
    assert_eq!(resinfo.info_return(), Some(InfoReturn::Uint));
    // the listings' `dcl_globalFlags` lines
    let early = flags(&program("pixel_flags.early.dxbc"));
    assert_eq!(
        early,
        [GlobalFlags {
            refactoring_allowed: true,
            force_early_depth_stencil: true,
            ..GlobalFlags::default()
        }]
    );
    let doubles = flags(&program("pixel_flags.doubles.dxbc"));
    assert_eq!(
        doubles,
        [GlobalFlags {
            refactoring_allowed: true,
            double_precision: true,
            ..GlobalFlags::default()
        }]
    );
    // `refactoringAllowed | enableMinimumPrecision`, and `| skipOptimization` of the /Od compile
    let min16 = flags(&program("min16_patch.hs.dxbc"));
    assert_eq!(
        min16,
        [GlobalFlags {
            refactoring_allowed: true,
            minimum_precision: true,
            ..GlobalFlags::default()
        }]
    );
    let unoptimized = flags(&program("compute_basic.od.dxbc"));
    assert_eq!(
        unoptimized,
        [GlobalFlags {
            refactoring_allowed: true,
            skip_optimization: true,
            ..GlobalFlags::default()
        }]
    );
    // the bits above 5 are kept
    assert_eq!(GlobalFlags::from_bits(0x1c0 | 8).other, 7);
    assert!(GlobalFlags::from_bits(0x1c0 | 8).raw_and_structured_buffers);
}

#[test]
fn the_geometry_declarations_are_typed() {
    // `dcl_inputprimitive triangle` (3), `dcl_outputtopology trianglestrip` (5), `dcl_maxout 4`
    let p = program("geometry_decls.gs.dxbc");
    let find = |f: fn(&dxbc_reader::Declaration) -> Option<u32>| -> Vec<u32> {
        p.declarations.iter().filter_map(f).collect()
    };
    assert_eq!(find(|d| d.geometry_input_primitive()), [3]);
    assert_eq!(find(|d| d.geometry_output_topology()), [5]);
    assert_eq!(find(|d| d.max_output_vertex_count()), [4]);
    assert!(find(|d| d.tessellator_domain()).is_empty());
    assert!(find(|d| d.input_control_point_count()).is_empty());
}

#[test]
fn the_tessellation_declarations_are_typed() {
    let find = |p: &Decoded, f: fn(&dxbc_reader::Declaration) -> Option<u32>| -> Vec<u32> {
        p.declarations.iter().filter_map(f).collect()
    };
    // the hull listing: three input and three output control points, `domain_tri` (2), `partitioning_integer` (1),
    // `output_triangle_cw` (3), `dcl_hs_max_tessfactor l(16.000000)`, and one `dcl_hs_fork_phase_instance_count 2`
    let hs = program("tessellation.hs.dxbc");
    assert_eq!(find(&hs, |d| d.input_control_point_count()), [3]);
    assert_eq!(find(&hs, |d| d.output_control_point_count()), [3]);
    assert_eq!(find(&hs, |d| d.tessellator_domain()), [2]);
    assert_eq!(find(&hs, |d| d.tessellator_partitioning()), [1]);
    assert_eq!(find(&hs, |d| d.tessellator_output_primitive()), [3]);
    assert_eq!(find(&hs, |d| d.fork_phase_instance_count()), [2]);
    assert!(find(&hs, |d| d.join_phase_instance_count()).is_empty());
    let factors: Vec<f32> = hs
        .declarations
        .iter()
        .filter_map(|d| d.hull_max_tess_factor())
        .collect();
    assert_eq!(factors, [16.0]);
    // the domain listing: three input control points and `domain_tri`
    let ds = program("tessellation.ds.dxbc");
    assert_eq!(find(&ds, |d| d.input_control_point_count()), [3]);
    assert_eq!(find(&ds, |d| d.tessellator_domain()), [2]);
    assert!(find(&ds, |d| d.tessellator_partitioning()).is_empty());
    // the other hull fixture: `l(64.000000)` and `dcl_hs_fork_phase_instance_count 3`
    let phases = program("hull_phases.hs.dxbc");
    let factors: Vec<f32> = phases
        .declarations
        .iter()
        .filter_map(|d| d.hull_max_tess_factor())
        .collect();
    assert_eq!(factors, [64.0]);
    assert_eq!(find(&phases, |d| d.fork_phase_instance_count()), [3]);
}
