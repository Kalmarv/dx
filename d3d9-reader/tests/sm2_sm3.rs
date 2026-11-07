//! Shader Model 2 and 3: instructions that state their length, flow control (`loop`, `rep`, `if`, `if_comp`, `break`,
//! `break_comp`, `breakp`, `call`, `callnz`, `label`, `ret`), integer and boolean constants, predication, the loop
//! counter `aL` and the address register's relative-address token, vertex texture fetch, `vPos` and `vFace`, and
//! relatively addressed outputs. Encodings are those Microsoft's assembler writes (Wine's assembler tests compare against
//! it): `c0[a0]` and `[aL]` come with a `.xyzw` address swizzle, `c5[a0.w]` with `.wwww`.
mod common;

use common::*;
use d3d9_reader::{
    Comparison, Declared, Literal, Modifier, Opcode, Precision, Register, RegisterType, Relative,
    TextureType, disassemble, read, records,
};

fn r(kind: RegisterType, number: u32) -> Register {
    Register { kind, number }
}

#[test]
fn vertex_2_0_reads_loops_branches_subroutines_and_constants() {
    let bytes = program(
        0xfffe_0200,
        &[
            // defi i0, 4, 0, 1, 0; defb b0, true
            op(48, &[dst(CONSTINT, 0, 15), 4, 0, 1, 0]),
            op(47, &[dst(CONSTBOOL, 0, 15), 1]),
            // loop aL, i0 / add r0, r0, c10[aL] / endloop
            op(27, &[src(LOOP, 0, 0xe4, 0), src(CONSTINT, 0, 0xe4, 0)]),
            op(
                2,
                &[
                    dst(TEMP, 0, 15),
                    src(TEMP, 0, 0xe4, 0),
                    src(CONST, 10, 0xe4, 0) | 0x2000,
                    src(LOOP, 0, 0xe4, 0),
                ],
            ),
            op(29, &[]),
            // rep i0 / endrep
            op(38, &[src(CONSTINT, 0, 0xe4, 0)]),
            op(39, &[]),
            // if b0 / else / endif
            op(40, &[src(CONSTBOOL, 0, 0xe4, 0)]),
            op(42, &[]),
            op(43, &[]),
            // mova a0.x, v1.x / add r0, r0, c20[a0.x]
            op(46, &[dst(ADDR, 0, 1), src(INPUT, 1, 0x00, 0)]),
            op(
                2,
                &[
                    dst(TEMP, 0, 15),
                    src(TEMP, 0, 0xe4, 0),
                    src(CONST, 20, 0xe4, 0) | 0x2000,
                    src(ADDR, 0, 0x00, 0),
                ],
            ),
            // call l0 / callnz l1, b0 / sincos r1.xy, v1.x, c201, c202 / sgn r2, v1, r3, r4
            op(25, &[src(LABEL, 0, 0xe4, 0)]),
            op(26, &[src(LABEL, 1, 0xe4, 0), src(CONSTBOOL, 0, 0xe4, 0)]),
            op(
                37,
                &[
                    dst(TEMP, 1, 3),
                    src(INPUT, 1, 0x00, 0),
                    src(CONST, 201, 0xe4, 0),
                    src(CONST, 202, 0xe4, 0),
                ],
            ),
            op(
                34,
                &[
                    dst(TEMP, 2, 15),
                    src(INPUT, 1, 0xe4, 0),
                    src(TEMP, 3, 0xe4, 0),
                    src(TEMP, 4, 0xe4, 0),
                ],
            ),
            // ret / label l0 / ret
            op(28, &[]),
            op(30, &[src(LABEL, 0, 0xe4, 0)]),
            op(28, &[]),
        ],
    );
    let p = read(&bytes).unwrap();
    assert_eq!(p.version.to_string(), "vs_2_0");
    let literals: Vec<_> = p
        .definitions()
        .map(|d| (d.destination.register, d.literal))
        .collect();
    assert_eq!(
        literals,
        [
            (r(RegisterType::ConstInt, 0), Literal::Integer([4, 0, 1, 0])),
            (r(RegisterType::ConstBool, 0), Literal::Bool(1))
        ]
    );
    use Opcode::*;
    let ops: Vec<_> = p.instructions().map(|i| i.opcode).collect();
    assert_eq!(
        ops,
        [
            Loop, Add, EndLoop, Rep, EndRep, If, Else, EndIf, Mova, Add, Call, CallNz, SinCos, Sgn, Ret,
            Label, Ret
        ]
    );
    let i: Vec<_> = p.instructions().collect();
    assert_eq!(i[0].sources[0].register, r(RegisterType::Loop, 0));
    assert!(i[0].destination.is_none());
    let indexed = i[1].sources[1];
    assert_eq!(indexed.register, r(RegisterType::Const, 10));
    assert_eq!(
        indexed.relative,
        Some(Relative {
            word: Some(indexed.word + 1),
            register: r(RegisterType::Loop, 0),
            swizzle: [0, 1, 2, 3]
        })
    );
    // the source after a relative one is two words on
    assert_eq!(i[1].sources.len(), 2);
    assert_eq!(
        i[9].sources[1].relative.unwrap().register,
        r(RegisterType::Address, 0)
    );
    assert_eq!(i[9].sources[1].relative.unwrap().swizzle, [0; 4]);
    assert_eq!(i[11].sources[1].register, r(RegisterType::ConstBool, 0));
    // Shader Model 2's sincos and sgn read three sources
    assert_eq!((i[12].sources.len(), i[13].sources.len()), (3, 3));
    assert_eq!(i[15].sources[0].register, r(RegisterType::Label, 0));
}

