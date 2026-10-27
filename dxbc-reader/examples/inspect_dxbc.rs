//! `cargo run -p dxbc-reader --example inspect_dxbc -- shader.dxbc`: print a Shader Model 4/5 shader's target, instruction count,
//! resource bindings and signature sizes. The README's example is this file's body.
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let path = std::env::args().nth(1).ok_or("usage: inspect <shader.dxbc>")?;
    let container = std::fs::read(path)?;
    let code = dxbc_reader::code(&container)?; // the SHDR/SHEX part as 32-bit words
    let program = dxbc_reader::decode(&code)?;
    println!(
        "{} with {} instructions",
        program.target(),
        program.instructions.len()
    );

    // Reflection and signatures straight from the container:
    if let Some(rdef) = dxbc_reader::rdef(&container)? {
        for binding in &rdef.bindings {
            println!("{} at register {}", binding.name, binding.register);
        }
    }
    let (stage, inputs, outputs) = dxbc_reader::signature_elements(&container)?;
    println!("{stage:?}: {} inputs, {} outputs", inputs.len(), outputs.len());
    Ok(())
}
