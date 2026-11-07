#![allow(clippy::unwrap_used)]
//! Properties of the readers over generated inputs, at a fixed number of cases so a run takes the same time on every
//! machine:
//!
//! - fragment and vertex microcode of any words is decoded or refused, never a panic, the same each time;
//! - a Cg binary container (`tests/cgbinary.rs`'s hand laid-out one, fragment and vertex) with any bytes changed is
//!   read or refused, never a panic, and `parse_prefix` reads it the same with any bytes after it, which `parse`
//!   refuses.
use proptest::prelude::*;
use proptest::sample::Index;
use rsx_reader::cgbinary::{parse, parse_prefix};
use rsx_reader::{fragment, vertex};

fn word(b: &mut [u8], at: usize, value: u32) {
    b[at..at + 4].copy_from_slice(&value.to_be_bytes());
}

// As tests/cgbinary.rs lays it out: header 0..32,
// parameter 32..80, descriptor 80..104, strings 104..118,
// float2 defaults 120..128, patch table 128..140, microcode 144..176.
fn fixture(fragment: bool) -> Vec<u8> {
    let mut b = vec![0; 176];
    for (i, n) in [if fragment { 7004 } else { 7003 }, 6, 176, 1, 32, 80, 32, 144]
        .into_iter()
        .enumerate()
    {
        word(&mut b, i * 4, n);
    }
    for (i, n) in [1046, 2051, 4102, 3, 104, 120, 128, 111, 4097, u32::MAX, 1, 0]
        .into_iter()
        .enumerate()
    {
        word(&mut b, 32 + i * 4, n);
    }
    word(&mut b, 80, 2);
    if fragment {
        word(&mut b, 84, 0x12345678);
        word(&mut b, 88, 0x80000001);
        b[92..104].copy_from_slice(&[0, 3, 0, 2, 0, 1, 7, 1, 1, 1, 0xaa, 0xbb]);
    } else {
        for (i, n) in [9, 7, 0x12345678, 0x87654321, 15].into_iter().enumerate() {
            word(&mut b, 84 + i * 4, n);
        }
    }
    b[104..118].copy_from_slice(b"albedo\0COLOR0\0");
    word(&mut b, 120, (-0.0f32).to_bits());
    word(&mut b, 124, 0x7fc01234); // keep NaN payload, not a numeric conversion
    word(&mut b, 128, 2);
    word(&mut b, 132, 0);
    word(&mut b, 136, 16);
    for (i, byte) in b[144..].iter_mut().enumerate() {
        *byte = i as u8;
    }
    b
}

proptest! {
    #![proptest_config(ProptestConfig { cases: 512, failure_persistence: None, ..ProptestConfig::default() })]

    #[test]
    fn microcode_of_any_words_is_decoded_or_refused(words in proptest::collection::vec(any::<u32>(), 1..33)) {
        let bytes: Vec<u8> = words.iter().flat_map(|w| w.to_be_bytes()).collect();
        prop_assert_eq!(fragment::decode(&bytes), fragment::decode(&bytes));
        prop_assert_eq!(vertex::decode(&bytes), vertex::decode(&bytes));
    }

    #[test]
    fn an_edited_container_is_read_or_refused_alone_and_before_other_bytes(
        fragment in any::<bool>(),
        changes in proptest::collection::vec((any::<Index>(), any::<u8>()), 0..4),
        after in proptest::collection::vec(any::<u8>(), 1..16),
    ) {
        let mut bytes = fixture(fragment);
        for (at, value) in changes {
            let at = at.index(bytes.len());
            bytes[at] = value;
        }
        let alone = parse_prefix(&bytes);
        let mut longer = bytes.clone();
        longer.extend(&after);
        let before = parse_prefix(&longer);
        if let Ok(p) = &alone && p.bytes.len() == bytes.len() {
            prop_assert_eq!(&parse(&bytes), &alone);
            prop_assert_eq!(&before, &alone);
            prop_assert!(parse(&longer).is_err(), "parse read trailing bytes");
        }
    }
}
