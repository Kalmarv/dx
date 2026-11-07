#![allow(clippy::unwrap_used)]
//! Properties of the bitstream reader and the disassembler over generated inputs, at a fixed number of cases so a run
//! takes the same time on every machine.
//!
//! - A bitstream written by the writer here (LLVM's bitstream format, as its writer emits it: nested blocks, defined
//!   abbreviations of literal, fixed, VBR, array, char6 and blob operands, and unabbreviated records) reads back as the
//!   blocks and records it was written from, each at the bit it was written at.
//! - Any change to a part of a committed program (`tests/fixtures`) is listed or refused, never a panic, and listing
//!   the same bytes twice gives the same text (the listing's tables are hash maps, whose order differs from one map to
//!   the next).
use std::path::{Path, PathBuf};
use std::sync::OnceLock;

use dxil_reader::bitstream::{self, Block, Element, Record};
use dxil_reader::disasm::disassemble;
use proptest::prelude::*;
use proptest::sample::Index;
use proptest::strategy::ValueTree;
use proptest::test_runner::TestRunner;

/// Bits, least significant first, as LLVM's bitstream writer emits them.
#[derive(Default)]
struct Bits {
    bytes: Vec<u8>,
    len: usize,
}
impl Bits {
    fn put(&mut self, mut value: u64, width: u32) {
        for _ in 0..width {
            if self.len.is_multiple_of(8) {
                self.bytes.push(0);
            }
            *self.bytes.last_mut().unwrap() |= ((value & 1) as u8) << (self.len % 8);
            value >>= 1;
            self.len += 1;
        }
    }
    fn vbr(&mut self, mut value: u64, width: u32) {
        let high = 1u64 << (width - 1);
        while value >= high {
            self.put((value & (high - 1)) | high, width);
            value >>= width - 1;
        }
        self.put(value, width);
    }
    fn align32(&mut self) {
        while !self.len.is_multiple_of(32) {
            self.put(0, 1);
        }
    }
    /// Overwrites the 32-bit word at bit `at` (a multiple of 32).
    fn set_word(&mut self, at: usize, value: u32) {
        self.bytes[at / 8..at / 8 + 4].copy_from_slice(&value.to_le_bytes());
    }
}

/// An abbreviation operand.
#[derive(Clone, Copy, Debug)]
enum Op {
    Literal(u64),
    Fixed(u32),
    Vbr(u32),
    Char6,
}

const CHAR6: &[u8; 64] = b"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._";

/// A record of an abbreviation: its code, its scalar operands, its array's elements and its blob.
type Written = (u64, Vec<u64>, Vec<u64>, Vec<u8>);

/// What a generated block holds.
#[derive(Clone, Debug)]
enum Item {
    /// An unabbreviated record: its code and operands.
    Plain(u64, Vec<u64>),
    /// An abbreviation (its code operand, its scalar operands, and optionally an array of one element encoding or a
    /// blob) defined here, then records of it.
    Abbreviated {
        code: Op,
        scalars: Vec<Op>,
        tail: Tail,
        records: Vec<Written>,
    },
    Block(Gen),
}

#[derive(Clone, Copy, Debug)]
enum Tail {
    None,
    Array(Op),
    Blob,
}

/// A generated block: its id, abbreviation width and items.
#[derive(Clone, Debug)]
struct Gen {
    id: u64,
    width: u32,
    items: Vec<Item>,
}

fn scalar_op() -> impl Strategy<Value = Op> {
    prop_oneof![
        (0u64..1 << 20).prop_map(Op::Literal),
        (1u32..=24).prop_map(Op::Fixed),
        (2u32..=24).prop_map(Op::Vbr),
        Just(Op::Char6),
    ]
}

/// A value an operand of `op` can hold, from `seed`.
fn value(op: Op, seed: u64) -> u64 {
    match op {
        Op::Literal(v) => v,
        Op::Fixed(w) => seed & ((1u64 << w) - 1),
        Op::Vbr(_) => seed & 0xffff_ffff,
        Op::Char6 => u64::from(CHAR6[(seed % 64) as usize]),
    }
}

