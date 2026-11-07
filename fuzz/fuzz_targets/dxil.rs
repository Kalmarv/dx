//! The Shader Model 6 reader on any bytes: the listing, the module and what reflection reads of it, the PSV0 and RDAT
//! parts, and the bitstream alone. No panic, no hang.
#![no_main]
use dxil_reader::{bitstream, psv, rdat, reflection, sampling};
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    let _ = dxil_reader::disasm::disassemble(data);
    let _ = dxil_reader::operations(data);
    let _ = bitstream::read(data, *b"BC\xc0\xde");
    let Ok(chunks) = dxil_reader::parts(data) else {
        return;
    };
    let _ = psv::part(&chunks);
    if let Some(part) = chunks.iter().find(|c| &c.kind == b"RDAT") {
        let _ = rdat::subobjects(part.data);
    }
    if let Ok(Some(m)) = dxil_reader::module(&chunks, b"DXIL") {
        let _ = reflection::elements(&m);
        let _ = reflection::shader_flags(&m);
        let _ = reflection::num_threads(&m);
        let _ = reflection::usage_masks(&m);
        let _ = reflection::element_tags(&m);
        let _ = sampling::texture_reads(&m);
        let _ = dxil_reader::disasm::module_text(&m);
    }
});
