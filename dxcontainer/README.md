# dxcontainer

Reads the part directory of a DXBC container, the file format Direct3D shader programs are stored in (Shader Model 4 to 6),
computes its digest, and writes a container again with the digest repaired.

```rust
let bytes = std::fs::read("shader.dxbc")?;
for part in dxcontainer::chunks(&bytes)? {
    println!("{}: {} bytes", String::from_utf8_lossy(&part.kind), part.data.len());
}
println!("digest: {:02x?}", dxcontainer::checksum(&bytes));
```

A shader-patching mod edits a part and writes the container back:

```rust
let bytes = std::fs::read("shader.dxbc")?;
let new_program = std::fs::read("replacement.shex")?; // a replacement SHEX part payload
let patched = dxcontainer::replace_part(&bytes, *b"SHEX", &new_program)?; // the other parts as they were, the digest repaired
std::fs::write("patched.dxbc", patched)?;
```

Run it with `cargo run -p dxcontainer --example parts -- shader.dxbc`; the source is [`examples/parts.rs`](examples/parts.rs). The crate documentation has a self-contained example with a hand-built container.

## What it reads

A header (`DXBC`, a 16-byte digest, version 1, the container's size, the number of parts), the directory of the parts'
offsets, then the parts one after another in the directory's order (each its four-character kind, its length and its
bytes), the last ending where the container does. Shader Model 6 parts are not padded, so an offset need not be a multiple
of 4. This layout holds for the 137 containers committed under `dxbc-reader/tests/fixtures` and `dxil-reader/tests/fixtures`:
the tests read each to its exact end and check that `checksum` equals the digest it stores.

`serialize(&parts)` writes parts as a container: the header, the directory, the parts in the order given, each exactly as given
with nothing between them (a part keeps the padding its producer wrote, or none), and the digest `checksum` computes.
`serialize(&chunks(bytes)?)` is `bytes` again for every container that stores the digest `checksum` computes, which includes
all 77,457 stock containers of five games. `repair_digest` rewrites the digest of a container edited in place, and
`replace_part` replaces (or appends) one part of a container and writes the result. A kind twice is refused, as the reader refuses it.
Outside tools agree: Microsoft's DXIL validator signs a container whose digest was zeroed with the digest `repair_digest`
writes, and vkd3d's `vkd3d-dxbc` accepts the containers written here (it checks the digest) and refuses the same bytes with one digest byte changed.

`feature_flags` reads the `SFI0` part, the features the shader requires, as a `u64` with the bytecode (`SHDR`/`SHEX` or
`DXIL`) that says what its bits mean; `feature_name` names a bit the way the compiler lists it. The names were read off
`fxc` and `dxc` output for programs that need one feature each (`tests/fixtures/features`, with the sources).

## What it guarantees

The reader reads to the exact end and refuses, with an `Error` that names the byte, a part anywhere else (overlapping, or
after a gap), a byte after the last part, a part kind twice, a size other than the container's and a version other than 1.
The crate denies indexing and unchecked arithmetic at compile time, so untrusted bytes produce an `Error`, not a panic.

## What it does not do

It does not verify the digest: the digest is not an authenticity check. `checksum(bytes)` computes it (MD5's block function
over the bytes from 20 on, padded as the compiler pads it), for a caller that wants to compare; on all 137 committed fixtures
it equals the stored digest, as it does on the 77,457 containers of five games' shipped shaders (none stores a zero
digest). It interprets no part but `SFI0`; `dxbc-reader` (Shader Model 4 and 5) and `dxil-reader` (Shader Model 6) do.

## Tests

`cargo test -p dxcontainer`: containers built by hand for each refusal, every truncation of one, and the committed
fixtures of `dxbc-reader` and `dxil-reader` read to their end. No game files are needed.

## Check the examples

From the repository root, `cargo test -p dxcontainer --doc` checks the crate documentation, and
`cargo build -p dxcontainer --examples` builds its example programs. Examples that read paths need the caller's files; the repository ships no game assets.

License: GPL-3.0-or-later.
