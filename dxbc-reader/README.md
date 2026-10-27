# dxbc-reader

A bounded reader of Direct3D 10 and 11 shader bytecode (DXBC, Shader Model 4 and 5): the token stream of any stage as typed
declarations and instructions, and the `RDEF` reflection and signature parts as the records they store.

```rust
let container = std::fs::read("shader.dxbc")?;
let code = dxbc_reader::code(&container)?; // the SHDR/SHEX part as 32-bit words
let program = dxbc_reader::decode(&code)?;
println!("{} with {} instructions", program.target(), program.instructions.len());

// Reflection and signatures straight from the container:
if let Some(rdef) = dxbc_reader::rdef(&container)? {
    for binding in &rdef.bindings {
        println!("{} at register {}", binding.name, binding.register);
    }
}
let (stage, inputs, outputs) = dxbc_reader::signature_elements(&container)?;
println!("{stage:?}: {} inputs, {} outputs", inputs.len(), outputs.len());
```

Run it with `cargo run -p dxbc-reader --example inspect_dxbc -- <files>`; the source is [`examples/inspect_dxbc.rs`](examples/inspect_dxbc.rs).

## What it reads

- **Program** (`decode`): the version token (vertex, hull, domain, geometry, pixel or compute, version 4.x or 5.x),
  declarations typed where this reader knows them (temps, indexable temps, global flags, constant buffers, samplers,
  resources, UAVs, thread groups, group-shared memory, inputs and outputs, the immediate constant buffer) and every
  instruction with its opcode, control bits, extended tokens (sample offset, resource dimension, return type) and operands
  (register kind, component selection, indices including relative ones, immediates, modifiers, minimum precision).
  Opcode names are those of Microsoft's tokenized program format (`opcode_name`).
- **Reflection** (`rdef`, `rdef_target`): the `RDEF` part of the Shader Model 4 layout (no tag) and the Shader Model 5 one
  (`RD11`): resource bindings, constant buffers with their variables, default values and type trees.
- **Signatures** (`signature`, `signature_elements`, `patch_signature_elements`): `ISGN`, `OSGN`, `ISG1`, `OSG1`, `OSG5`,
  `PCSG` and `PSG1` parts.
- **Container** (`parts`, over the `dxcontainer` crate).

Numbers are Direct3D's own (`D3D_NAME`, `D3D_SHADER_INPUT_TYPE`, `D3D_REGISTER_COMPONENT_TYPE`, ...), as stored.

## What it guarantees

Reflection tables are bounded before they are read, strings must end inside their part and be UTF-8, and a type tree is
refused where it nests deeper than 32 or refers to itself. Operands nest at most three deep. Whatever cannot be read
(a truncated instruction, an out-of-range table, an operand register type it has no name for, an unexpected number of index
dimensions) is an `Error` naming the 32-bit word where it happened.

## What it does not do

It does not execute, translate or validate programs. Declarations of the tessellation and geometry stages (and interface
tables) are kept as `Declared::Other` with their raw words rather than typed. `RDEF` parts of other record layouts than
Shader Model 4's and 5's are refused. Shader Model 6 is `dxil-reader`'s.

## Tests

`cargo test -p dxbc-reader`: token streams assembled by hand (a vertex program, typed declarations, an instruction's
controls and extended tokens, the refusals by name) and the 24 committed fixtures in `tests/fixtures`, compiled by `fxc`
from the HLSL beside each (`.od` files with `/Od`), each read to its end. No game files are needed.

License: GPL-3.0-or-later.
