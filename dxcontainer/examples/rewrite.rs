//! `cargo run -p dxcontainer --example rewrite -- in.dxbc out.dxbc [KIND=part.bin]...`: write a container again, with
//! the digest recomputed, after replacing (or appending) the named parts. With no `KIND=file` argument the output is the
//! input's parts re-serialized: byte-identical to the input when it stores the digest `checksum` computes.
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut args = std::env::args().skip(1);
    let (Some(input), Some(output)) = (args.next(), args.next()) else {
        return Err("usage: rewrite <in> <out> [KIND=file]...".into());
    };
    let mut bytes = std::fs::read(input)?;
    for edit in args {
        let (kind, file) = edit.split_once('=').ok_or("an edit is KIND=file")?;
        let kind: [u8; 4] = kind
            .as_bytes()
            .try_into()
            .map_err(|_| "a kind is four characters")?;
        bytes = dxcontainer::replace_part(&bytes, kind, &std::fs::read(file)?)?;
    }
    let rewritten = dxcontainer::serialize(&dxcontainer::chunks(&bytes)?)?;
    std::fs::write(output, rewritten)?;
    Ok(())
}
