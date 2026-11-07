//! The stream as a whole: versions, comments and the constant table, `END`, framing in a larger buffer, and malformed
//! or truncated input, which is refused at the word where it goes wrong and never panics.
mod common;

use common::*;
use d3d9_reader::{Stage, Version, frame, read};

#[test]
fn every_version_the_reader_names_is_read_and_others_are_refused() {
    let read_ones = [
        (0xfffe_0100, "vs_1_0"),
        (0xfffe_0101, "vs_1_1"),
        (0xfffe_0200, "vs_2_0"),
        (0xfffe_0201, "vs_2_x"),
        (0xfffe_02ff, "vs_2_sw"),
        (0xfffe_0300, "vs_3_0"),
        (0xfffe_03ff, "vs_3_sw"),
        (0xffff_0100, "ps_1_0"),
        (0xffff_0101, "ps_1_1"),
        (0xffff_0102, "ps_1_2"),
        (0xffff_0103, "ps_1_3"),
        (0xffff_0104, "ps_1_4"),
        (0xffff_0200, "ps_2_0"),
        (0xffff_0201, "ps_2_x"),
        (0xffff_0300, "ps_3_0"),
    ];
    for (token, name) in read_ones {
        let p = read(&program(token, &[])).unwrap();
        assert_eq!(
            (p.version.to_string(), p.version.token()),
            (name.to_owned(), token)
        );
        assert_eq!(Version::from_token(token), Some(p.version));
        assert!(p.items.is_empty());
        assert_eq!(p.end, 1);
    }
    assert_eq!(Version::from_token(0xffff_0300).unwrap().stage, Stage::Pixel);
    for token in [
        0xfffe_0102,
        0xffff_0105,
        0xffff_0202,
        0xfffe_0400,
        0xfffd_0300,
        0x4658_0000,
        0,
    ] {
        let (word, why) = refusal(&program(token, &[]));
        assert_eq!(word, 0);
        assert!(why.contains("version token"), "{token:#x}: {why}");
    }
    assert!(read(&[]).unwrap_err().detail.contains("no version token"));
}

#[test]
fn end_must_close_the_stream_exactly() {
    let mut trailing = program(0xffff_0300, &[]);
    trailing.extend([0; 4]);
    assert_eq!(refusal(&trailing), (2, "1 words after END".to_owned()));
    let missing: Vec<u8> = [0xffff_0300u32, 0]
        .into_iter()
        .flat_map(u32::to_le_bytes)
        .collect();
    let (_, why) = refusal(&missing);
    assert!(
        why.contains("extends past") || why.contains("missing END"),
        "{why}"
    );
    assert!(
        read(&[0, 3, 255, 255, 255])
            .unwrap_err()
            .detail
            .contains("not whole words")
    );
}

/// A CTAB comment for `version` with one float4[count] constant `Tint` at c`register` and its default, the strings
/// after the default.
fn ctab(version: u32, register: u16, count: u16) -> Vec<u32> {
    let strings = 64 + u32::from(count) * 16;
    // header: size, creator, version, constants, constant info, flags, target
    let mut bytes: Vec<u8> = [28u32, strings, version, 1, 28, 0x0000_0100, strings + 9]
        .into_iter()
        .flat_map(u32::to_le_bytes)
        .collect();
    // constant info at 28: name, register set (float4) and register, count, reserved, type, default
    bytes.extend((strings + 4).to_le_bytes());
    bytes.extend([2u16, register, count, 0].into_iter().flat_map(u16::to_le_bytes));
    bytes.extend([48u32, 64].into_iter().flat_map(u32::to_le_bytes));
    // type at 48: vector, float, 1 row, 4 columns, count elements, no members
    bytes.extend([1u16, 3, 1, 4, count, 0].into_iter().flat_map(u16::to_le_bytes));
    bytes.extend(0u32.to_le_bytes());
    // default at 64: a row of 16 bytes per register
    bytes.extend((0..u32::from(count) * 4).flat_map(|n| (n as f32).to_le_bytes()));
    bytes.extend(b"fxc\0Tint\0ps_3_0\0");
    while !bytes.len().is_multiple_of(4) {
        bytes.push(0);
    }
    let words: Vec<u32> = std::iter::once(u32::from_le_bytes(*b"CTAB"))
        .chain(bytes.as_chunks::<4>().0.iter().copied().map(u32::from_le_bytes))
        .collect();
    [vec![0xfffe | (words.len() as u32) << 16], words].concat()
}

