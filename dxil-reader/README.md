# dxil-reader

A bounded reader of DXIL, the Direct3D Shader Model 6 program format: it decodes the LLVM bitcode inside a `DXBC`
container into a module (types, constants, metadata, function bodies) and reads the reflection records DXIL keeps in its
metadata and in its signature and runtime-data parts. It also writes a container's listing as `dxc -dumpbin` does.

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
- **Module** (`module`): LLVM 3.7 IR as DXIL stores it, with relative value ids (module version 1): types (packed and
  literal structs kept apart), globals and functions with their linkage, visibility, section, alignment and calling
  convention, the module's triple, data layout and inline assembly, constants (strings, and the `getelementptr`, cast,
  binary and comparison constant expressions), metadata (strings, values, nodes, distinct nodes, named nodes, kind
  names), the attribute groups and lists (a function names its list; `function_attributes`, `string_attribute`), each
  function body's own symbol table and its blocks' use-list order; the metadata attached to each instruction
  (`Instruction::attachments`, with `dx.precise` also as `precise`) and to a function. Instructions: binary operators
  (with their optimisation flags), casts, comparisons, select, extractvalue and insertvalue, vector element and shuffle
  operations, call (tail marker, calling convention, attributes), phi, ret, branches, switch, unreachable, alloca, load
  and store (volatile, atomic), getelementptr, atomicrmw, cmpxchg and fence. Debug locations, function-local metadata,
  comdats, prologue and prefix data and switch case ranges are refused by name, as is any other record.
- **Texture reads** (`sampling::texture_reads`): every `sample`, `sampleBias`, `sampleLevel`, `sampleGrad`, `sampleCmp`,
  `sampleCmpLevelZero`, `textureGather`, `textureGatherCmp`, `calculateLOD`, `textureLoad`, `bufferLoad` and
  `rawBufferLoad` call, with the class, space and register of its resource's handle and of its sampler's (the handle is
  followed through `annotateHandle` to its `createHandle` or `createHandleFromBinding` call), and whether the call
  compares. In Elden Ring's 12,754 distinct programs a texture register is read with exactly one sampler register in all
  but 15 of 103,299 sampled slots. `cargo run -p dxil-reader --example pairs_dxil -- <files or folders>` prints the pairs
  of each program.
- **Reflection records** (`reflection`): the entry point and what its properties state (`num_threads`, `geometry_state`,
  `mesh_state`, `hull_state`, `domain_state`; a library's `library_kind`); signature elements and their packing
  (`elements`, `patch_elements`); the bound resource ranges of `dx.resources` (`ranges`: class, range id, register, count,
  shape, space, element type and stride tags, counter), and the same as dxc's listing writes them in its Resource
  Bindings table (`bindings`, in its order, each `Binding` with that table's type, format, dimension, id and binding
  names); the struct annotations of `dx.typeAnnotations` (`struct_annotation`:
  the size and each field; `fields`), the shader model (`shader_model`), the serialised view-id state (`view_id_state`); and the
  rows of an `ISG1`/`OSG1`/`PSG1` part (`signature`, with the names dxc's listing gives their system values and formats);
  the entry properties' shader flags (`shader_flags`; the module's, as dxc reads them for a library too,
  `module_shader_flags`) and each
  signature element's usage mask (`usage_masks`). Every entry property as stored (`entry_properties`) and the typed ones
  beside the earlier states: the ray payload and attribute sizes, the auto binding space of the entry and of a library's
  resource record, a required wave size, an amplification program's payload size (its thread group is read by
  `num_threads` too). Each signature element's tail tags (`element_tags`: the geometry stream, the dynamically indexed
  components, the usage mask), the optional fields of each resource record (`resource_extras`: an SRV's sample count, a
  UAV's coherence, rasterizer order and 64-bit atomic use, the tag list), and the string attribute of the entry function
  that states the denormal mode (`fp32_denorm_mode`).
- **Pipeline state** (`psv`): the `PSV0` part the validator writes: runtime information (36, 48, 52 or 56 bytes), resource
  records, strings, semantic indices, signature elements and the dependency words.
- **Runtime data** (`rdat`): a library's subobjects as its `RDAT` part stores them (state object and pipeline configuration,
  root signatures, associations, hit groups), and a function's export name from its decorated name.
- `operations`: the `dx.op` operations a container's module calls, by name, for surveying shaders.

## The listing

`disasm::disassemble(&container)` writes the text dxc 1.9.2609's `dxc -dumpbin` prints, byte for byte: dxc's comment
header (the `SFI0` feature flags, the signature parts, the debug name and hash, the `PSV0` runtime information, the
entry point's signatures with their interpolation modes, the buffer layouts, resource bindings and view-id state of the
reflection module, a library's `RDAT` subobjects), then the module as LLVM 3.7 prints it, with dxc's comment after each
`dx.op` call. The operation table is generated from dxc's own operation database at v1.9.2609
(`cargo xtask dxil-ops`, which reads the tables from the C++ dxc generates from it). A program it can't list is an error, never a listing that differs from dxc's.

```rust
let container = std::fs::read("shader.dxil")?;
print!("{}", dxil_reader::disasm::disassemble(&container)?);
```

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

`cargo test -p dxil-reader`: every committed fixture in `tests/fixtures` (132 `.dxil` files compiled by dxc 1.9.2609 from the
HLSL beside each, with the command in each file; `.od` files with `-Od`) is read, control-flow and memory fixtures are checked
in detail, and `RDAT` data laid out by hand exercises every subobject kind and the refusals. `tests/disasm.rs` compares the
listing of every fixture (every stage, ray tracing libraries included) with dxc's own in `tests/disasm/listings`, which
`tests/disasm/generate.py` compiles and lists; a fixture without its listing fails. No game files are needed.

With `GAME_DATA` naming a real-data configuration, `tests/corpora.rs` compares the listing with dxc's for all 50,283 of
Elden Ring's programs (1,731 `cs_6_0`, 150 `ds_6_0`, 33 `gs_6_0`, 136 `hs_6_0`, 4,281 `lib_6_3`, 25,183 `ps_6_0`, 18,769
`vs_6_0`); the inputs are in [`tests/inputs/README.md`](tests/inputs/README.md), and the test skips where they are not
configured.

## Check the examples

From the repository root, `cargo test -p dxil-reader --doc` checks the crate documentation, and
`cargo build -p dxil-reader --examples` builds its example programs. Examples that read paths need the caller's files; the repository ships no game assets.

License: GPL-3.0-or-later.
