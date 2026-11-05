# dx

Rust libraries that read compiled shader programs and their containers: Direct3D 9, DXBC and DXIL programs, and PlayStation 3 RSX programs and texture descriptors.

## Features

- Reads and writes the DXBC container used by Shader Model 4 to 6 programs, computes and repairs its digest, and reads its `SFI0` feature flags
- Reads Direct3D 9 vertex and pixel programs from Shader Model 1.0 to 3.0, with the `CTAB` constant table
- Decodes Shader Model 4, 5 and 5.1 programs of every stage into typed declarations and instructions
- Reads `RDEF` reflection, input, output and patch-constant signatures and `STAT` counters from DXBC containers
- Decodes Shader Model 6 DXIL from its LLVM bitcode into types, constants, metadata and function bodies
- Reads DXIL reflection metadata, the `PSV0` pipeline state part and a ray tracing library's `RDAT` subobjects
- Lists the texture and sampler registers each texture read of a DXBC or DXIL program uses
- Reads PS3 `CellGcmTexture` descriptors and `CgBinaryProgram` containers, and decodes RSX fragment and vertex microcode
- Traces which texture units and interpolants can influence an RSX fragment program's outputs
- Reports values as the file stores them, with Direct3D's own enum numbers
- Reports every refusal with the byte, word or bit where it happened and what was expected there
- Contains no `unsafe` code and does no file, environment or process access in the libraries

## Getting Started

### Requirements

Rust 1.99 or newer (edition 2024). The repository pins its toolchain in `rust-toolchain.toml`.

### Installation

| Crate | Reads |
|-------|-------|
| [`dxcontainer`](dxcontainer) | The DXBC container, its digest and its `SFI0` flags; writes containers |
| [`d3d9-reader`](d3d9-reader) | Direct3D 9 token streams, Shader Model 1.0 to 3.0, with `CTAB` |
| [`dxbc-reader`](dxbc-reader) | DXBC, Shader Model 4 and 5, with reflection, signatures and statistics |
| [`dxil-reader`](dxil-reader) | DXIL, Shader Model 6, with reflection, `PSV0` and `RDAT` |
| [`rsx-reader`](rsx-reader) | PS3 texture descriptors, Cg binary programs, fragment and vertex microcode |

`dxcontainer`, `dxbc-reader`, `dxil-reader` and `rsx-reader` are published on crates.io at 0.4.0:

```sh
cargo add dxbc-reader
```

`d3d9-reader` is not published yet, and Shader Model 5.1 support in `dxbc-reader` is newer than the published 0.4.0.
For either, depend on the repository:

```toml
d3d9-reader = { git = "https://github.com/Kalmarv/dx" }
dxbc-reader = { git = "https://github.com/Kalmarv/dx" }
```

### Usage

Read a Shader Model 5 program from a compiled shader and list its resource bindings:

```rust
fn main() -> Result<(), dxbc_reader::Error> {
    let container = std::fs::read("shader.dxbc").expect("a compiled shader");
    let code = dxbc_reader::code(&container)?; // the SHDR/SHEX part as 32-bit words
    let program = dxbc_reader::decode(&code)?;
    println!("{} with {} instructions", program.target(), program.instructions.len());

    if let Some(rdef) = dxbc_reader::rdef(&container)? {
        for binding in &rdef.bindings {
            println!("{} at register {}", binding.name, binding.register);
        }
    }
    Ok(())
}
```

Each crate has runnable examples that take file paths:

```sh
cargo run -p dxbc-reader --example inspect_dxbc -- dxbc-reader/tests/fixtures/modes.dxbc
cargo run -p dxbc-reader --example pairs_dxbc -- shaders/
cargo run -p dxil-reader --example inspect_dxil -- shader.dxil
cargo run -p dxil-reader --example pairs_dxil -- shaders/
cargo run -p dxcontainer --example parts -- shader.dxbc
cargo run -p dxcontainer --example rewrite -- in.dxbc out.dxbc SHEX=replacement.bin
cargo run -p rsx-reader --example inspect_rsx -- texture.bin shader.fpo
```

Run the tests with `cargo test --workspace`; they use committed compiler output and hand-built bytes, and need no game files.

Each crate's README describes what it reads and refuses. See [CONTRIBUTING.md](CONTRIBUTING.md) for the checks and for
reporting a file the readers cannot read. Licensed GPL-3.0-or-later.