#[test]
fn the_constant_table_is_read_with_its_words() {
    let bytes = program(
        0xffff_0300,
        &[vec![0x0001_fffe, 0x1234_5678], ctab(0xffff_0300, 2, 2)],
    );
    let p = read(&bytes).unwrap();
    assert_eq!(p.comments().count(), 2);
    assert_eq!(p.comments().next().unwrap().data, [0x1234_5678]);
    let table = p.constants.unwrap();
    assert_eq!((table.creator.as_str(), table.target.as_str()), ("fxc", "ps_3_0"));
    assert_eq!((table.version, table.flags), (0xffff_0300, 0x100));
    let c = &table.constants[0];
    assert_eq!(
        (c.name.as_str(), c.register_set, c.register, c.count),
        ("Tint", 2, 2, 2)
    );
    assert_eq!(
        (c.ty.class, c.ty.kind, c.ty.rows, c.ty.columns, c.ty.elements),
        (1, 3, 1, 4, 2)
    );
    assert_eq!(c.default.as_ref().map(Vec::len), Some(32));
    // the second comment's token is word 3, its FourCC 4, the header 5; the constant record is 28 bytes in
    assert_eq!(c.word, 5 + 28 / 4);
    // bank sizes are the device's and the version's: c250 + 10 is read
    let wide = read(&program(0xffff_0300, &[ctab(0xffff_0300, 250, 10)]));
    assert!(wide.is_ok(), "{wide:?}");

    let crossed = program(0xffff_0300, &[ctab(0xfffe_0300, 2, 2)]);
    assert!(
        refusal(&crossed)
            .1
            .contains("CTAB version disagrees with the program's")
    );
    let empty = program(0xffff_0300, &[ctab(0xffff_0300, 2, 0)]);
    assert!(refusal(&empty).1.contains("is empty"));
    let twice = program(0xffff_0300, &[ctab(0xffff_0300, 2, 2), ctab(0xffff_0300, 2, 2)]);
    assert!(refusal(&twice).1.contains("duplicate CTAB"));
}

#[test]
fn frame_finds_end_by_reading_and_leaves_the_rest() {
    // a comment and a definition holding END-shaped words, the real END, then other bytes
    let body = [
        vec![0x0002_fffe, 0xffff, 0x1234],
        op(81, &[dst(CONST, 0, 15), 0xffff, 0, 0, 0]),
    ];
    let mut bytes = program(0xfffe_0300, &body);
    let length = bytes.len();
    bytes.extend([0xbe, 0xef, 1]);
    let (p, span) = frame(&bytes).unwrap();
    assert_eq!(span, &bytes[..length]);
    assert_eq!(p.end, length / 4 - 1);
    assert!(read(&bytes).is_err());
    for n in 0..length {
        assert!(frame(&bytes[..n]).is_err(), "accepted the prefix of {n} bytes");
    }
}

