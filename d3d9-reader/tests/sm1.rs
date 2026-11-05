//! Shader Model 1: instructions that state no length, the pixel 1.x texture registers and texture-addressing
//! instructions, co-issue, result shifts, the 1.x source modifiers, the 1.4 phase, and a vertex 1.1 program's `a0.x`
//! index with no token of its own.
mod common;

use common::*;
use d3d9_reader::{
    Declared, Item, Literal, Modifier, Opcode, Register, RegisterType, Relative, Stage, Version, read,
};

#[test]
fn vertex_1_1_reads_declarations_outputs_and_the_implicit_a0_index() {
    let bytes = program(
        0xfffe_0101,
        &[
            // dcl_position v0; dcl_normal v1
            op1(31, &[0x8000_0000, dst(INPUT, 0, 15)]),
            op1(31, &[0x8000_0003, dst(INPUT, 1, 15)]),
            // def c95, 0.5, 1, 2, 0
            op1(
                81,
                &[dst(CONST, 95, 15), 0x3f00_0000, 0x3f80_0000, 0x4000_0000, 0],
            ),
            // m4x4 oPos, v0, c0
            op1(
                20,
                &[
                    dst(RASTOUT, 0, 15),
                    src(INPUT, 0, 0xe4, 0),
                    src(CONST, 0, 0xe4, 0),
                ],
            ),
            // mov a0.x, v1.x
            op1(1, &[dst(ADDR, 0, 1), src(INPUT, 1, 0x00, 0)]),
            // mul oD0, v1, c[a0.x + 10]
            op1(
                5,
                &[
                    dst(ATTROUT, 0, 15),
                    src(INPUT, 1, 0xe4, 0),
                    src(CONST, 10, 0xe4, 0) | 0x2000,
                ],
            ),
            // mov oD1, -v1.zyxw
            op1(1, &[dst(ATTROUT, 1, 15), src(INPUT, 1, 0xc6, 1)]),
            // expp r1, v1.w; lit r2, r1; dst r3, r1, r2
            op1(78, &[dst(TEMP, 1, 15), src(INPUT, 1, 0xff, 0)]),
            op1(16, &[dst(TEMP, 2, 15), src(TEMP, 1, 0xe4, 0)]),
            op1(
                17,
                &[dst(TEMP, 3, 15), src(TEMP, 1, 0xe4, 0), src(TEMP, 2, 0xe4, 0)],
            ),
            // mov oFog, r1.x; mov oPts, c95.y; mov oT0.xy, v1
            op1(1, &[dst(RASTOUT, 1, 15), src(TEMP, 1, 0x00, 0)]),
            op1(1, &[dst(RASTOUT, 2, 15), src(CONST, 95, 0x55, 0)]),
            op1(1, &[dst(OUTPUT, 0, 3), src(INPUT, 1, 0xe4, 0)]),
        ],
    );
    let p = read(&bytes).unwrap();
    assert_eq!(
        p.version,
        Version {
            stage: Stage::Vertex,
            major: 1,
            minor: 1
        }
    );
    assert_eq!(p.version.to_string(), "vs_1_1");
    let usages: Vec<_> = p.declarations().map(|d| d.declared).collect();
    assert_eq!(
        usages,
        [
            Declared::Semantic { usage: 0, index: 0 },
            Declared::Semantic { usage: 3, index: 0 }
        ]
    );
    let def = p.definitions().next().unwrap();
    assert_eq!(
        def.literal,
        Literal::Float([0x3f00_0000, 0x3f80_0000, 0x4000_0000, 0])
    );
    let ops: Vec<_> = p.instructions().map(|i| i.opcode).collect();
    use Opcode::*;
    assert_eq!(ops, [M4x4, Mov, Mul, Mov, ExpP, Lit, Dst, Mov, Mov, Mov]);
    let mul = p.instructions().nth(2).unwrap();
    assert_eq!(
        mul.sources[1].relative,
        Some(Relative {
            word: None,
            register: Register {
                kind: RegisterType::Address,
                number: 0
            },
            swizzle: [0; 4]
        })
    );
    assert_eq!(mul.sources[1].register.number, 10);
    let neg = p.instructions().nth(3).unwrap();
    assert_eq!(neg.sources[0].modifier, Modifier::Negate);
    assert_eq!(neg.sources[0].swizzle, [2, 1, 0, 3]);
    let outs: Vec<_> = p
        .instructions()
        .filter_map(|i| i.destination)
        .map(|d| (d.register.kind, d.register.number, d.mask))
        .collect();
    assert!(outs.contains(&(RegisterType::RasterizerOut, 1, 15)));
    assert!(outs.contains(&(RegisterType::RasterizerOut, 2, 15)));
    assert!(outs.contains(&(RegisterType::Output, 0, 3)));
    // the word of every record is where its token is
    assert_eq!(p.items.first().map(Item::word), Some(1));
    assert_eq!(p.end, bytes.len() / 4 - 1);
}

