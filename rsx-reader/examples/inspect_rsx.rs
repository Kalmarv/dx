//! `cargo run -p rsx-reader --example inspect_rsx -- texture.bin shader.fpo`: read a 24-byte `CellGcmTexture` descriptor and
//! a fragment `CgBinaryProgram`, and print the program's disassembly. The README's example is this file's body.
use rsx_reader::{cgbinary, fragment, gcm};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut args = std::env::args().skip(1);
    let (Some(texture_path), Some(shader_path)) = (args.next(), args.next()) else {
        return Err("usage: inspect <texture.bin> <shader.fpo>".into());
    };
    let texture = gcm::CellGcmTexture::parse(&std::fs::read(texture_path)?)?; // exactly 24 bytes
    println!(
        "{}x{}, {} mips, linear: {}",
        texture.width,
        texture.height,
        texture.mipmap,
        texture.linear()
    );

    let shader = std::fs::read(shader_path)?;
    let program = cgbinary::parse(&shader)?;
    if let cgbinary::Stage::Fragment(_) = program.stage {
        let code = fragment::decode(program.microcode)?;
        print!("{}", code.disassemble());
    }
    Ok(())
}
