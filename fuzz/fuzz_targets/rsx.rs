//! The RSX readers on any bytes: a Cg binary container and fragment and vertex microcode. No panic, no hang.
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    let _ = rsx_reader::cgbinary::parse_prefix(data);
    let _ = rsx_reader::fragment::decode(data);
    let _ = rsx_reader::vertex::decode(data);
});