#[test]
fn pixel_1_1_reads_texture_registers_coissue_shift_and_modifiers() {
    let bytes = program(
        0xffff_0101,
        &[
            // def c0, 0.5, 0.25, 1, 1
            op1(
                81,
                &[
                    dst(CONST, 0, 15),
                    0x3f00_0000,
                    0x3e80_0000,
                    0x3f80_0000,
                    0x3f80_0000,
                ],
            ),
            // tex t0; texbem t1, t0; texcoord t2
            op1(66, &[dst(TEXTURE, 0, 15)]),
            op1(67, &[dst(TEXTURE, 1, 15), src(TEXTURE, 0, 0xe4, 0)]),
            op1(64, &[dst(TEXTURE, 2, 15)]),
            // mul r0.rgb, t0, v0 / +mov r0.a, t1.a
            op1(
                5,
                &[dst(TEMP, 0, 7), src(TEXTURE, 0, 0xe4, 0), src(INPUT, 0, 0xe4, 0)],
            ),
            [vec![0x4000_0001], vec![dst(TEMP, 0, 8), src(TEXTURE, 1, 0xff, 0)]].concat(),
            // mad_x2 r1, t1_bx2, c0, v1_bias
            op1(
                4,
                &[
                    dst(TEMP, 1, 15) | 1 << 24,
                    src(TEXTURE, 1, 0xe4, 4),
                    src(CONST, 0, 0xe4, 0),
                    src(INPUT, 1, 0xe4, 2),
                ],
            ),
            // sub_d2 r1.rgb, 1-r1, -v0 (Microsoft's assembler encodes _d2 as 15, _d4 as 14)
            op1(
                3,
                &[
                    dst(TEMP, 1, 7) | 15 << 24,
                    src(TEMP, 1, 0xe4, 6),
                    src(INPUT, 0, 0xe4, 1),
                ],
            ),
            // cnd r0, r0.a, t2, r1
            op1(
                80,
                &[
                    dst(TEMP, 0, 15),
                    src(TEMP, 0, 0xff, 0),
                    src(TEXTURE, 2, 0xe4, 0),
                    src(TEMP, 1, 0xe4, 0),
                ],
            ),
        ],
    );
    let p = read(&bytes).unwrap();
    assert_eq!(p.version.to_string(), "ps_1_1");
    let i: Vec<_> = p.instructions().collect();
    assert_eq!(i[0].opcode, Opcode::Tex);
    assert!(i[0].sources.is_empty());
    assert_eq!(i[0].destination.unwrap().register.kind, RegisterType::Texture);
    assert_eq!(i[1].opcode, Opcode::TexBem);
    assert_eq!(i[2].opcode, Opcode::TexCoord);
    assert!(!i[3].coissue && i[4].coissue);
    assert_eq!(i[4].destination.unwrap().mask, 8);
    assert_eq!(i[5].destination.unwrap().shift, 1);
    assert_eq!(
        i[5].sources.iter().map(|s| s.modifier).collect::<Vec<_>>(),
        [Modifier::Sign, Modifier::None, Modifier::Bias]
    );
    assert_eq!(i[6].destination.unwrap().shift, -1);
    assert_eq!(i[6].sources[0].modifier, Modifier::Complement);
    assert_eq!(i[7].opcode, Opcode::Cnd);
    assert_eq!(i[7].sources.len(), 3);
}