#[test]
fn vertex_2_x_reads_predication_comparisons_and_breaks() {
    let bytes = program(
        0xfffe_0201,
        &[
            // setp_gt p0, v0, c200.x
            op(
                94 | 1 << 16,
                &[
                    dst(PREDICATE, 0, 15),
                    src(INPUT, 0, 0xe4, 0),
                    src(CONST, 200, 0x00, 0),
                ],
            ),
            // (p0) mov r0, v0 -- the predicate token follows the destination
            op(
                1 | 1 << 28,
                &[
                    dst(TEMP, 0, 15),
                    src(PREDICATE, 0, 0xe4, 0),
                    src(INPUT, 0, 0xe4, 0),
                ],
            ),
            // (!p0.y) add r0, r0, c200
            op(
                2 | 1 << 28,
                &[
                    dst(TEMP, 0, 15),
                    src(PREDICATE, 0, 0x55, 13),
                    src(TEMP, 0, 0xe4, 0),
                    src(CONST, 200, 0xe4, 0),
                ],
            ),
            // if_lt v0.x, c200.y / endif
            op(41 | 4 << 16, &[src(INPUT, 0, 0x00, 0), src(CONST, 200, 0x55, 0)]),
            op(43, &[]),
            // rep i0 / break_ge r1.x, c200.w / breakp p0.x / break / endrep
            op(38, &[src(CONSTINT, 0, 0xe4, 0)]),
            op(45 | 3 << 16, &[src(TEMP, 1, 0x00, 0), src(CONST, 200, 0xff, 0)]),
            op(96, &[src(PREDICATE, 0, 0x00, 0)]),
            op(44, &[]),
            op(39, &[]),
            // callnz l0, !p0.x
            op(26, &[src(LABEL, 0, 0xe4, 0), src(PREDICATE, 0, 0x00, 13)]),
        ],
    );
    let p = read(&bytes).unwrap();
    assert_eq!(p.version.to_string(), "vs_2_x");
    let i: Vec<_> = p.instructions().collect();
    assert_eq!(i[0].comparison(), Some(Comparison::Greater));
    assert_eq!(i[0].destination.unwrap().register, r(RegisterType::Predicate, 0));
    let predicate = i[1].predicate.unwrap();
    assert_eq!(predicate.register, r(RegisterType::Predicate, 0));
    assert_eq!(predicate.word, i[1].word + 2);
    assert_eq!(i[1].sources[0].register, r(RegisterType::Input, 0));
    assert_eq!(i[2].predicate.unwrap().modifier, Modifier::Not);
    assert_eq!(i[2].predicate.unwrap().swizzle, [1; 4]);
    assert_eq!(i[3].comparison(), Some(Comparison::Less));
    assert_eq!(i[6].comparison(), Some(Comparison::GreaterEqual));
    assert_eq!(i[7].opcode, Opcode::BreakP);
    assert_eq!(i[8].opcode, Opcode::Break);
    assert_eq!(i[10].sources[1].modifier, Modifier::Not);
    assert_eq!(i[1].comparison(), None);

    // setp and predication are 2.x's, but a 2.0 program with them is read, as Microsoft's disassembler lists it; a
    // comparison is 1 to 6
    let mut two = bytes.clone();
    two[..4].copy_from_slice(&0xfffe_0200u32.to_le_bytes());
    assert_eq!(
        read(&two)
            .unwrap()
            .instructions()
            .filter(|i| i.predicate.is_some())
            .count(),
        2
    );
    let bad = program(
        0xfffe_0201,
        &[op(41 | 7 << 16, &[src(INPUT, 0, 0, 0), src(INPUT, 0, 0, 0)])],
    );
    assert!(refusal(&bad).1.contains("if_comp has control bits 0x7"));
}

