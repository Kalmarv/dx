#![allow(clippy::unwrap_used)]
//! Reflection and container parts a compiler never writes, built by hand: each is refused with an error that names the
//! 32-bit word the bad bytes start at (counted from the start of the part) and says what was expected there.

/// A container of these parts, directory first and the parts one after another.
fn container(parts: &[(&[u8; 4], &[u8])]) -> Vec<u8> {
    let directory = 32 + 4 * parts.len();
    let mut offsets = Vec::new();
    let mut body = Vec::new();
    for (kind, data) in parts {
        offsets.push((directory + body.len()) as u32);
        body.extend_from_slice(*kind);
        body.extend_from_slice(&(data.len() as u32).to_le_bytes());
        body.extend_from_slice(data);
    }
    let mut out = b"DXBC".to_vec();
    out.extend_from_slice(&[0; 16]);
    out.extend_from_slice(&1u32.to_le_bytes());
    out.extend_from_slice(&((directory + body.len()) as u32).to_le_bytes());
    out.extend_from_slice(&(parts.len() as u32).to_le_bytes());
    for offset in offsets {
        out.extend_from_slice(&offset.to_le_bytes());
    }
    out.extend_from_slice(&body);
    out
}

fn words(w: &[u32]) -> Vec<u8> {
    w.iter().flat_map(|x| x.to_le_bytes()).collect()
}

/// An RDEF part of the SM5 layout with `buffers` constant buffers at word 14 and no bindings, the record-size directory
/// `sizes` and the tag `tag`.
fn rdef_part(tag: &[u8; 4], sizes: [u32; 6], buffers: &[[u32; 6]]) -> Vec<u8> {
    let mut out = words(&[buffers.len() as u32, 56, 0, 0, 0xffff_0500, 0, 0]);
    out.extend_from_slice(tag);
    out.extend(words(&sizes));
    assert_eq!(out.len(), 56);
    for b in buffers {
        out.extend(words(b));
    }
    out.extend_from_slice(b"cb\0\0");
    out
}

const SIZES: [u32; 6] = [60, 24, 32, 40, 36, 12];

#[test]
fn an_rdef_of_another_layout_is_refused_at_its_tag_saying_what_the_tag_is() {
    let bytes = container(&[(b"RDEF", &rdef_part(b"RD10", SIZES, &[]))]);
    let e = dxbc_reader::rdef(&bytes).unwrap_err();
    assert_eq!(e.word, 7, "the tag is the eighth word of the part: {e}");
    assert!(e.detail.contains("RD11"), "{e}");
    assert!(!e.detail.contains("pixel or vertex"), "{e}");
    // the same part with the right tag reads
    let ok = container(&[(b"RDEF", &rdef_part(b"RD11", SIZES, &[]))]);
    assert!(dxbc_reader::rdef(&ok).unwrap().unwrap().buffers.is_empty());
}

#[test]
fn a_record_size_that_differs_is_refused_at_its_word_with_both_sizes() {
    let mut sizes = SIZES;
    sizes[2] = 36;
    let bytes = container(&[(b"RDEF", &rdef_part(b"RD11", sizes, &[]))]);
    let e = dxbc_reader::rdef(&bytes).unwrap_err();
    assert_eq!(e.word, 10, "{e}");
    assert!(e.detail.contains("36") && e.detail.contains("32"), "{e}");
}

#[test]
fn a_constant_buffer_size_past_the_bound_is_refused_at_the_size_field() {
    // one buffer record at byte 56: name offset, variable count, variable offset, size, flags, type; the name is at 80
    let bytes = container(&[(b"RDEF", &rdef_part(b"RD11", SIZES, &[[80, 0, 0, 1 << 20, 0, 0]]))]);
    let e = dxbc_reader::rdef(&bytes).unwrap_err();
    assert_eq!(e.word, (56 + 12) / 4, "{e}");
    assert!(e.detail.contains("65536") || e.detail.contains("bound"), "{e}");
}

#[test]
fn a_missing_part_is_named_with_its_own_tag() {
    let bytes = container(&[(b"SHEX", &words(&[0x10050, 2]))]);
    let e = dxbc_reader::signature_elements(&bytes).unwrap_err();
    assert!(e.detail.contains("ISGN"), "{e}");
    assert!(!e.detail.contains("reflection chunk"), "{e}");
}

#[test]
fn code_that_is_not_whole_words_is_refused_where_the_partial_word_starts() {
    let bytes = container(&[(b"SHEX", &[0, 0, 5, 0, 0, 0, 1])]);
    let e = dxbc_reader::code(&bytes).unwrap_err();
    assert_eq!(e.word, 1, "{e}");
    assert!(e.detail.contains("multiple of 4"), "{e}");
}

#[test]
fn a_signature_directory_that_does_not_start_at_8_says_what_it_found() {
    let part = words(&[0, 12]);
    let e = dxbc_reader::signature(&part, b"ISGN").unwrap_err();
    assert_eq!(e.word, 1, "{e}");
    assert!(e.detail.contains("12") && e.detail.contains('8'), "{e}");
}

#[test]
fn lengths_that_do_not_fit_the_stream_are_refused_at_the_token_that_states_them() {
    // customdata (opcode 53) of 9 words in a stream with 4 words after it
    let e = dxbc_reader::decode(&[0x50, 8, 53, 9, 0, 0, 0, 0]).unwrap_err();
    assert_eq!(e.word, 2, "{e}");
    assert!(e.detail.contains("customdata"), "{e}");
    // an instruction of length 0
    let e = dxbc_reader::decode(&[0x50, 3, 54]).unwrap_err();
    assert_eq!(e.word, 2, "{e}");
    assert!(e.detail.contains("instruction length 0"), "{e}");
    // an instruction of 5 words with 2 left
    let e = dxbc_reader::decode(&[0x50, 4, 54 | 5 << 24, 0]).unwrap_err();
    assert_eq!(e.word, 2, "{e}");
    assert!(e.detail.contains("does not fit"), "{e}");
    // an immediate constant buffer of 6 words is not whole rows
    let e = dxbc_reader::decode(&[0x50, 10, 53 | 3 << 11, 8, 0, 0, 0, 0, 0, 0]).unwrap_err();
    assert_eq!(e.word, 2, "{e}");
    assert!(e.detail.contains("whole rows"), "{e}");
}