#[test]
fn pixel_1_3_reads_the_texture_matrix_instructions() {
    let bytes = program(
        0xffff_0103,
        &[
            op1(66, &[dst(TEXTURE, 0, 15)]),
            // texm3x3pad t1, t0_bx2; texm3x3pad t2, t0_bx2; texm3x3spec t3, t0_bx2, c0
            op1(73, &[dst(TEXTURE, 1, 15), src(TEXTURE, 0, 0xe4, 4)]),
            op1(73, &[dst(TEXTURE, 2, 15), src(TEXTURE, 0, 0xe4, 4)]),
            op1(
                76,
                &[
                    dst(TEXTURE, 3, 15),
                    src(TEXTURE, 0, 0xe4, 4),
                    src(CONST, 0, 0xe4, 0),
                ],
            ),
            // texm3x2depth (1.3 only) after a texm3x2pad
            op1(71, &[dst(TEXTURE, 1, 15), src(TEXTURE, 0, 0xe4, 0)]),
            op1(84, &[dst(TEXTURE, 2, 15), src(TEXTURE, 0, 0xe4, 0)]),
            // mul_x4 r0, t3, v0; texkill t0
            op1(
                5,
                &[
                    dst(TEMP, 0, 15) | 2 << 24,
                    src(TEXTURE, 3, 0xe4, 0),
                    src(INPUT, 0, 0xe4, 0),
                ],
            ),
            op1(65, &[dst(TEXTURE, 0, 15)]),
        ],
    );
    let p = read(&bytes).unwrap();
    let ops: Vec<_> = p.instructions().map(|i| (i.opcode, i.sources.len())).collect();
    use Opcode::*;
    assert_eq!(
        ops,
        [
            (Tex, 0),
            (TexM3x3Pad, 1),
            (TexM3x3Pad, 1),
            (TexM3x3Spec, 2),
            (TexM3x2Pad, 1),
            (TexM3x2Depth, 1),
            (Mul, 2),
            (TexKill, 0)
        ]
    );
    assert_eq!(p.instructions().nth(6).unwrap().destination.unwrap().shift, 2);
    // texm3x2depth is 1.3 only
    let mut older = bytes.clone();
    older[..4].copy_from_slice(&0xffff_0102u32.to_le_bytes());
    let (word, why) = refusal(&older);
    assert_eq!(word, 16);
    assert!(
        why.contains("texm3x2depth (opcode 84) is not an instruction of ps_1_2"),
        "{why}"
    );
}

#[test]
fn pixel_1_4_reads_texld_texcrd_bem_phase_and_texdepth() {
    let bytes = program(
        0xffff_0104,
        &[
            // texld r0, t0; texcrd r1.rgb, t1_dw.xyw
            op1(66, &[dst(TEMP, 0, 15), src(TEXTURE, 0, 0xe4, 0)]),
            op1(64, &[dst(TEMP, 1, 7), src(TEXTURE, 1, 0xf4, 10)]),
            // bem r2.rg, c0, r0
            op1(
                89,
                &[dst(TEMP, 2, 3), src(CONST, 0, 0xe4, 0), src(TEMP, 0, 0xe4, 0)],
            ),
            vec![0xfffd],
            // texld r3, r2; texld r4, r1_dz.xyz; texdepth r5
            op1(66, &[dst(TEMP, 3, 15), src(TEMP, 2, 0xe4, 0)]),
            op1(66, &[dst(TEMP, 4, 15), src(TEMP, 1, 0xa4, 9)]),
            op1(87, &[dst(TEMP, 5, 15)]),
            // mul_x4_sat r0, r3, v0 / cmp r0.rgb, r0, c0, r4 / +mov r0.a, c0.b
            op1(
                5,
                &[
                    dst(TEMP, 0, 15) | 2 << 24 | 1 << 20,
                    src(TEMP, 3, 0xe4, 0),
                    src(INPUT, 0, 0xe4, 0),
                ],
            ),
            op1(
                88,
                &[
                    dst(TEMP, 0, 7),
                    src(TEMP, 0, 0xe4, 0),
                    src(CONST, 0, 0xe4, 0),
                    src(TEMP, 4, 0xe4, 0),
                ],
            ),
            [vec![0x4000_0001], vec![dst(TEMP, 0, 8), src(CONST, 0, 0xaa, 0)]].concat(),
            // dp3_d2 r1, r0_bx2, c0
            op1(
                8,
                &[
                    dst(TEMP, 1, 15) | 15 << 24,
                    src(TEMP, 0, 0xe4, 4),
                    src(CONST, 0, 0xe4, 0),
                ],
            ),
        ],
    );
    let p = read(&bytes).unwrap();
    let ops: Vec<_> = p.instructions().map(|i| (i.opcode, i.sources.len())).collect();
    use Opcode::*;
    assert_eq!(
        ops,
        [
            (Tex, 1),
            (TexCoord, 1),
            (Bem, 2),
            (Phase, 0),
            (Tex, 1),
            (Tex, 1),
            (TexDepth, 0),
            (Mul, 2),
            (Cmp, 3),
            (Mov, 1),
            (Dp3, 2)
        ]
    );
    let i: Vec<_> = p.instructions().collect();
    assert_eq!(i[1].sources[0].modifier, Modifier::DivideW);
    assert_eq!(i[5].sources[0].modifier, Modifier::DivideZ);
    let d = i[7].destination.unwrap();
    assert_eq!((d.shift, d.saturate), (2, true));
    assert!(i[9].coissue);
    // phase is 1.4's only, and is the bare token
    let mut phase = bytes.clone();
    phase[..4].copy_from_slice(&0xffff_0103u32.to_le_bytes());
    assert!(read(&phase).is_err());
    let at = 4 * p.instructions().nth(3).unwrap().word;
    let mut flagged = bytes.clone();
    flagged[at + 3] = 0x40;
    assert!(refusal(&flagged).1.contains("phase token"));
}