#[test]
fn pixel_2_0_reads_sampler_declarations_texld_variants_and_modifiers() {
    let bytes = program(
        0xffff_0200,
        &[
            // dcl t0.xy; dcl_centroid t1; dcl_pp v0
            op(31, &[0x8000_0000, dst(TEXTURE, 0, 3)]),
            op(31, &[0x8000_0000, dst(TEXTURE, 1, 15) | 4 << 20]),
            op(31, &[0x8000_0000, dst(INPUT, 0, 15) | 2 << 20]),
            // dcl_2d s0; dcl_cube s1; dcl_volume s2
            op(31, &[0x9000_0000, dst(SAMPLER, 0, 15)]),
            op(31, &[0x9800_0000, dst(SAMPLER, 1, 15)]),
            op(31, &[0xa000_0000, dst(SAMPLER, 2, 15)]),
            // texld r0, t0, s0; texldp r1, t1, s1; texldb_pp r2, t1, s2
            op(
                66,
                &[
                    dst(TEMP, 0, 15),
                    src(TEXTURE, 0, 0xe4, 0),
                    src(SAMPLER, 0, 0xe4, 0),
                ],
            ),
            op(
                66 | 1 << 16,
                &[
                    dst(TEMP, 1, 15),
                    src(TEXTURE, 1, 0xe4, 0),
                    src(SAMPLER, 1, 0xe4, 0),
                ],
            ),
            op(
                66 | 2 << 16,
                &[
                    dst(TEMP, 2, 15) | 2 << 20,
                    src(TEXTURE, 1, 0xe4, 0),
                    src(SAMPLER, 2, 0xe4, 0),
                ],
            ),
            // texkill t0; dp2add r3, r0, c0, c0.x; sincos r5.xy, t0.x, c2, c3
            op(65, &[dst(TEXTURE, 0, 15)]),
            op(
                90,
                &[
                    dst(TEMP, 3, 15),
                    src(TEMP, 0, 0xe4, 0),
                    src(CONST, 0, 0xe4, 0),
                    src(CONST, 0, 0, 0),
                ],
            ),
            op(
                37,
                &[
                    dst(TEMP, 5, 3),
                    src(TEXTURE, 0, 0, 0),
                    src(CONST, 2, 0xe4, 0),
                    src(CONST, 3, 0xe4, 0),
                ],
            ),
            // mov_sat oC0, r4; mov oDepth, r3.x
            op(1, &[dst(COLOROUT, 0, 15) | 1 << 20, src(TEMP, 4, 0xe4, 0)]),
            op(1, &[dst(DEPTHOUT, 0, 15), src(TEMP, 3, 0, 0)]),
        ],
    );
    let p = read(&bytes).unwrap();
    let d: Vec<_> = p.declarations().collect();
    assert_eq!(d[0].declared, Declared::Semantic { usage: 0, index: 0 });
    assert_eq!(d[0].destination.mask, 3);
    assert!(d[1].destination.centroid);
    assert!(d[2].destination.partial_precision);
    assert_eq!(
        d[3..].iter().map(|d| d.declared).collect::<Vec<_>>(),
        [TextureType::D2, TextureType::Cube, TextureType::Volume].map(Declared::Sampler)
    );
    let i: Vec<_> = p.instructions().collect();
    assert_eq!(i[..3].iter().map(|i| i.control).collect::<Vec<_>>(), [0, 1, 2]);
    assert!(i[2].destination.unwrap().partial_precision);
    assert_eq!(i[3].opcode, Opcode::TexKill);
    assert_eq!(i[5].sources.len(), 3);
    assert!(i[6].destination.unwrap().saturate);
    assert_eq!(i[7].destination.unwrap().register, r(RegisterType::DepthOut, 0));
    // texld's control is 0 to 2
    let bad = program(
        0xffff_0200,
        &[op(
            66 | 3 << 16,
            &[
                dst(TEMP, 0, 15),
                src(TEXTURE, 0, 0xe4, 0),
                src(SAMPLER, 0, 0xe4, 0),
            ],
        )],
    );
    assert!(refusal(&bad).1.contains("tex has control bits 0x3"));
}

