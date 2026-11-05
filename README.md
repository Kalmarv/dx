# dx

Rust libraries that read compiled shader bytecode: Direct3D 9, DXBC and DXIL programs, and PlayStation 3 RSX programs.
Each one parses a shader binary into typed records and returns an error for malformed input instead of panicking.

## Features

- Reads Direct3D 9 vertex and pixel programs from Shader Model 1.x to 3.0, with the `CTAB` constant table
- Reads the DXBC container that holds every Shader Model 4 to 6 program, and checks or repairs its digest
- Reads Shader Model 4, 5 and 5.1 programs (`fxc` output) of every stage into declarations and instructions
- Reads `RDEF` reflection, input and output signatures and `STAT` statistics from DXBC containers
- Decodes Shader Model 6 DXIL (`dxc` output) from its LLVM bitcode into types, constants, metadata and function bodies
- Reads DXIL reflection metadata and a ray tracing library's `RDAT` subobjects
- Lists the texture and sampler register pairs a DXBC or DXIL program reads
- Reads PS3 `CellGcmTexture` descriptors, Cg binary program containers and RSX fragment microcode
- Reports values as the file stores them, with Direct3D's own enum numbers
- Names the byte, word or bit where a refusal happened and what was expected there
- Contains no `unsafe` code and does no file, environment or process access in the libraries

## Getting Started

### Requirements

Rust 1.99 or newer (edition 2024).

### Installation

| Crate | Reads |
|-------|-------|
| [`d3d9-reader`](d3d9-reader) | Direct3D 9 token streams, Shader Model 1.x to 3.0 |
| [`dxcontainer`](dxcontainer) | The DXBC container and its digest |
| [`dxbc-reader`](dxbc-reader) | DXBC, Shader Model 4 and 5, with reflection and signatures |
| [`dxil-reader`](dxil-reader) | DXIL, Shader Model 6, with reflection and `RDAT` |
| [`rsx-reader`](rsx-reader) | PS3 RSX textures, Cg binary programs and fragment microcode |

`dxcontainer`, `dxbc-reader`, `dxil-reader` and `rsx-reader` are on crates.io:

```sh
cargo add dxbc-reader
```

`d3d9-reader` is not published yet; depend on it from this repository:

```toml
d3d9-reader = { git = "https://github.com/Kalmarv/dx" }
```

### Usage

Read a Shader Model 5 program from a compiled shader:

```rust
fn main() -> Result<(), dxbc_reader::Error> {
    let container = std::fs::read("shader.dxbc").expect("a compiled shader");
    let code = dxbc_reader::code(&container)?; // the SHDR/SHEX part as 32-bit words
    let program = dxbc_reader::decode(&code)?;
    println!("{} with {} instructions", program.target(), program.instructions.len());
    Ok(())
}
```

Each crate has runnable examples that take a file path:

```sh
cargo run -p d3d9-reader --example disassemble_d3d9 -- shader.bin
cargo run -p dxbc-reader --example inspect_dxbc -- dxbc-reader/tests/fixtures/modes.dxbc
cargo run -p dxil-reader --example inspect_dxil -- shader.dxil
cargo run -p dxcontainer --example parts -- shader.dxbc
cargo run -p rsx-reader --example inspect_rsx -- texture.bin shader.fpo
```

Run the tests with `cargo test --workspace`; they need no game files.

Each crate's README describes what it reads and refuses; see [CONTRIBUTING.md](CONTRIBUTING.md) for checks and
reporting a file these readers cannot read. Licensed GPL-3.0-or-later.
