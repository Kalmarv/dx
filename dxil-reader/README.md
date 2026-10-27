# dxil-reader

A bounded reader of DXIL, the Direct3D Shader Model 6 program format: it decodes the LLVM bitcode inside a `DXBC`
container into a module (types, constants, metadata, function bodies) and reads the reflection records DXIL keeps in its
metadata and in its signature and runtime-data parts.

```rust
let container = std::fs::read("shader.dxil")?;
let parts = dxil_reader::parts(&container)?;
let module = dxil_reader::module(&parts, b"DXIL")?.expect("a DXIL part");
println!("{} functions", module.functions.len());

// The records the file stores for its entry point:
let (inputs, outputs) = dxil_reader::reflection::elements(&module)?;
println!("{} input and {} output signature elements", inputs.len(), outputs.len());
for (range, name, _) in dxil_reader::reflection::ranges(&module)? {
    println!("{name}: class {} register {}", range.class, range.lower);
}
```

Run it with `cargo run -p dxil-reader --example inspect_dxil -- <files>`; the source is [`examples/inspect_dxil.rs`](examples/inspect_dxil.rs).

## What it reads

- **Container** (`parts`, over the `dxcontainer` crate): the DXBC directory; Shader Model 6 parts are not 4-byte aligned.
- **Program part** (`program`, `part`): the `DXIL` part's header (program version, size, `DXIL` magic, DXIL version,
  bitcode offset and size); the `STAT` reflection part has the same header (`module(&parts, b"STAT")`).
- **Bitstream** (`bitstream`): LLVM's bitstream container: abbreviations (literal, fixed, VBR, array, char6, blob),
  BLOCKINFO, nesting up to 32 blocks, at most 4096 abbreviations per block and 2^26 record operands, every length checked
  against the bits that remain before anything is allocated. The `llvm-bitcode` crate was considered and not used: it sizes
  allocations from untrusted lengths.
- **Module** (`module`): LLVM 3.7 IR as DXIL stores it, with relative value ids (module version 1): types, globals and
  functions, constants (no constant expressions), metadata (strings, values, nodes, named nodes), value names and function
  bodies. Instructions: binary operators, casts, comparisons, select, extractvalue and insertvalue, vector element and
  shuffle operations, call, phi, ret, branches, switch, unreachable, alloca, load and store. Any other record is refused by
  name.
- **Reflection records** (`reflection`): the entry point and what its properties state (`num_threads`, `geometry_state`,
  `mesh_state`, `hull_state`, `domain_state`; a library's `library_kind`); signature elements and their packing
  (`elements`, `patch_elements`); the bound resource ranges of `dx.resources` (`ranges`: class, range id, register, count,
  shape, space, element type and stride tags, counter); the field annotations of `dx.typeAnnotations` (`fields`); and the
  rows of an `ISG1`/`OSG1`/`PSG1` part (`signature`).
- **Runtime data** (`rdat`): a library's subobjects as its `RDAT` part stores them (state object and pipeline configuration,
  root signatures, associations, hit groups), and a function's export name from its decorated name.
- `operations`: the `dx.op` operations a container's module calls, by name, for surveying shaders.

## What it guarantees

- **Bounded.** Every length, count and reference is checked against what exists before allocation; a crafted file produces
  an `Error` naming the bit offset (in the bitcode, or eight times a byte of the container or part), never a panic or an
  unbounded allocation.
- **Function bodies are self-consistent.** Every value an instruction reads is one of the function's (an earlier one, or a
  later one a phi or a loop reads), every branch target and phi predecessor is a block of it, every instruction is in a
  block, and a call has as many arguments as its callee has parameters.
- **Records as stored.** Resource classes, kinds and shapes keep DXIL's and D3D's own numbers.

## What it does not do

It does not execute, optimise or translate programs, does not write bitcode, and does not read LLVM modules that are not
DXIL's dialect (LLVM 3.7 IR as dxc emits it). The container digest is not verified. Reflection helpers that are given a
module without the metadata they look for return an error naming what is missing; some of those errors report bit 0,
because a metadata node has no position of its own.

## Tests

`cargo test -p dxil-reader`: every committed fixture in `tests/fixtures` (110 `.dxil` files compiled by dxc 1.7 from the
HLSL beside each, with the command in each file; `.od` files with `-Od`) is read, control-flow and memory fixtures are checked
in detail, and `RDAT` data laid out by hand exercises every subobject kind and the refusals. No game files are needed.

License: GPL-3.0-or-later.
