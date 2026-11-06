//! What the listing tests share: the flags words Microsoft's listings were made with, and the message for a listing
//! that differs.
#![allow(dead_code)]

/// The flags words of the fixture listings (`generate.py`'s `FLAGS`) and of the corpora that have more than one: no
/// flags, and the flags that change the text alone, in pairs and all together.
pub fn flag_words() -> Vec<u32> {
    const TEXT: [u32; 6] = [0x02, 0x04, 0x10, 0x20, 0x40, 0x80];
    let mut words = vec![0, TEXT.iter().sum()];
    for (i, a) in TEXT.iter().enumerate() {
        words.push(*a);
        words.extend(TEXT[i + 1..].iter().map(|b| a | b));
    }
    words.sort_unstable();
    words
}

/// A listing as Microsoft's disassembler wrote it, read back: a blob saved with its closing zero byte, or in text
/// mode on Windows (CRLF), is the text the disassembler wrote.
pub fn microsofts(bytes: &[u8]) -> String {
    String::from_utf8_lossy(bytes)
        .trim_end_matches('\0')
        .replace("\r\n", "\n")
}

/// Where `ours` first differs from `theirs`, for a failure message naming `what`; `None` when they are the same.
pub fn difference(what: &str, ours: &str, theirs: &str) -> Option<String> {
    if ours == theirs {
        return None;
    }
    let line = ours
        .lines()
        .zip(theirs.lines())
        .position(|(a, b)| a != b)
        .unwrap_or(0);
    Some(format!(
        "{what} line {}:\n  dx: {:?}\n  ms: {:?}",
        line + 1,
        ours.lines().nth(line).unwrap_or(""),
        theirs.lines().nth(line).unwrap_or("")
    ))
}
