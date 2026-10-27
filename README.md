# dx

Rust readers for compiled Direct3D shader bytecode (DXBC and DXIL) and PlayStation 3 RSX shader programs: they parse a
shader binary into typed records and refuse malformed input with an error instead of a panic.

| Crate | Reads |
|-------|-------|
| [`dxcontainer`](dxcontainer) | The DXBC container that holds every Direct3D shader program (Shader Model 4 to 6): its part directory and its digest. |
| [`dxbc-reader`](dxbc-reader) | DXBC shader bytecode, Shader Model 4 and 5 (Direct3D 10 and 11): the token stream as typed declarations and instructions, plus the `RDEF` reflection and the signature parts. |
| [`dxil-reader`](dxil-reader) | DXIL, Shader Model 6: the LLVM bitcode of the program decoded to a module (types, constants, metadata, function bodies), the reflection records in its metadata, and a library's `RDAT` subobjects. |
| [`rsx-reader`](rsx-reader) | PS3 RSX: `CellGcmTexture` descriptors, Cg binary (`CgBinaryProgram`) vertex and fragment program containers, and RSX fragment microcode as typed instructions. |

If you searched for a "DXBC parser", a "DXIL reader" or "shader bytecode in Rust", this is it. The crates report what the
file stores, with Direct3D's and DXIL's own numbers (`D3D_NAME`, `D3D_SHADER_INPUT_TYPE`, DXIL resource classes, Cg enum
values); mapping those to another graphics API, or compiling or translating the shaders, is left to the caller.

## What it was written against

The repository holds no shader from a shipped game: the Direct3D fixtures are compiler output for small HLSL sources, and the
PS3 tests use byte streams laid out by hand from the public layouts below.

- **Direct3D:** containers and programs from Microsoft's `fxc` (Shader Model 4 and 5; the six program types are recognised: vertex,
  hull, domain, geometry, pixel, compute) and from DirectXShaderCompiler `dxc` 1.7 (Shader Model 6, LLVM 3.7 IR with relative value ids,
  module version 1). The committed fixtures, with the HLSL they were compiled from, are in `*/tests/fixtures`.
- **PS3:** libgcm texture descriptors, and revision-6 `CgBinaryProgram` containers with profiles 7003 (vertex) and 7004
  (fragment) as the Cg toolchain wrote them for the RSX. Layouts follow RPCS3's public declarations; no RPCS3 code is
  copied.

## Example

```rust
fn main() -> Result<(), dxbc_reader::Error> {
    let container = std::fs::read("shader.dxbc").expect("a compiled shader");
    let code = dxbc_reader::code(&container)?; // the SHDR/SHEX part as 32-bit words
    let program = dxbc_reader::decode(&code)?;
    println!("{} with {} instructions", program.target(), program.instructions.len());
    Ok(())
}
```

Each crate has a runnable `examples/` program like this one and an example in its crate documentation, which `cargo test`
compiles; the programs take a file path, for instance `cargo run -p dxbc-reader --example inspect_dxbc -- dxbc-reader/tests/fixtures/modes.dxbc`.

## What it guarantees

- **No panics on untrusted bytes.** Every read is bounds-checked; the lengths, counts and offsets a file states are checked
  against the bytes that exist before anything is allocated, and nesting, tables and operand counts are capped. (`dxbc-reader`
  and `dxil-reader` document this; `dxcontainer` and the `RDAT` reader also deny indexing and unchecked arithmetic at
  compile time.) This is a design rule with tests on hand-built malformed input (for example, every truncation of a container
  is refused), not a fuzzing result.
- **Refusals say where and what.** Every error carries the position it happened at (a byte, a 32-bit word or a bit,
  depending on the format) and what was expected there. Whatever a reader does not implement it refuses by name rather than
  skipping.
- **Records as stored.** Numbers keep the values the file holds; no reader reinterprets them for an API.
- **No `unsafe`** (`unsafe_code = "deny"` for the workspace) and no file, environment or process access in the library code.

## What it does not do

- It does not write, assemble or compile shaders, and does not execute them or translate them to another language.
- It does not verify a container's digest (`dxcontainer::checksum` computes it, for a caller that wants to compare); the digest
  is not an authenticity check.
- `dxbc-reader` reads Shader Model 4 and 5 only; `dxil-reader` reads the LLVM IR that DXIL uses, not arbitrary LLVM bitcode,
  and refuses instruction records DXIL does not use.
- `rsx-reader` keeps vertex program microcode encoded and decodes fragment microcode only; it reads one revision (6) of
  `CgBinaryProgram`. Its dependency analysis is conservative, not an evaluator.
- The minimum supported Rust version is the pinned toolchain, 1.99. The four crates are on crates.io
  (`cargo add dxbc-reader`, and so on).

## Tests

```sh
cargo test --workspace
```

The tests need no game files: they use the committed fixtures (compiler output for the HLSL beside each) and byte streams
laid out by hand. There is no real-data suite and no `GAME_DATA` file in this repository. Lint and format checks, as run in
CI:

```sh
cargo fmt --all --check
cargo clippy --workspace --all-targets --locked -- -D warnings
RUSTDOCFLAGS="-D warnings" cargo doc --workspace --no-deps
```

The crates depend on [`primase-foundations`](https://github.com/Kalmarv/primase-foundations) (a bounds-checked byte `View` and
an MD5 block function), pinned to a commit.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md), including how to report a file these readers cannot read.

## License

GPL-3.0-or-later, see [LICENSE](LICENSE).

Used by [primase](https://github.com/Kalmarv/primase), a game-asset conversion library.