#[test]
fn pixel_2_x_reads_derivatives_and_texldd() {
    let bytes = program(
        0xffff_0201,
        &[
            op(91, &[dst(TEMP, 0, 15), src(TEXTURE, 0, 0xe4, 0)]),
            op(92, &[dst(TEMP, 1, 15), src(TEXTURE, 0, 0xe4, 0)]),
            op(
                93,
                &[
                    dst(TEMP, 2, 15),
                    src(TEXTURE, 0, 0xe4, 0),
                    src(SAMPLER, 0, 0xe4, 0),
                    src(TEMP, 0, 0xe4, 0),
                    src(TEMP, 1, 0xe4, 0),
                ],
            ),
        ],
    );
    let p = read(&bytes).unwrap();
    let ops: Vec<_> = p.instructions().map(|i| (i.opcode, i.sources.len())).collect();
    assert_eq!(ops, [(Opcode::Dsx, 1), (Opcode::Dsy, 1), (Opcode::TexLdd, 4)]);
    // derivatives are 2.x's on, but a 2.0 program with them is read, as Microsoft's disassembler lists it
    let mut older = bytes.clone();
    older[..4].copy_from_slice(&0xffff_0200u32.to_le_bytes());
    assert_eq!(read(&older).unwrap().instructions().count(), 3);
}

#[test]
fn vertex_3_0_reads_texture_fetch_outputs_and_relative_outputs() {
    let bytes = program(
        0xfffe_0300,
        &[
            // dcl_texcoord0 v1; dcl_position o0; dcl_texcoord0 o1.xy; dcl_psize o1.z; dcl_2d s0
            op(31, &[0x8000_0005, dst(INPUT, 1, 15)]),
            op(31, &[0x8000_0000, dst(OUTPUT, 0, 15)]),
            op(31, &[0x8000_0005, dst(OUTPUT, 1, 3)]),
            op(31, &[0x8000_0004, dst(OUTPUT, 1, 4)]),
            op(31, &[0x9000_0000, dst(SAMPLER, 0, 15)]),
            // texldl r0, v1, s0
            op(
                95,
                &[dst(TEMP, 0, 15), src(INPUT, 1, 0xe4, 0), src(SAMPLER, 0, 0xe4, 0)],
            ),
            // sincos r1.xy, v1.x and sgn r2, v1: one source in 3.0
            op(37, &[dst(TEMP, 1, 3), src(INPUT, 1, 0, 0)]),
            op(34, &[dst(TEMP, 2, 15), src(INPUT, 1, 0xe4, 0)]),
            // mov o[aL + 2], v2[aL]
            op(
                1,
                &[
                    dst(OUTPUT, 2, 15) | 0x2000,
                    src(LOOP, 0, 0xe4, 0),
                    src(INPUT, 2, 0xe4, 0) | 0x2000,
                    src(LOOP, 0, 0xe4, 0),
                ],
            ),
            // mov r3, c0[a0.w]
            op(
                1,
                &[
                    dst(TEMP, 3, 15),
                    src(CONST, 0, 0xe4, 0) | 0x2000,
                    src(ADDR, 0, 0xff, 0),
                ],
            ),
            // add_sat r4, -r1_abs, c0
            op(
                2,
                &[
                    dst(TEMP, 4, 15) | 1 << 20,
                    src(TEMP, 1, 0xe4, 12),
                    src(CONST, 0, 0xe4, 0),
                ],
            ),
        ],
    );
    let p = read(&bytes).unwrap();
    let usages: Vec<_> = p
        .declarations()
        .map(|d| (d.declared, d.destination.register, d.destination.mask))
        .collect();
    assert_eq!(
        usages[3],
        (
            Declared::Semantic { usage: 4, index: 0 },
            r(RegisterType::Output, 1),
            4
        )
    );
    assert_eq!(usages[4].0, Declared::Sampler(TextureType::D2));
    let i: Vec<_> = p.instructions().collect();
    assert_eq!(i[0].opcode, Opcode::TexLdl);
    assert_eq!((i[1].sources.len(), i[2].sources.len()), (1, 1));
    let out = i[3].destination.unwrap();
    assert_eq!(out.register, r(RegisterType::Output, 2));
    assert_eq!(out.relative.unwrap().register, r(RegisterType::Loop, 0));
    assert_eq!(
        i[3].sources[0].relative.unwrap().register,
        r(RegisterType::Loop, 0)
    );
    assert_eq!(i[4].sources[0].relative.unwrap().swizzle, [3; 4]);
    assert_eq!(i[5].sources[0].modifier, Modifier::AbsNegate);
    // texld is a pixel instruction, but a vertex 3.0 program with it is read, as Microsoft's disassembler lists it
    let tex = program(
        0xfffe_0300,
        &[op(
            66,
            &[dst(TEMP, 0, 15), src(INPUT, 0, 0xe4, 0), src(SAMPLER, 0, 0xe4, 0)],
        )],
    );
    let i = read(&tex).unwrap().instructions().next().unwrap().clone();
    assert_eq!(
        (i.opcode, i.sources[1].register.kind),
        (Opcode::Tex, RegisterType::Sampler)
    );
}

