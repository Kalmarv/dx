# dxcontainer

Reads the part directory of a DXBC container, the file format Direct3D shader programs are stored in (Shader Model 4 to 6),
and computes its digest.

```rust
let bytes = std::fs::read("shader.dxbc")?;
for part in dxcontainer::chunks(&bytes)? {
    println!("{}: {} bytes", String::from_utf8_lossy(&part.kind), part.data.len());
}
println!("digest: {:02x?}", dxcontainer::checksum(&bytes));
```

Run it with `cargo run -p dxcontainer --example parts -- shader.dxbc`; the source is [`examples/parts.rs`](examples/parts.rs). The crate documentation has a self-contained example with a hand-built container.

## What it reads

A header (`DXBC`, a 16-byte digest, version 1, the container's size, the number of parts), the directory of the parts'
offsets, then the parts one after another in the directory's order (each its four-character kind, its length and its
bytes), the last ending where the container does. Shader Model 6 parts are not padded, so an offset need not be a multiple
of 4. This layout held for 77,956 containers from shader corpora that are not part of this repository, and holds for the 127
containers committed under `dxbc-reader/tests/fixtures` and `dxil-reader/tests/fixtures`.

## What it guarantees

The reader reads to the exact end and refuses, with an `Error` that names the byte, a part anywhere else (overlapping, or
after a gap), a byte after the last part, a part kind twice, a size other than the container's and a version other than 1.
The crate denies indexing and unchecked arithmetic at compile time, so untrusted bytes produce an `Error`, not a panic.

## What it does not do

It does not verify the digest: the digest is not an authenticity check. `checksum(bytes)` computes it (MD5's block function
over the bytes from 20 on, padded as the compiler pads it), for a caller that wants to compare; on all 127 committed fixtures
it equals the stored digest. It does not interpret the parts; `dxbc-reader` (Shader Model 4 and 5) and `dxil-reader`
(Shader Model 6) do.

## Tests

`cargo test -p dxcontainer`: containers built by hand for each refusal, every truncation of one, and the committed
fixtures of `dxbc-reader` and `dxil-reader` read to their end. No game files are needed.

License: GPL-3.0-or-later.
