//! `cargo run -p dxcontainer --example parts -- shader.dxbc`: list a container's parts and print its digest.
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let path = std::env::args().nth(1).ok_or("usage: parts <container>")?;
    let bytes = std::fs::read(path)?;
    for part in dxcontainer::chunks(&bytes)? {
        println!(
            "{}: {} bytes",
            String::from_utf8_lossy(&part.kind),
            part.data.len()
        );
    }
    println!("digest: {:02x?}", dxcontainer::checksum(&bytes));
    Ok(())
}
