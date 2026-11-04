#![allow(clippy::unwrap_used)]
//! Shader Model 5.1 programs of fxc's own output (the HLSL is beside each fixture): the declarations, operands and
//! texture reads that `fxc -dumpbin` gives for them.
use dxbc_reader::{Declared, Decoded, Register, RegisterRange, decode, opcode_name, texture_reads};
use std::path::Path;

fn program(name: &str) -> Decoded {
    let bytes = std::fs::read(
        Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/fixtures")
            .join(name),
    )
    .unwrap();
    decode(&dxbc_reader::code(&bytes).unwrap()).unwrap()
}

fn range(lower: u32, upper: u32, space: u32) -> Option<RegisterRange> {
    Some(RegisterRange { lower, upper, space })
}

/// Each binding declaration's opcode name, its id and the registers and space it binds.
fn bindings(program: &Decoded) -> Vec<(&'static str, u32, Option<RegisterRange>)> {
    program
        .declarations
        .iter()
        .filter_map(|d| {
            let slot = match d.kind {
                Declared::ConstantBuffer { slot, .. }
                | Declared::Sampler { slot, .. }
                | Declared::Resource { slot, .. }
                | Declared::ResourceRaw { slot, .. }
                | Declared::ResourceStructured { slot, .. }
                | Declared::UavTyped { slot, .. }
                | Declared::UavRaw { slot, .. }
                | Declared::UavStructured { slot, .. } => slot,
                _ => return None,
            };
            Some((opcode_name(d.opcode), slot, d.kind.registers()))
        })
        .collect()
}

#[test]
fn every_binding_declaration_of_shader_model_5_1_reads_its_id_registers_and_space() {
    let cs = program("bindings_sm51.cs.dxbc");
    assert_eq!(cs.target(), "cs_5_1");
    // fxc -dumpbin: CB0[5:5][5] space=0, CB1[0:1][2] space=4, S0[0:0] and S1[1:1] space=1, T0[0:*] space=1, T1 to T4
    // at t2 to t5 in space 2, U0[0:0], U1[1:1] and U2[2:4] in space 3
    assert_eq!(
        bindings(&cs),
        [
            ("dcl_constant_buffer", 0, range(5, 5, 0)),
            ("dcl_constant_buffer", 1, range(0, 1, 4)),
            ("dcl_sampler", 0, range(0, 0, 1)),
            ("dcl_sampler", 1, range(1, 1, 1)),
            ("dcl_resource", 0, range(0, u32::MAX, 1)),
            ("dcl_resource", 1, range(2, 2, 2)),
            ("dcl_resource_raw", 2, range(3, 3, 2)),
            ("dcl_resource_structured", 3, range(4, 4, 2)),
            ("dcl_resource", 4, range(5, 5, 2)),
            ("dcl_unordered_access_view_typed", 0, range(0, 0, 3)),
            ("dcl_unordered_access_view_raw", 1, range(1, 1, 3)),
            ("dcl_unordered_access_view_structured", 2, range(2, 4, 3)),
        ]
    );
    // dcl_globalFlags first, then the bindings in the order above
    let kinds: Vec<&Declared> = cs.declarations.iter().map(|d| &d.kind).collect();
    // the rows are a word of their own in 5.1: CB0[5:5][5] immediateIndexed, CB1[0:1][2] dynamicIndexed
    assert!(matches!(
        kinds[1],
        Declared::ConstantBuffer {
            rows: 5,
            dynamic: false,
            dimensions: 3,
            ..
        }
    ));
    assert!(matches!(
        kinds[2],
        Declared::ConstantBuffer {
            rows: 2,
            dynamic: true,
            dimensions: 3,
            ..
        }
    ));
    assert!(matches!(kinds[4], Declared::Sampler { mode: 1, .. }));
    // dcl_resource_buffer (uint,uint,uint,uint), dcl_resource_structured 32, dcl_uav_structured 32
    assert!(matches!(
        kinds[9],
        Declared::Resource {
            dimension: 1,
            returns: [4, 4, 4, 4],
            ..
        }
    ));
    assert!(matches!(
        kinds[8],
        Declared::ResourceStructured { stride: 32, .. }
    ));
    assert!(matches!(kinds[12], Declared::UavStructured { stride: 32, .. }));

    let ps = program("reflection_sm51.ps51.dxbc");
    assert_eq!(ps.target(), "ps_5_1");
    assert_eq!(
        bindings(&ps),
        [
            ("dcl_constant_buffer", 0, range(1, 1, 2)),
            ("dcl_sampler", 0, range(2, 2, 3)),
            ("dcl_resource", 0, range(3, 3, 1)),
            ("dcl_resource", 1, range(4, 7, 1)),
        ]
    );
}