fn item(depth: u32) -> BoxedStrategy<Item> {
    let plain =
        (0u64..1 << 16, proptest::collection::vec(0u64..1 << 40, 0..6)).prop_map(|(c, o)| Item::Plain(c, o));
    let tail = prop_oneof![
        Just(Tail::None),
        scalar_op().prop_map(Tail::Array),
        Just(Tail::Blob)
    ];
    let abbreviated = (
        scalar_op(),
        proptest::collection::vec(scalar_op(), 0..4),
        tail,
        proptest::collection::vec(
            (
                any::<u64>(),
                proptest::collection::vec(any::<u64>(), 4),
                proptest::collection::vec(any::<u64>(), 0..5),
                proptest::collection::vec(any::<u8>(), 0..9),
            ),
            0..3,
        ),
    )
        .prop_map(|(code, scalars, tail, seeds)| {
            let records = seeds
                .into_iter()
                .map(|(c, s, a, blob)| {
                    let element = match tail {
                        Tail::Array(op) => op,
                        _ => Op::Literal(0),
                    };
                    (
                        value(code, c),
                        scalars
                            .iter()
                            .zip(&s)
                            .map(|(op, seed)| value(*op, *seed))
                            .collect(),
                        a.iter().map(|seed| value(element, *seed)).collect(),
                        blob,
                    )
                })
                .collect();
            Item::Abbreviated {
                code,
                scalars,
                tail,
                records,
            }
        });
    if depth == 0 {
        prop_oneof![plain, abbreviated].boxed()
    } else {
        prop_oneof![3 => plain, 2 => abbreviated, 1 => block(depth - 1).prop_map(Item::Block)].boxed()
    }
}

fn block(depth: u32) -> impl Strategy<Value = Gen> {
    // no block id 0, BLOCKINFO, whose records define other blocks' abbreviations; widths that hold the ids of the
    // abbreviations defined (at most three per item list here, so 4 + 6 ids fit in 4 bits)
    (8u64..64, 4u32..=7, proptest::collection::vec(item(depth), 0..6)).prop_map(|(id, width, items)| Gen {
        id,
        width,
        items,
    })
}

fn put_op(bits: &mut Bits, op: Op) {
    match op {
        Op::Literal(v) => {
            bits.put(1, 1);
            bits.vbr(v, 8);
        }
        Op::Fixed(w) => {
            bits.put(0, 1);
            bits.put(1, 3);
            bits.vbr(u64::from(w), 5);
        }
        Op::Vbr(w) => {
            bits.put(0, 1);
            bits.put(2, 3);
            bits.vbr(u64::from(w), 5);
        }
        Op::Char6 => {
            bits.put(0, 1);
            bits.put(4, 3);
        }
    }
}

fn put_value(bits: &mut Bits, op: Op, v: u64) {
    match op {
        Op::Literal(_) => {}
        Op::Fixed(w) => bits.put(v, w),
        Op::Vbr(w) => bits.vbr(v, w),
        Op::Char6 => bits.put(CHAR6.iter().position(|&c| u64::from(c) == v).unwrap() as u64, 6),
    }
}

/// Writes `g` (its ENTER_SUBBLOCK in a block of abbreviation width `outer`) and returns the block the reader must
/// read.
fn write_block(bits: &mut Bits, g: &Gen, outer: u32) -> Block {
    let at = bits.len;
    bits.put(1, outer);
    bits.vbr(g.id, 8);
    bits.vbr(u64::from(g.width), 4);
    bits.align32();
    let length_at = bits.len;
    bits.put(0, 32);
    let mut elements = Vec::new();
    let mut next_abbrev = 4;
    for item in &g.items {
        match item {
            Item::Plain(code, operands) => {
                let here = bits.len;
                bits.put(3, g.width);
                bits.vbr(*code, 6);
                bits.vbr(operands.len() as u64, 6);
                for o in operands {
                    bits.vbr(*o, 6);
                }
                elements.push(Element::Record(Record {
                    code: *code,
                    operands: operands.clone(),
                    blob: None,
                    at: here,
                }));
            }
            Item::Abbreviated {
                code,
                scalars,
                tail,
                records,
            } => {
                let ops = 1
                    + scalars.len()
                    + match tail {
                        Tail::None => 0,
                        Tail::Array(_) => 2,
                        Tail::Blob => 1,
                    };
                bits.put(2, g.width);
                bits.vbr(ops as u64, 5);
                put_op(bits, *code);
                for op in scalars {
                    put_op(bits, *op);
                }
                match tail {
                    Tail::None => {}
                    Tail::Array(element) => {
                        bits.put(0, 1);
                        bits.put(3, 3);
                        put_op(bits, *element);
                    }
                    Tail::Blob => {
                        bits.put(0, 1);
                        bits.put(5, 3);
                    }
                }
                let id = next_abbrev;
                next_abbrev += 1;
                for (c, values, array, blob) in records {
                    let here = bits.len;
                    bits.put(id, g.width);
                    put_value(bits, *code, *c);
                    for (op, v) in scalars.iter().zip(values) {
                        put_value(bits, *op, *v);
                    }
                    let mut operands = values.clone();
                    let mut stored_blob = None;
                    match tail {
                        Tail::None => {}
                        Tail::Array(element) => {
                            bits.vbr(array.len() as u64, 6);
                            for v in array {
                                put_value(bits, *element, *v);
                            }
                            operands.extend(array);
                        }
                        Tail::Blob => {
                            bits.vbr(blob.len() as u64, 6);
                            bits.align32();
                            for b in blob {
                                bits.put(u64::from(*b), 8);
                            }
                            bits.align32();
                            stored_blob = Some(blob.clone());
                        }
                    }
                    elements.push(Element::Record(Record {
                        code: *c,
                        operands,
                        blob: stored_blob,
                        at: here,
                    }));
                }
            }
            Item::Block(child) => {
                let b = write_block(bits, child, g.width);
                elements.push(Element::Block(b));
            }
        }
    }
    bits.put(0, g.width);
    bits.align32();
    let words = (bits.len - length_at - 32) / 32;
    bits.set_word(length_at, words as u32);
    Block {
        id: g.id,
        elements,
        at,
    }
}

