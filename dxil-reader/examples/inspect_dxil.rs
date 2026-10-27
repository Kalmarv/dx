//! `cargo run -p dxil-reader --example inspect_dxil -- shader.dxil`: print a Shader Model 6 shader's function count, signature
//! sizes and bound resource ranges. The README's example is this file's body.
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let path = std::env::args().nth(1).ok_or("usage: inspect <shader.dxil>")?;
    let container = std::fs::read(path)?;
    let parts = dxil_reader::parts(&container)?;
    let module = dxil_reader::module(&parts, b"DXIL")?.ok_or("no DXIL part")?;
    println!("{} functions", module.functions.len());

    // The records the file stores for its entry point:
    let (inputs, outputs) = dxil_reader::reflection::elements(&module)?;
    println!(
        "{} input and {} output signature elements",
        inputs.len(),
        outputs.len()
    );
    for (range, name, _) in dxil_reader::reflection::ranges(&module)? {
        println!("{name}: class {} register {}", range.class, range.lower);
    }
    Ok(())
}
