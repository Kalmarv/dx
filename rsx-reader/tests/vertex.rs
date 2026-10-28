#![allow(clippy::unwrap_used)]
//! Vertex microcode laid out by hand, bit by bit from the field positions of the NV40 vertex instruction (no encoder is
//! used): the fields a slot holds, the two operations of one slot with their separate destinations, the ten-bit constant
//! index, relative addressing, the masks a program header states, and the refusals.
use rsx_reader::vertex::{Destination, Output, ScalarOpcode, SourceKind, VectorOpcode, decode};

/// A source operand: 17 bits.
fn source(kind: u32, temp: u32, swizzle: [u32; 4], negate: bool) -> u32 {
    (u32::from(negate) << 16)
        | (swizzle[0] << 14)
        | (swizzle[1] << 12)
        | (swizzle[2] << 10)
        | (swizzle[3] << 8)
        | (temp << 2)
        | kind
}
const IDENTITY: [u32; 4] = [0, 1, 2, 3];
const NONE: u32 = 0;
const TEMP: u32 = 1;
const INPUT: u32 = 2;
const CONSTANT: u32 = 3;

#[derive(Clone, Copy)]
struct Slot {
    vector: u32,
    scalar: u32,
    sources: [u32; 3],
    input: u32,
    constant: u32,
    /// The output destination field; 31 for a temporary.
    dest: u32,
    vector_result: bool,
    scalar_result: bool,
    vector_temp: u32,
    scalar_temp: u32,
    /// The lanes written, bit 0 for x.
    vector_mask: u32,
    scalar_mask: u32,
    last: bool,
}

/// A write mask as the slot stores it: x is the highest of the four bits.
fn stored(mask: u32) -> u32 {
    (0..4).fold(0, |m, lane| m | (((mask >> lane) & 1) << (3 - lane)))
}

impl Slot {
    fn new() -> Self {
        Slot {
            vector: 0,
            scalar: 0,
            sources: [source(NONE, 0, IDENTITY, false); 3],
            input: 0,
            constant: 0,
            dest: 31,
            vector_result: false,
            scalar_result: false,
            vector_temp: 63,
            scalar_temp: 31,
            vector_mask: 0,
            scalar_mask: 0,
            last: false,
        }
    }
    fn words(self) -> [u32; 4] {
        let [s0, s1, s2] = self.sources;
        // word 0: vector result flag (30), vector destination temporary (15 to 20), condition code "always" (10 to 12)
        let w0 = (u32::from(self.vector_result) << 30) | (self.vector_temp << 15) | (7 << 10);
        let w1 =
            (self.scalar << 27) | (self.vector << 22) | (self.constant << 12) | (self.input << 8) | (s0 >> 9);
        let w2 = ((s0 & 0x1ff) << 23) | (s1 << 6) | (s2 >> 11);
        let w3 = ((s2 & 0x7ff) << 21)
            | (stored(self.scalar_mask) << 17)
            | (stored(self.vector_mask) << 13)
            | (u32::from(self.scalar_result) << 12)
            | (self.scalar_temp << 7)
            | (self.dest << 2)
            | u32::from(self.last);
        [w0, w1, w2, w3]
    }
}

fn program(slots: &[Slot]) -> Vec<u8> {
    slots
        .iter()
        .flat_map(|s| s.words())
        .flat_map(u32::to_be_bytes)
        .collect()
}

#[test]
fn one_slot_holds_a_vector_operation_its_sources_and_an_output() {
    // MOV o[COL0].xyzw, -v[3].yxzw
    let mov = Slot {
        vector: 1,
        sources: [
            source(INPUT, 0, [1, 0, 2, 3], true),
            source(NONE, 0, IDENTITY, false),
            source(NONE, 0, IDENTITY, false),
        ],
        input: 3,
        dest: 1,
        vector_result: true,
        vector_mask: 15,
        last: true,
        ..Slot::new()
    };
    let p = decode(&program(&[mov])).unwrap();
    let i = &p.instructions[0];
    assert_eq!((i.vector, i.scalar), (VectorOpcode::MOV, ScalarOpcode::NOP));
    assert_eq!(i.vector_destination, Destination::Output(Output::Color0));
    assert_eq!(i.scalar_destination, Destination::None);
    assert_eq!((i.vector_mask, i.input, i.last), (15, 3, true));
    let s = i.sources[0];
    assert_eq!(
        (s.kind, s.swizzle, s.negate, s.absolute),
        (SourceKind::Input, [1, 0, 2, 3], true, false)
    );
    assert_eq!(i.sources[1].kind, SourceKind::None);
    assert_eq!(i.unassigned, [0; 4]);
    assert_eq!(i.outputs(), [Output::Color0]);
    assert_eq!(
        (p.input_mask(), p.output_mask(), p.register_count()),
        (Some(1 << 3), 1, 1)
    );
    assert!(p.disassemble().contains("MOV o[Color0].xyzw, -v[3].yxzw"));
}