proptest! {
    #![proptest_config(ProptestConfig { cases: 512, failure_persistence: None, ..ProptestConfig::default() })]

    #[test]
    fn a_written_bitstream_reads_back_as_written(blocks in proptest::collection::vec(block(2), 1..3)) {
        let mut bits = Bits::default();
        bits.put(u64::from(u32::from_le_bytes(*b"BC\xc0\xde")), 32);
        let expected: Vec<Block> = blocks.iter().map(|g| write_block(&mut bits, g, 2)).collect();
        prop_assert_eq!(bitstream::read(&bits.bytes, *b"BC\xc0\xde").unwrap(), expected);
    }
}

/// The committed programs, read once.
fn programs() -> &'static [(PathBuf, Vec<u8>)] {
    static PROGRAMS: OnceLock<Vec<(PathBuf, Vec<u8>)>> = OnceLock::new();
    PROGRAMS.get_or_init(|| {
        let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures");
        let mut out = Vec::new();
        for entry in std::fs::read_dir(dir).unwrap() {
            let path = entry.unwrap().path();
            if path.extension().is_some_and(|e| e == "dxil") {
                let bytes = std::fs::read(&path).unwrap();
                out.push((path, bytes));
            }
        }
        out.sort();
        out
    })
}

/// Changes to the bytes of one part of a committed program: which program, which part, and the bytes (where, as a
/// fraction of the part, and the new value).
fn edited() -> impl Strategy<Value = Vec<u8>> {
    (
        any::<Index>(),
        any::<Index>(),
        proptest::collection::vec((any::<Index>(), any::<u8>()), 1..4),
    )
        .prop_map(|(which, part, changes)| {
            let programs = programs();
            let bytes = &programs[which.index(programs.len())].1;
            let directory = dxcontainer::chunks(bytes).unwrap();
            let chunk = directory[part.index(directory.len())];
            let start = chunk.data.as_ptr() as usize - bytes.as_ptr() as usize;
            let mut out = bytes.clone();
            if !chunk.data.is_empty() {
                for (at, value) in changes {
                    out[start + at.index(chunk.data.len())] = value;
                }
            }
            out
        })
}

proptest! {
    #![proptest_config(ProptestConfig { cases: 128, failure_persistence: None, ..ProptestConfig::default() })]

    #[test]
    fn an_edited_program_is_listed_or_refused_the_same_each_time(bytes in edited()) {
        let first = disassemble(&bytes);
        prop_assert_eq!(&first, &disassemble(&bytes), "listed twice, two texts");
    }
}

/// The edits reach both outcomes: of 128 edits drawn as the test draws them (a fixed seed), at least an eighth are
/// listed and at least an eighth refused.
#[test]
fn the_edits_reach_both_outcomes() {
    let mut runner = TestRunner::deterministic();
    let mut listed = 0;
    for _ in 0..128 {
        let bytes = edited().new_tree(&mut runner).unwrap().current();
        listed += usize::from(disassemble(&bytes).is_ok());
    }
    assert!((16..=112).contains(&listed), "{listed} of 128 listed");
}