#[test]
fn pixel_3_0_reads_vpos_vface_input_indexing_and_predicated_sampling() {
    let bytes = program(
        0xffff_0300,
        &[
            // dcl_texcoord0 v0; dcl vPos.xy; dcl vFace; dcl_2d s0
            op(31, &[0x8000_0005, dst(INPUT, 0, 15)]),
            op(31, &[0x8000_0000, dst(MISC, 0, 3)]),
            op(31, &[0x8000_0000, dst(MISC, 1, 15)]),
            op(31, &[0x9000_0000, dst(SAMPLER, 0, 15)]),
            // if_gt vFace, c0.x / endif
            op(41 | 1 << 16, &[src(MISC, 1, 0xe4, 0), src(CONST, 0, 0, 0)]),
            op(43, &[]),
            // loop aL, i0 / add r0, r0, v0[aL] / endloop
            op(27, &[src(LOOP, 0, 0xe4, 0), src(CONSTINT, 0, 0xe4, 0)]),
            op(
                2,
                &[
                    dst(TEMP, 0, 15),
                    src(TEMP, 0, 0xe4, 0),
                    src(INPUT, 0, 0xe4, 0) | 0x2000,
                    src(LOOP, 0, 0xe4, 0),
                ],
            ),
            op(29, &[]),
            // (p0) texld r1, v0, s0
            op(
                66 | 1 << 28,
                &[
                    dst(TEMP, 1, 15),
                    src(PREDICATE, 0, 0xe4, 0),
                    src(INPUT, 0, 0xe4, 0),
                    src(SAMPLER, 0, 0xe4, 0),
                ],
            ),
            // mul r5.xy, vPos, c0.z; mov oC1_pp, r1
            op(
                5,
                &[dst(TEMP, 5, 3), src(MISC, 0, 0xe4, 0), src(CONST, 0, 0xaa, 0)],
            ),
            op(1, &[dst(COLOROUT, 1, 15) | 2 << 20, src(TEMP, 1, 0xe4, 0)]),
        ],
    );
    let p = read(&bytes).unwrap();
    let misc: Vec<_> = p
        .declarations()
        .map(|d| d.destination.register)
        .filter(|r| r.kind == RegisterType::Misc)
        .collect();
    assert_eq!(misc, [r(RegisterType::Misc, 0), r(RegisterType::Misc, 1)]);
    let i: Vec<_> = p.instructions().collect();
    assert_eq!(i[0].sources[0].register, r(RegisterType::Misc, 1));
    assert_eq!(
        i[3].sources[1].relative.unwrap().register,
        r(RegisterType::Loop, 0)
    );
    assert!(i[5].predicate.is_some());
    assert_eq!(i[5].sources.len(), 2);
    // vFace is misc register 1, and there is no 2
    let bad = program(0xffff_0300, &[op(31, &[0x8000_0000, dst(MISC, 2, 15)])]);
    assert!(
        refusal(&bad)
            .1
            .contains("register Misc 2, where the type has registers 0 to 1")
    );
}