#[test]
fn malformed_tokens_are_refused_at_their_word() {
    let mov = |destination: u32, source: u32| op(1, &[destination, source]);
    let cases = [
        // an operand without bit 31
        (mov(0x000f_0000, src(CONST, 0, 0xe4, 0)), 2, "lacks bit 31"),
        // register type 16 (D3DSPR_TEMPFLOAT16, never used) and 20
        (
            mov(dst(TEMP, 0, 15), src(16, 0, 0xe4, 0)),
            3,
            "register type 16 is not a Direct3D 9 register type",
        ),
        (
            mov(dst(TEMP, 0, 15), src(20, 0, 0xe4, 0)),
            3,
            "register type 20 is not a Direct3D 9 register type",
        ),
        // a source modifier past 13, a result modifier bit 23, a shift that is none of x2 to x8 and d2 to d8
        (
            mov(dst(TEMP, 0, 15), src(CONST, 0, 0xe4, 14)),
            3,
            "source modifier 14",
        ),
        (
            mov(dst(TEMP, 0, 15) | 8 << 20, src(CONST, 0, 0xe4, 0)),
            2,
            "result modifier bit 23",
        ),
        (
            mov(dst(TEMP, 0, 15) | 5 << 24, src(CONST, 0, 0xe4, 0)),
            2,
            "result shift 5",
        ),
        // the stated length disagrees with the operands
        (
            [
                vec![1 | 3 << 24],
                vec![dst(TEMP, 0, 15), src(CONST, 0, 0xe4, 0), 0],
            ]
            .concat(),
            1,
            "states 3 operand tokens",
        ),
        // the instruction token's reserved bits
        (
            [
                vec![1 | 2 << 24 | 1 << 29],
                vec![dst(TEMP, 0, 15), src(CONST, 0, 0xe4, 0)],
            ]
            .concat(),
            1,
            "reserved bit 29",
        ),
        // a relative source without its token, and one whose token is not a0 or aL
        (
            mov(dst(TEMP, 0, 15), src(CONST, 0, 0xe4, 0) | 0x2000),
            3,
            "without its address token",
        ),
        (
            op(
                1,
                &[
                    dst(TEMP, 0, 15),
                    src(CONST, 0, 0xe4, 0) | 0x2000,
                    src(TEMP, 0, 0, 0),
                ],
            ),
            4,
            "where it is the address register a0 or the loop counter aL",
        ),
        (
            op(
                1,
                &[
                    dst(TEMP, 0, 15),
                    src(CONST, 0, 0xe4, 0) | 0x2000,
                    src(LOOP, 0, 0, 1),
                ],
            ),
            4,
            "has source modifier 1",
        ),
        // definitions name their own bank
        (op(81, &[dst(CONSTINT, 0, 15), 0, 0, 0, 0]), 2, "def defines"),
        (op(48, &[dst(CONST, 0, 15), 0, 0, 0, 0]), 2, "defi defines"),
        // a declaration's texture type, usage and reserved bits
        (
            op(31, &[0x8800_0000, dst(SAMPLER, 0, 15)]),
            2,
            "DCL sampler texture type",
        ),
        (op(31, &[0x8000_000e, dst(INPUT, 0, 15)]), 2, "DCL usage 14"),
        (
            op(31, &[0x8000_0100, dst(INPUT, 0, 15)]),
            2,
            "DCL semantic reserved bits",
        ),
        (op(31, &[0x0000_0000, dst(INPUT, 0, 15)]), 2, "lacks bit 31"),
        // comments: the reserved bit, and a span past the stream
        (vec![0x8000_fffe], 1, "COMMENT reserved bit"),
        (vec![0x7fff_fffe], 1, "span"),
        // an instruction span past the stream
        (vec![0x0f00_0001], 1, "extends past the stream"),
    ];
    for (body, word, wanted) in cases {
        let (at, why) = refusal(&program(0xfffe_0300, &[body]));
        assert!(why.contains(wanted), "expected {wanted}: {why}");
        assert_eq!(at, word, "{why}");
    }
}

#[test]
fn every_truncation_and_bit_flip_is_read_or_refused_without_a_panic() {
    let programs = [
        program(
            0xfffe_0300,
            &[
                op(31, &[0x8000_0000, dst(OUTPUT, 0, 15)]),
                op(27, &[src(LOOP, 0, 0xe4, 0), src(CONSTINT, 0, 0xe4, 0)]),
                op(
                    1,
                    &[
                        dst(OUTPUT, 0, 15) | 0x2000,
                        src(LOOP, 0, 0xe4, 0),
                        src(CONST, 0, 0xe4, 0) | 0x2000,
                        src(ADDR, 0, 0, 0),
                    ],
                ),
                op(29, &[]),
                ctab(0xfffe_0300, 2, 2),
            ],
        ),
        program(
            0xffff_0104,
            &[
                op1(66, &[dst(TEMP, 0, 15), src(TEXTURE, 0, 0xe4, 0)]),
                vec![0xfffd],
                [vec![0x4000_0001], vec![dst(TEMP, 0, 8), src(CONST, 0, 0xaa, 0)]].concat(),
            ],
        ),
    ];
    for bytes in programs {
        assert!(read(&bytes).is_ok());
        for n in 0..bytes.len() {
            assert!(read(&bytes[..n]).is_err());
            let _ = frame(&bytes[..n]);
        }
        for at in 0..bytes.len() {
            for bit in 0..8 {
                let mut changed = bytes.clone();
                changed[at] ^= 1 << bit;
                let _ = read(&changed);
                let _ = frame(&changed);
            }
        }
    }
}

