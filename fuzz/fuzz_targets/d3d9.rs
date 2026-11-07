//! The Direct3D 9 reader on any bytes: the read, the frame, and the listing under a flags word chosen by the first
//! byte. No panic, no hang.
#![no_main]
use libfuzzer_sys::fuzz_target;

/// The flags words that change the text, each alone and all together.
const FLAGS: [u32; 8] = [0, 0x02, 0x04, 0x10, 0x20, 0x40, 0x80, 0xf6];

fuzz_target!(|data: &[u8]| {
    let Some((&pick, bytes)) = data.split_first() else {
        return;
    };
    let options = d3d9_reader::Options::from_flags(FLAGS[usize::from(pick) % FLAGS.len()]).unwrap();
    let _ = d3d9_reader::read(bytes);
    let _ = d3d9_reader::frame(bytes);
    let _ = d3d9_reader::disassemble_with(bytes, &options);
});