#[test]
fn a_shader_model_5_1_operand_names_the_id_then_the_register() {
    let cs = program("bindings_sm51.cs.dxbc");
    let bases = |register: Register, n: usize| -> Vec<(u32, bool)> {
        let operand = cs
            .instructions
            .iter()
            .flat_map(|i| &i.operands)
            .filter(|o| o.register == register)
            .nth(n)
            .unwrap();
        operand
            .indices
            .iter()
            .map(|i| (i.base, i.relative.is_some()))
            .collect()
    };
    // mul r0.yz, r0.yyzy, CB1[r0.w + 0][0].xxyx: id 1, register 0 plus r0.w, row 0
    assert_eq!(bases(Register::Constant, 0), [(1, false), (0, true), (0, false)]);
    // sample_c_lz ..., CB0[5][4].x: id 0, register 5, row 4
    assert_eq!(bases(Register::Constant, 1), [(0, false), (5, false), (4, false)]);
    // ld r0.x, vThreadID.xxxx, T4[5]; sample_l ..., T0[r0.x + 0] { nonuniform }, S0[0]
    assert_eq!(bases(Register::Texture, 0), [(4, false), (5, false)]);
    assert_eq!(bases(Register::Texture, 1), [(0, false), (0, true)]);
    assert_eq!(bases(Register::Sampler, 0), [(0, false), (0, false)]);
    // store_uav_typed U0[0], imm_atomic_iadd U1[1], then store_structured U2[r0.x + 2]
    assert_eq!(bases(Register::Uav, 2), [(2, false), (2, true)]);
    let nonuniform: Vec<bool> = cs
        .instructions
        .iter()
        .flat_map(|i| &i.operands)
        .filter(|o| o.register == Register::Texture)
        .map(|o| o.non_uniform)
        .collect();
    assert_eq!(nonuniform, [false, true, false, false, false, false]);
}

#[test]
fn shader_model_5_1_texture_reads_give_the_register_and_space_of_the_declared_range() {
    let reads = |name: &str| -> Vec<String> {
        texture_reads(&program(name))
            .iter()
            .map(|r| {
                format!(
                    "{} t{}{} space {:?} s{:?}{} space {:?} mode {:?}{}",
                    opcode_name(r.opcode),
                    r.texture,
                    if r.texture_indexed { "+" } else { "" },
                    r.texture_space,
                    r.sampler,
                    if r.sampler_indexed { "+" } else { "" },
                    r.sampler_space,
                    r.sampler_mode,
                    if r.comparison { " compares" } else { "" }
                )
            })
            .collect()
    };
    assert_eq!(
        reads("bindings_sm51.cs.dxbc"),
        [
            "ld t5 space Some(2) sNone space None mode None",
            "sample_l t0+ space Some(1) sSome(0) space Some(1) mode Some(0)",
            "sample_c_lz t2 space Some(2) sSome(1) space Some(1) mode Some(1) compares",
            "ld_structured t4 space Some(2) sNone space None mode None",
            "ld_structured t4 space Some(2) sNone space None mode None",
            "ld_raw t3 space Some(2) sNone space None mode None",
        ]
    );
    // sample ..., T0[3], S0[2]; sample ..., T1[r1.x + 4], S0[2]
    assert_eq!(
        reads("reflection_sm51.ps51.dxbc"),
        [
            "sample t3 space Some(1) sSome(2) space Some(3) mode Some(0)",
            "sample t4+ space Some(1) sSome(2) space Some(3) mode Some(0)",
        ]
    );
    // the 5.0 build of the same source: registers in space 0, the array's element declared on its own
    assert_eq!(
        reads("reflection_sm51.ps50.dxbc"),
        [
            "sample t3 space Some(0) sSome(2) space Some(0) mode Some(0)",
            "sample t6 space Some(0) sSome(2) space Some(0) mode Some(0)",
        ]
    );
}
