//! The Shader Model 4 and 5 reader on any bytes: the listing under a flags word chosen by the first byte, and every
//! other reading of the container and its token stream. No panic, no hang.
#![no_main]
use libfuzzer_sys::fuzz_target;

/// The flags words that change the text, each alone and all together.
const FLAGS: [u32; 8] = [0, 0x02, 0x04, 0x10, 0x20, 0x40, 0x80, 0xf6];

fuzz_target!(|data: &[u8]| {
    let Some((&pick, bytes)) = data.split_first() else {
        return;
    };
    let options = dxbc_reader::Options::from_flags(FLAGS[usize::from(pick) % FLAGS.len()]).unwrap();
    let _ = dxbc_reader::disassemble_with(bytes, &options);
    if let Ok(directory) = dxbc_reader::parts(bytes) {
        let _ = dxbc_reader::program_type(&directory);
    }
    let _ = dxbc_reader::rdef(bytes);
    let _ = dxbc_reader::rdef_target(bytes);
    let _ = dxbc_reader::signature_elements(bytes);
    let _ = dxbc_reader::statistics(bytes);
    let _ = dxbc_reader::interfaces(bytes);
    let _ = dxbc_reader::level9(bytes);
    if let Ok(code) = dxbc_reader::code(bytes)
        && let Ok(program) = dxbc_reader::decode(&code)
    {
        let _ = dxbc_reader::texture_reads(&program);
    }
});