#[test]
fn records_stop_at_the_first_refusal_and_keep_what_came_before() {
    let bytes = program(
        0xffff_0300,
        &[
            op(1, &[dst(COLOROUT, 0, 15), src(CONST, 0, 0xe4, 0)]),
            // opcode 75 (the reserved texm3x3diff) is no instruction
            op(75, &[]),
            op(1, &[dst(COLOROUT, 0, 15), src(CONST, 0, 0xe4, 0)]),
        ],
    );
    let mut stream = records(&bytes).unwrap();
    assert_eq!(stream.version().to_string(), "ps_3_0");
    assert!(stream.next().unwrap().is_ok());
    let e = stream.next().unwrap().unwrap_err();
    assert_eq!(
        (e.word, e.detail.as_str()),
        (4, "opcode 75 is not a Direct3D 9 instruction")
    );
    assert!(stream.next().is_none());
    assert_eq!(read(&bytes).unwrap_err().word, 4);
}

/// Bits 14 to 15 of an operand token are its minimum precision (`D3DSP_MIN_PRECISION`), which fxc writes in a feature
/// level 9 program's Direct3D 9 part: on a declared or defined register, a destination and a source; a relative-address
/// or predicate token's mean nothing. The listing is `D3DDisassemble`'s of these tokens.
#[test]
fn minimum_precision_is_read_and_listed_after_the_operand() {
    let precision = |p: u32| p << 14;
    let bytes = program(
        0xfffe_0300,
        &[
            op(31, &[0x8000_0000, dst(INPUT, 0, 15) | precision(1)]),
            op(31, &[0x8000_0000, dst(OUTPUT, 0, 15)]),
            op(
                81,
                &[dst(CONST, 1, 15) | precision(2), 0x3f80_0000, 0, 0, 0x3f80_0000],
            ),
            op(
                1,
                &[
                    dst(TEMP, 0, 15) | precision(1),
                    src(INPUT, 0, 0xe4, 0) | precision(2),
                ],
            ),
            op(46, &[dst(ADDR, 0, 1), src(INPUT, 0, 0, 0)]),
            // the relative-address token's precision is ignored
            op(
                1,
                &[
                    dst(TEMP, 1, 15),
                    src(CONST, 2, 0xe4, 1) | 0x2000 | precision(1),
                    src(ADDR, 0, 0, 0) | precision(3),
                ],
            ),
            op(
                94 | 1 << 16,
                &[
                    dst(PREDICATE, 0, 15),
                    src(INPUT, 0, 0xe4, 0),
                    src(CONST, 1, 0xe4, 0),
                ],
            ),
            // a predicated mov: its predicate's precision is ignored, and 3 names none
            vec![
                1 | 3 << 24 | 1 << 28,
                dst(TEMP, 2, 15) | precision(3),
                src(PREDICATE, 0, 0xe4, 0) | precision(1),
                src(TEMP, 0, 0xe4, 0),
            ],
            op(1, &[dst(OUTPUT, 0, 15), src(TEMP, 0, 0xe4, 0) | precision(2)]),
        ],
    );
    let p = read(&bytes).unwrap();
    let d: Vec<_> = p.declarations().collect();
    assert_eq!(d[0].destination.precision, Precision::Min16);
    let i: Vec<_> = p.instructions().collect();
    assert_eq!(
        (i[0].destination.unwrap().precision, i[0].sources[0].precision),
        (Precision::Min16, Precision::Min2_8)
    );
    assert_eq!(i[4].destination.unwrap().precision, Precision::Unnamed);
    assert_eq!(i[4].predicate.unwrap().precision, Precision::Min16);
    assert_eq!(
        disassemble(&bytes).unwrap(),
        [
            "    vs_3_0",
            "    dcl_position v0 {min16f}",
            "    dcl_position o0",
            "    def c1 {min2_8f}, 1, 0, 0, 1",
            "    mov r0 {min16f}, v0 {min2_8f}",
            "    mova a0.x, v0.x",
            "    mov r1, -c2[a0.x] {min16f}",
            "    setp_gt p0, v0, c1",
            "    (p0) mov r2, r0",
            "    mov o0, r0 {min2_8f}",
            "",
            "// approximately 7 instruction slots used",
            "",
        ]
        .join("\n")
    );
}
