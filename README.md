# dx

[![crates.io: dxbc-reader](https://img.shields.io/crates/v/dxbc-reader?label=dxbc-reader)](https://crates.io/crates/dxbc-reader) [![crates.io: dxil-reader](https://img.shields.io/crates/v/dxil-reader?label=dxil-reader)](https://crates.io/crates/dxil-reader) [![crates.io: dxcontainer](https://img.shields.io/crates/v/dxcontainer?label=dxcontainer)](https://crates.io/crates/dxcontainer) [![crates.io: rsx-reader](https://img.shields.io/crates/v/rsx-reader?label=rsx-reader)](https://crates.io/crates/rsx-reader) [![docs.rs](https://img.shields.io/docsrs/dxbc-reader)](https://docs.rs/dxbc-reader) [![CI](https://img.shields.io/github/actions/workflow/status/Kalmarv/dx/ci.yml?branch=main&label=CI)](https://github.com/Kalmarv/dx/actions/workflows/ci.yml) [![release](https://img.shields.io/github/v/release/Kalmarv/dx)](https://github.com/Kalmarv/dx/releases/latest)

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
- Writes Shader Model 4, 5 and 5.1 and Direct3D 9 listings byte for byte as Microsoft's disassembler does
- Writes DXIL listings byte for byte as `dxc -dumpbin` (dxc 1.9.2609) does
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
| [`dxil-reader`](dxil-reader) | DXIL, Shader Model 6, with reflection, `PSV0`, `RDAT` and the `dxc -dumpbin` listing |
| [`rsx-reader`](rsx-reader) | PS3 texture descriptors, Cg binary programs, fragment and vertex microcode |

All five are published on crates.io:

```sh
cargo add dxbc-reader
```

The `dx` command-line tool is not on crates.io. Download it for Windows or Linux (x86_64) from the
[latest release](https://github.com/Kalmarv/dx/releases/latest), or build it from the repository:

```sh
cargo install --git https://github.com/Kalmarv/dx dx
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

### Command line

The `dx` tool reads compiled programs from disk:

```sh
cargo install --path dx
dx disasm shader.dxbc                 # Microsoft's listing; a folder lists every program in it
dx disasm shader.dxil                 # a DXIL program's listing as dxc -dumpbin writes it
dx disasm --flags 0x04 shader.cso     # with D3D_DISASM_* flags: 0x04 numbers the instructions
dx disasm --check shaders/            # compare with NAME.txt / NAME.asm beside each, counted by model and stage
dx reflect --json shader.dxbc         # bindings, buffers, signatures, STAT, SFI0 and level 9 tables as JSON
dx reflect shader.dxil                # a DXIL program's signatures, entry point, resources and buffer layouts
dx info shader.dxbc                   # parts, offsets, sizes, digest
```

A DXBC container and a Direct3D 9 token stream are told apart by their first bytes, and a container holding a `DXIL`
part is listed as dxc lists it. A DXIL listing has no `--flags`.

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
