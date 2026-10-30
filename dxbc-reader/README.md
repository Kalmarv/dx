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
- **Operand formats** (`operand_format`, `Instruction::format`, `Instruction::destinations_and_sources`): for each
  instruction opcode, how many destination and source operands it takes and what each carries (float, double, integer, a
  register with no data of its own such as a resource, sampler, view or stream, or data typed by the resource). `decode`
  checks every instruction against it. The table is the one vkd3d's `tpf.c` and DXVK's `dxbc_defs.cpp` both publish (their
  operand counts agree for every opcode both list); `call`, `callc`, `label` and `interface_call` have none. All 3,415,319
  instructions of the 7,729 programs of Sekiro, Riders Republic and Sledding Game have the count and the register class
  their opcode's format gives (109 of the 180 opcodes with a format occur in them).
- **Control bits** (`Instruction::precise_mask`, `sync_flags`, `info_return`; `Declaration::global_flags` and the
  accessors of the geometry and tessellation declarations): the bits of the opcode token that the programs of the three
  games use, read as the fields the token format gives them: the `precise` mask (4,960 instructions of Riders Republic's
  programs), the flags of a `sync` (245 in Riders Republic), the return type of `resinfo` and `sample_info`, the global
  flags (bits 0 to 5 occur), a geometry program's input primitive, output topology and vertex count, and a hull and
  domain program's control point counts, domain, partitioning, output primitive, largest factor and phase instance
  counts. The values are Direct3D's own numbers, as stored.
- **Texture reads** (`texture_reads`): every `sample`, `gather4`, `lod` and `ld` family instruction that names a `t`
  register, with the texture register, the sampler register (none for a load, which uses no sampler), whether the
  instruction compares, and the mode the program declares the sampler with. In Sekiro's 9,204 distinct programs (the
  renderer, effect, material and character bundles) a texture register is read with exactly one sampler register in all
  but 11 of 89,699 sampled slots, and an instruction compares exactly when its sampler is declared a comparison sampler.
  `cargo run -p dxbc-reader --example pairs_dxbc -- <files or folders>` prints the pairs of each program.
- **Reflection** (`rdef`, `rdef_target`): the `RDEF` part of the Shader Model 4 layout (no tag) and the Shader Model 5 one
  (`RD11`): resource bindings, constant buffers with their variables, default values and type trees.
- **Signatures** (`signature`, `signature_elements`, `patch_signature_elements`): `ISGN`, `OSGN`, `ISG1`, `OSG1`, `OSG5`,
  `PCSG` and `PSG1` parts.
- **Statistics** (`statistics`): the `STAT` part, the compiler's counters, with accessors for the words checked against
  `D3DReflect`.
- **Container** (`parts`, over the `dxcontainer` crate).

Numbers are Direct3D's own (`D3D_NAME`, `D3D_SHADER_INPUT_TYPE`, `D3D_REGISTER_COMPONENT_TYPE`, ...), as stored.

## What it guarantees

Reflection tables are bounded before they are read, strings must end inside their part and be UTF-8, and a type tree is
refused where it nests deeper than 32 or refers to itself. Operands nest at most three deep. Whatever cannot be read
(a truncated instruction, an out-of-range table, an operand register type it has no name for, an unexpected number of index
dimensions, an operand count other than the opcode's format) is an `Error` naming the 32-bit word where it happened.

## What it does not do

It does not execute, translate or validate programs. Declarations of the tessellation and geometry stages (and interface
tables) are kept as `Declared::Other` with their raw words (`Declaration`'s accessors read their values). Nothing in the
7,729 programs of Sekiro, Riders Republic and Sledding Game needs more: they hold no Shader Model 5.1 program (their
version tokens are 4.0 and 5.0), no 64-bit immediate or 64-bit index, no operand register type the decoder lacks, no
extended operand token but the modifier, no `interface_call` or interface declaration, and no signature element with a
nonzero stream or minimum-precision column (all 691,630 elements of the `ISG1`, `OSG1`, `OSG5` and `PSG1` parts of the five
games' containers state stream 0 and minimum precision 0, so the signature records do not carry them); the decoder
refuses each of the other cases by name rather than reading it. `RDEF` parts of other record layouts than
Shader Model 4's and 5's are refused. Shader Model 6 is `dxil-reader`'s.

## Tests

`cargo test -p dxbc-reader`: token streams assembled by hand (a vertex program, typed declarations, an instruction's
controls and extended tokens, the refusals by name) and the 30 committed fixtures in `tests/fixtures`, compiled by `fxc`
from the HLSL beside each (`.od` files with `/Od`), each read to its end. No game files are needed.

## Check the examples

From the repository root, `cargo test -p dxbc-reader --doc` checks the crate documentation, and
`cargo build -p dxbc-reader --examples` builds its example programs. Examples that read paths need the caller's files; the repository ships no game assets.

License: GPL-3.0-or-later.

`sample_info` and `sample_pos` can query the rasterizer register (operand type 14), retained as the token format names it.