#[test]
fn the_constant_index_is_ten_bits_and_each_operation_has_its_own_destination() {
    // MAD R2.xyz, R0, c[300], R1 in the vector slot; RSQ o[TC0].w of c[300].x in the scalar slot
    let slot = Slot {
        vector: 4,
        scalar: 4,
        sources: [
            source(TEMP, 0, IDENTITY, false),
            source(CONSTANT, 0, IDENTITY, false),
            source(TEMP, 1, IDENTITY, false),
        ],
        constant: 300,
        dest: 7,
        scalar_result: true,
        vector_temp: 2,
        vector_mask: 0b0111,
        scalar_mask: 0b1000,
        last: true,
        ..Slot::new()
    };
    let p = decode(&program(&[slot])).unwrap();
    let i = &p.instructions[0];
    assert_eq!((i.vector, i.scalar), (VectorOpcode::MAD, ScalarOpcode::RSQ));
    assert_eq!(i.constant, 300);
    assert_eq!(i.vector_destination, Destination::Temporary(2));
    assert_eq!(i.scalar_destination, Destination::Output(Output::TexCoord(0)));
    assert_eq!((i.vector_mask, i.scalar_mask), (0b0111, 0b1000));
    assert_eq!(
        i.sources.map(|s| s.kind),
        [
            SourceKind::Temporary(0),
            SourceKind::Constant,
            SourceKind::Temporary(1)
        ]
    );
    assert_eq!(i.outputs(), [Output::TexCoord(0)]);
    assert_eq!(p.register_count(), 3);
    assert_eq!(p.output_mask(), 1 << 14);
}

#[test]
fn masks_follow_the_destinations_a_program_writes() {
    let write = |dest: u32, mask: u32| Slot {
        vector: 1,
        sources: [source(CONSTANT, 0, IDENTITY, false); 3],
        dest,
        vector_result: true,
        vector_mask: mask,
        ..Slot::new()
    };
    // position, colour 0, destination 6 with all lanes and with x alone, texture coordinates 0 and 9
    let mut slots = vec![
        write(0, 15),
        write(1, 15),
        write(6, 15),
        write(7, 15),
        write(16, 15),
    ];
    slots.last_mut().unwrap().last = true;
    let p = decode(&program(&slots)).unwrap();
    assert_eq!(p.output_mask(), 1 | (1 << 13) | (1 << 14) | (1 << 23));
    let mut slots = vec![write(6, 0b0001), write(5, 0b0001)];
    slots.last_mut().unwrap().last = true;
    assert_eq!(
        decode(&program(&slots)).unwrap().output_mask(),
        (1 << 5) | (1 << 4)
    );
    // an operation with an empty write mask writes nothing
    let mut slots = vec![write(1, 0)];
    slots[0].last = true;
    assert_eq!(decode(&program(&slots)).unwrap().output_mask(), 0);
}

#[test]
fn relative_input_reads_have_no_input_mask() {
    let read = Slot {
        vector: 1,
        sources: [source(INPUT, 0, IDENTITY, false); 3],
        input: 2,
        dest: 0,
        vector_result: true,
        vector_mask: 15,
        last: true,
        ..Slot::new()
    };
    assert_eq!(decode(&program(&[read])).unwrap().input_mask(), Some(1 << 2));
    let mut words = read.words();
    words[0] |= 1 << 27; // index the attributes by the address register
    let bytes: Vec<u8> = words.into_iter().flat_map(u32::to_be_bytes).collect();
    let p = decode(&bytes).unwrap();
    assert!(p.instructions[0].input_relative);
    assert_eq!(p.input_mask(), None);
}

#[test]
fn what_cannot_be_read_is_refused_by_name() {
    let base = Slot {
        vector: 1,
        sources: [source(TEMP, 0, IDENTITY, false); 3],
        vector_temp: 0,
        vector_mask: 15,
        ..Slot::new()
    };
    let last = Slot { last: true, ..base };
    assert!(decode(&[]).is_err());
    assert!(
        decode(&program(&[last])[..15])
            .unwrap_err()
            .detail
            .contains("complete 16-byte slots")
    );
    // an opcode nothing names
    for (vector, scalar, why) in [
        (0x1a, 0, "vector opcode 0x1a"),
        (0, 0x08, "scalar opcode 0x08"),
        (0, 0x1f, "scalar opcode 0x1f"),
    ] {
        let bad = Slot {
            vector,
            scalar,
            ..last
        };
        assert!(
            decode(&program(&[bad])).unwrap_err().detail.contains(why),
            "{why}"
        );
    }
    // the last flag on the last slot, and only there
    assert!(
        decode(&program(&[base]))
            .unwrap_err()
            .detail
            .contains("not flagged")
    );
    let e = decode(&program(&[last, last])).unwrap_err();
    assert_eq!(e.offset, 0);
    assert!(e.detail.contains("before the end"));
    decode(&program(&[base, last])).unwrap();
}