#[test]
fn shader_model_1_lengths_are_the_opcode_table_s_or_the_stated_one() {
    // a 1.x instruction may state its length; it must then be its operands'
    let stated = program(
        0xfffe_0101,
        &[op(
            2,
            &[dst(TEMP, 0, 15), src(INPUT, 0, 0xe4, 0), src(INPUT, 1, 0xe4, 0)],
        )],
    );
    assert_eq!(read(&stated).unwrap().instructions().count(), 1);
    let wrong = program(
        0xfffe_0101,
        &[[
            vec![2 | 2 << 24],
            vec![dst(TEMP, 0, 15), src(INPUT, 0, 0xe4, 0), src(INPUT, 1, 0xe4, 0)],
        ]
        .concat()],
    );
    let (word, why) = refusal(&wrong);
    assert_eq!(word, 1);
    assert!(
        why.contains("states 2 operand tokens, where its operands take 3"),
        "{why}"
    );
    // a token missing at the end of the stream: the operand reading runs into END's word and past it
    let short = program(
        0xfffe_0101,
        &[op1(2, &[dst(TEMP, 0, 15), src(INPUT, 0, 0xe4, 0)])],
    );
    assert!(read(&short).is_err());
}

#[test]
fn shader_model_1_has_no_flow_control_samplers_or_relative_pixel_operands() {
    let cases = [
        // rep in a vertex 1.1 program
        (
            program(0xfffe_0101, &[op1(38, &[src(CONSTINT, 0, 0xe4, 0)])]),
            "not an instruction of vs_1_1",
        ),
        // a sampler register in a pixel 1.4 program
        (
            program(
                0xffff_0104,
                &[op1(66, &[dst(TEMP, 0, 15), src(SAMPLER, 0, 0xe4, 0)])],
            ),
            "register type 10 is not a register of ps_1_4",
        ),
        // the relative flag in a pixel 1.x program
        (
            program(
                0xffff_0101,
                &[op1(1, &[dst(TEMP, 0, 15), src(CONST, 0, 0xe4, 0) | 0x2000])],
            ),
            "relative addressing in a pixel 1.x program",
        ),
        // predication before 2.x
        (
            program(
                0xfffe_0101,
                &[op1(1 | 1 << 28, &[dst(TEMP, 0, 15), src(INPUT, 0, 0xe4, 0)])],
            ),
            "predication in vs_1_1",
        ),
        // co-issue in a vertex program
        (
            program(
                0xfffe_0101,
                &[op1(1 | 1 << 30, &[dst(TEMP, 0, 15), src(INPUT, 0, 0xe4, 0)])],
            ),
            "co-issue outside a pixel 1.x program",
        ),
        // a result shift the token format does not define
        (
            program(
                0xffff_0101,
                &[op1(1, &[dst(TEMP, 0, 15) | 5 << 24, src(INPUT, 0, 0xe4, 0)])],
            ),
            "result shift 5",
        ),
        // a pixel-only instruction in a vertex program
        (
            program(
                0xfffe_0101,
                &[op1(
                    80,
                    &[
                        dst(TEMP, 0, 15),
                        src(INPUT, 0, 0xe4, 0),
                        src(INPUT, 0, 0xe4, 0),
                        src(INPUT, 0, 0xe4, 0),
                    ],
                )],
            ),
            "cnd (opcode 80) is a pixel instruction, not one of vs_1_1",
        ),
    ];
    for (bytes, wanted) in cases {
        let (_, why) = refusal(&bytes);
        assert!(why.contains(wanted), "expected {wanted}: {why}");
    }
}