#[test]
fn malformed_streams_microsoft_lists_as_garbage_are_refused() {
    // Microsoft's disassembler lists each of these without validating it; the reader refuses each at the word that
    // breaks it. The comment one word short leaves its last word to be read as the instruction after it: Microsoft
    // reads the dcl's usage token 0x80000005 as `mul v0.xyz`, its bit 31 ignored; it lists opcodes 43776 and 49 as
    // `???`, and version 0xffff02fe as `ps_2_254`
    let cases: [(&[u32], usize, &str); 4] = [
        (
            &[
                0xffff_0300,
                0x0001_fffe,
                0x0200_001f,
                0x8000_0005,
                0x9007_0000,
                0xffff,
            ],
            3,
            "instruction token 0x80000005 sets reserved bit 29 or 31",
        ),
        (
            &[0xfffe_0300, 0x0000_ab00, 0xffff],
            1,
            "opcode 43776 is not a Direct3D 9 instruction",
        ),
        (
            &[0xffff_03ff, 0x0000_0031, 0xffff],
            1,
            "opcode 49 is not a Direct3D 9 instruction",
        ),
        (
            &[0xffff_02fe, 0xffff],
            0,
            "version token 0xffff02fe is not a Direct3D 9 vertex (0xfffe) or pixel (0xffff) program of version 1.0 to 3.0",
        ),
    ];
    for (words, word, wanted) in cases {
        let bytes: Vec<u8> = words.iter().flat_map(|w| w.to_le_bytes()).collect();
        let (at, why) = refusal(&bytes);
        assert_eq!((at, why.as_str()), (word, wanted));
    }
}

#[test]
fn a_debug_line_table_that_does_not_follow_the_program_is_refused() {
    // fxc writes a line record for each declaration, definition and instruction, in stream order, with its byte
    // offset. Microsoft's disassembler lists a table that breaks this by no one rule: the first record's offset past
    // the program drops every note and `#line`, the last one's drops its `#line` and keeps its note, two records'
    // offsets swapped drop the first's `#line`, and an offset a byte off keeps its note
    let path = concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/tests/disasm/debug.tinted.ps20.od.bin"
    );
    let original = std::fs::read(path).unwrap();
    let word = |bytes: &[u8], n: usize| u32::from_le_bytes(bytes[4 * n..4 * n + 4].try_into().unwrap());
    // the DBUG comment's offsets are from the word after its FourCC (word 2); header word 6 is the line table's offset
    assert_eq!(&original[8..12], b"DBUG");
    let table = 3 + word(&original, 3 + 6) as usize / 4;
    // record n's offset is its second word
    let offset = |n: usize| table + 2 * n + 1;
    read(&original).unwrap();
    let edited = |edits: &[(usize, u32)]| {
        let mut bytes = original.clone();
        for &(n, value) in edits {
            bytes[4 * n..4 * n + 4].copy_from_slice(&value.to_le_bytes());
        }
        refusal(&bytes)
    };
    let (dcl, texld) = (word(&original, offset(0)), word(&original, offset(2)));
    let mul = word(&original, offset(3));
    assert_eq!(
        edited(&[(offset(0), 0x3300_0000 | dcl)]),
        (
            dcl as usize / 4,
            format!(
                "DBUG line record 0 has offset {:#x}, where its record starts at {dcl:#x}",
                0x3300_0000 | dcl
            )
        )
    );
    assert_eq!(
        edited(&[(offset(2), mul), (offset(3), texld)]),
        (
            texld as usize / 4,
            format!("DBUG line record 2 has offset {mul:#x}, where its record starts at {texld:#x}")
        )
    );
    assert_eq!(
        edited(&[(offset(0), dcl + 1)]).1,
        format!(
            "DBUG line record 0 has offset {:#x}, where its record starts at {dcl:#x}",
            dcl + 1
        )
    );
}
