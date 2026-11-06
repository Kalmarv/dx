# Changelog

## Unreleased

- `dxbc-reader`: `/Zi` listings are Microsoft's where three new kinds of program made them differ:
  - inlinee lines of signature 1 (`CV_INLINEE_SOURCE_LINE_SIGNATURE_EX`, which an inlined function with code from an
    `#include` makes) are read, where they were refused;
  - a binary annotation's code length (op 4) moves the code offset past the row it ends, so the next row's code delta
    counts from there: an inlined call's rows no longer overlap its caller's code, whose instruction got the inlinee's
    `#line`;
  - after an instruction, an inlined call's variables are written only where the instruction is in the code the call
    spans (from its first row to its last, its nested calls' code and its caller's code between its rows among it); a
    function's own variables after any instruction, as before. The caller's code that leads into a call wrote the
    call's parameters early.
- `dxbc-reader`: 22 new fixture programs and their 506 listings (`tests/disasm`; 4,508 listings of 196 programs, 104 of
  them `/Zi` builds): inlined calls from an included file, two and three deep, in a loop and with an else
  (`zi_inlined`, `zi_scopes`), interface arrays indexed by a register (`classes_arrays2d`), Shader Model 4.0 and 4.1
  vertex, geometry and pixel programs, feature level 9_1 and 9_3 pixel and vertex programs (one a `/Zi` build) and
  Shader Model 5.1 pixel and compute programs with register spaces and unbounded arrays. `generate.py` takes the
  sources to build and copies the `.hlsli` files beside them.
- `dxil-reader`: `reflection::bindings` reads the bound resources as dxc's listing writes them in its Resource Bindings
  table, in its order, each a `Binding` with that table's names (`class_name`, `format_name`, `dimension_name`,
  `id_name`, `bind_name`); the listing writes the table from them. The listing's feature notes take their names from
  `dxcontainer::feature_name`, where it kept a copy of the table.
- `dx reflect` on a DXIL program lists its resources in dxc's order with dxc's names: `format` is `byte` or `struct`
  for a raw or structured buffer (it was empty), `dimension` is `r/o`, `r/w` or `r/w+cnt` for one and has a
  multisampled texture's sample count (`2dMS4`; it was the resource kind's name, `structbuf`), `NA` for a buffer or
  sampler; `id_name` and `bind` are new. `tests/reflect.rs` compares its signatures, resources and target with
  dxc's listings of the 129 DXIL fixtures.
- `dx info` writes a container's `SFI0` feature flags as `dx reflect` does (`bits`, `names`, `unnamed`), where it wrote
  the names alone and left out a set bit with no name. `tests/reflect.rs` compares the names with the features
  Microsoft's listings note for the 34 DXBC fixtures with an `SFI0` part.
- `dx`: `tests/cli.rs` checks `dx disasm` over corpus folders: a listing named by the whole file name, one named by the
  stem only where no other program shares it, a folder's files that are not programs left out, `--check` failing on a
  differing listing and where no program has one.
- `dxil-reader`: `ops.rs` is written by `cargo xtask dxil-ops` (a Rust task in the workspace) from the operation tables
  dxc 1.9.2609 commits in C++ (`DxilOperations.cpp`, `DxilInstructions.h`, `DxilConstants.h`), where `generate_ops.py`
  ran dxc's Python database and rustfmt. The tables are the same; the file is marked `@generated`, rustfmt leaves it
  alone, and `cargo test -p xtask` fails when it was edited by hand.

## 0.5.2 (2026-11-06)

- `d3d9-reader`: Shader Model 1 and 2 listings match `D3DDisassemble` in the places they did not:
  - the instruction-slot footer counts pixel 1.x's texture addressing operations as texture slots, vertex 1.1's
    `exp`, `log` and `frc` as the macros they are, `sgn` as 3 slots, and one more arithmetic slot for a predicated
    instruction;
  - `breakp` is listed as Microsoft's disassembler writes it (`break`, then its predicate read as a destination);
  - a `label` takes no instruction number;
  - 3.0's `sgn` with the three sources Microsoft's assembler writes is read whole.
- `d3d9-reader`: `tests/assembled.rs` compares the listings of 287 `D3DAssemble`d programs with `D3DDisassemble`'s,
  with and without instruction numbering, all 574 identical. They cover every Shader Model 1 to 3 operation alone in
  each version, the 105 one-feature programs of iridia-d3d9-ir's executor tests, predication and `breakp`.

## 0.5.1 (2026-11-06)

- `dxbc-reader`: the fixture generator (`tests/disasm/generate.py`) keeps a stored container whose listings under
  every flags word are those of the new build, so a run over unchanged sources changes no file (a `/Zi` build differs
  on every run in its digest and its PDB's GUID and timestamp). The seven `/Zi` builds of `vs_cbuffers.hlsl` were made
  from an earlier copy of the source one line longer; they and their listings are made again from the committed one
  (their `#line` numbers move by one). All fixtures regenerate byte for byte on Linux, with fxc 10.0.26100.4654 under
  Wine (primase-oracles `tools/wine`).
- `dxil-reader`: `generate_ops.py` formats `ops.rs` with rustfmt, so it writes the committed file.

## 0.5.0 (2026-11-06)

- `dxil-reader`: `disasm::disassemble` writes a DXIL container's listing as dxc 1.9.2609's `dxc -dumpbin` does, byte
  for byte: dxc's comment header (feature flags, signature parts, debug name, hash, the `PSV0` runtime information,
  the entry point's signatures, buffer layouts, resource bindings, view-id state and a library's `RDAT` subobjects)
  and the module as LLVM 3.7 prints it, with dxc's comment after each `dx.op` call. The listings are identical to dxc's
  for all 129 fixtures (every stage, ray tracing libraries included; `tests/disasm.rs`) and for all 50,283 of Elden
  Ring's programs (`tests/corpora.rs`, through `GAME_DATA`). `dx disasm` lists DXIL containers, `dx disasm --check`
  compares them with a stored dxc listing and counts them by the program header's target, and `dx reflect` writes a
  DXIL container's signature parts, entry point, resources and constant-buffer layouts.
- `dxil-reader`: the fixtures are compiled by dxc 1.9.2609, where dxc 1.7 compiled them before; `generate.py` refuses
  another build.
- `dxil-reader`: the module keeps what a listing shows, changes for code that builds or matches these types
  exhaustively: `Type::Struct` gains `packed` and `literal`; `Value::Function` gains `properties` (a `GlobalProperties`:
  linkage, visibility, DLL storage, `unnamed_addr`, section, alignment), `calling_conv` and `gc`, `Value::Global`
  gains `properties`, `thread_local` and `externally_initialized`; `Module` gains `triple`, `datalayout` and `asm`;
  `Instruction` gains `flags`; `Op::Call` gains `calling_conv` and `tail`, `Op::Alloca` `inalloca`, `Op::Load` and
  `Op::Store` `volatile` and `atomic`, `Op::Gep` `source` and `inbounds`, and `Op::AtomicRmw`, `Op::CmpXchg` and
  `Op::Fence` carry their orderings (`Atomic`, `Ordering`, `TailCall`); `Constant::String`, `Constant::Compare` and
  `Metadata::Distinct` are new, `Constant::Gep` gains `source` and `inbounds` and `Constant::Binary` `flags`;
  `Function` gains `names`, `block_names` and `block_use_orders`; casts may be `CastOp::AddrSpaceCast`. A
  `getelementptr`'s result keeps its base's address space, where it was space 0. Debug locations, function-local
  metadata, comdats, prologue and prefix data and switch case ranges are refused by name.
- `dxil-reader`: `reflection::struct_annotation` (a struct's size and fields), `shader_model`, `module_shader_flags`
  (the first entry's flags, as dxc reads them, for a library too), `view_id_state`, `component_name` and
  `dimension_name`; `SignatureElement` gains `stream` and the methods `system_value_name` and `format_name`.
  `fields` reads only as many fields as the struct has, where it took DXIL 1.5's template-arguments operand for one.
  `psv` reads the 56-byte runtime info (`RuntimeInfo::group_shared_bytes`, `size`).
- `dxcontainer`: `feature_name` names the DXIL feature bits dxc 1.9.2609 names (to bit 33, and the optional bits 40
  and 41); a DXBC container's names are unchanged.
- `dx`, a new command-line tool (`cargo install --path dx`): `dx disasm FILE|DIR` writes the listing of each DXBC or
  Direct3D 9 program as Microsoft's disassembler does, with its `D3D_DISASM_*` flags (`--flags 0x04`), and
  `--check` compares each with Microsoft's listing stored beside it and counts identical, differing and failed programs
  by shader model and stage; `dx reflect FILE` writes the `RDEF` bindings and buffer layouts, the signatures, the
  `STAT` counters, the `SFI0` flags and the level 9 mappings of a DXBC container, or a Direct3D 9 program's constant
  table, as JSON (`--json`) or indented text, each record with D3D's numbers and the disassembler's names; `dx info
  FILE` writes a container's parts with their offsets and sizes, its digest and whether it matches, its target and its
  `SFI0` feature flags; a DXIL container's target is its `DXIL` part's (`ps_6_0`). A folder holds the files that start
  as a container or a Direct3D 9 program does, so the other files beside them (scripts, tables) are left out and
  counted. `--check` finds a program's listing by its whole file name first (`NAME.vpo.flag24.asm`), and by `NAME`
  alone only where no other program in the folder is `NAME` with another extension; it fails when no program has a
  listing to compare.
- `dxbc-reader`: `disassemble` and `disassemble_with(&[u8], &Options)` write a Shader Model 4, 5 or 5.1 container's
  listing as `D3DDisassemble` (d3dcompiler_47 10.0.26100.4654) does, byte for byte: the header (buffer definitions,
  resource bindings, signatures, functionality notes, tessellation tables), the program and its slot count.
  `Options::from_flags` takes Microsoft's flags word: `0x40` leaves out the header, `0x04` numbers the instructions,
  `0x20` writes their offsets (after the number, `   3  0x00000024: `, with both), `0x80` writes literals in hex
  (`0x02` changes nothing in the text, `0x10` leaves out a level 9 program's debug information); it
  refuses `0x01` (an HTML listing) and `0x08`, which Microsoft's disassembler refuses too. The listings are identical to
  Microsoft's for all 2,443 programs of Riders Republic's shader pack and all 432 of Sekiro's under each of 23 flag
  words, and for 1,817 listings of 79 fixture programs under the same 23 (no flags, and the flags that change the text
  alone, in pairs and all together), class linkage and `fxc /Zi` builds included.
- `dxbc-reader`: the listing writes an operand's minimum precision as Microsoft's does where an instruction mixes
  precisions: a source says `{def32 as min16f}` only where it is read at the result's precision (a source of the
  first destination's type, not a comparison's or a shift's amount), every other operand its own (`{min16u}`, none for
  full precision), and an absolute value holds it inside its bars (`|r0.z {min16f}|`). It wrote both precisions on
  every operand that differed from the first, destinations, conversions, load addresses, resources and samplers
  included: 20 of the 3,316 `ps_4_0` programs of Sledding Game's Unity player differed for it.
- `dxbc-reader` and `d3d9-reader`: real-data tests (`tests/corpora.rs`, through `primase-testdata` and `GAME_DATA`;
  each skips where its oracle entry is not configured) compare the listing with Microsoft's for whole games:
  Riders Republic's 2,443 programs, Sekiro's 432 under 23 flag words (9,936 listings), Sledding Game's Unity
  player's 4,854 (16 of them `/Zi` builds), Shaun White Skateboarding's 7,306
  and three more of its programs. The counts quoted in this file were one-off runs before.
- `dxbc-reader`: the tests compare the listing with Microsoft's for the 19 test programs of t7_dxbc (MIT, copied with
  its licence into `tests/third-party/t7_dxbc`), HLSL this crate's listing was not written against.
- `dxbc-reader`: `interfaces` reads the `IFCE` part of a program with class linkage: its class types, class instances
  and interface slot records (`Interfaces`, `ClassType`, `ClassInstance`, `InterfaceSlots`). The listing writes them
  as Microsoft's does, its quirks included (eight entries a slot row, the ninth skipped). `decode` types the class
  linkage declarations (`Declared::FunctionBody`, `FunctionTable`, `Interface`), refusing one whose count word does
  not match its length; they were `Declared::Other` before, a change for code that matched on them. The listing
  writes `fcall fp#[array][call site]` and `dcl_interface fp#[array][call sites]`, where it wrote the call site as an
  operand and the table count before. `RdefVariable` gains `textures` and `samplers`, the registers a class instance
  holds (the `// Texture:` lines of the buffer definitions), and `rdef` reads an interface pointer buffer, whose
  variables are counted in slots and an unused one has none, where it refused it. `dx reflect` writes the class
  tables and those registers.
- `dxbc-reader`: `level9` reads the `Aon9` part of a container compiled for a Direct3D 9 feature level
  (`ps_4_0_level_9_1` and the like): the Direct3D 9 program and the tables that map constant buffers, samplers and
  resources onto its registers (`Level9`, `ConstantMapping`, `ScalarMapping`, `SamplerMapping`, `RuntimeConstant`).
  The listing writes them and the program, as Microsoft's does. `dxbc-reader` now depends on `d3d9-reader`.
- `dxbc-reader`: the listing writes the `SPDB` part of an `fxc /Zi` build as Microsoft's does: `#line N "file"` and
  `#line N` lines (the inlined function's line where an instruction is inlined), the variables' initial locations
  before the first instruction with a line (`// Initial variable locations:`, one line to a register), and after an
  instruction the locations that start at the next one (`// r0.x <- c.x; r0.y <- uv.y`, with `Prior locations: `
  after an `else`), struct members, array elements, matrix elements and vector components named by the PDB's types;
  `0x10` leaves them out (`Options::debug_info`). The PDB is read from the part's bytes (MSF streams, DBI modules,
  C13 lines, checksums and inlinee lines, symbols, types). All 4,854 programs of Sledding Game's Unity player are now
  identical, its 16 `/Zi` builds included, and so are the listings of 92 `/Zi` fixture programs (with and without
  `/Od`, class linkage, every stage, level 9) under the 23 flag words. `dx disasm` no longer warns about them.
- `d3d9-reader`: a constant table may name a constant once in each register set: fxc gives a uniform read both as
  an integer and as a float a range in each (`int2 limit` as a loop count in `i0` and a float in `c0`). Reading
  refused the second; it now refuses a name only when it repeats within one set, and the listing names such a
  parameter once and lists both registers, as Microsoft's does.
- `d3d9-reader`: the `DBUG` comment of an `fxc /Zi` build is read (`Program::debug`, a `DebugInfo`: source files,
  each record's line, each variable's locations), and the listing writes it as Microsoft's does: a `#line N "file"`
  where the file changes and `#line N` where the line moves by more than 2, each after a blank line, and after a line
  the variables it writes, `  // p<0,1>, ::o<1,2,3,0>, C::k<0>`; `0x10` leaves them out (`Options::debug_info`). A
  feature level 9 container's Direct3D 9 program gets them the same way: its section of the listing is identical to
  Microsoft's for 16 `/Zi` programs under each flag word. `Program` has a new field.
- `dxbc-reader`: the names the listing gives reflection records are methods, so a caller can print the same ones:
  `RdefBinding::type_name`, `format_name`, `dimension_name` and `register_prefix`; `RdefType::type_name` and
  `scalar_name`; `SignatureElement::system_value_for` (a pixel program's outputs store no system value; theirs is the one
  the semantic names), `system_value_name` and `format_name`.
- `d3d9-reader`: `disassemble_with(&[u8], &Options)` and `Options::from_flags`, the same flags as `dxbc-reader`'s. The
  listings are identical to Microsoft's for all 7,306 programs of Shaun White Skateboarding (6,207 `ps_3_0`, 1,099
  `vs_3_0`) and 1,035 listings of 45 fixture programs (`vs_1_1` and `ps_1_1` to `ps_3_0`) under the 23 flag words,
  struct parameters, co-issue (`  + mov r0.w, v0`, which takes no slot and no number), `nop` (no slot and no number
  either; it was counted as one arithmetic slot) and the texture and arithmetic slot split included. The Shader Model 1 fixtures are written from their tokens, which fxc no longer compiles.
- `dxbc-reader`: `decode` refuses an instruction whose trailing words decode as more operands than its opcode's
  format has, naming the count, where it took the first operands before. A change for code that relied on it.

- `d3d9-reader`, a new crate: Direct3D 9 shader bytecode (vs/ps 1.x, 2.0, 2.x and 3.0, and the 2.x and 3.0 software
  profiles), from the version token to `END`, as typed records. `read` gives a `Program` of declarations, `def`/`defi`/
  `defb` definitions, instructions (opcode, control bits, predicate, co-issue, destination with mask, modifiers and
  result shift, sources with swizzles, modifiers and relative addressing through `a0` or `aL`) and comments, with the
  `CTAB` constant table read; `records` gives the same records one at a time, and `frame` reads a program at the start
  of a larger buffer and returns the bytes it spans. Each program is read under its own version's opcodes, register
  types and operand counts, and every refusal names its word. The reader and the `CTAB` reader come from
  `iridia-d3d9`, which kept only the `vs_3_0`/`ps_3_0` subset it lifts and now reads through this crate. `disassemble` writes a
  program's listing as Microsoft's disassembler does, byte for byte (the constant table, the program and its
  instruction slot count). Tests are token streams laid out by hand.
- `dxbc-reader`: Shader Model 5.1 programs decode, where `decode` refused their operands before. A 5.1 resource,
  sampler, view or constant buffer operand names the declaration's id first (`T1[r1.x + 4]`: id 1, then the register;
  `CB1[r0.w + 0][0]`: id 1, the register, the row); a 5.1 declaration states `[id][lower][upper]` and the register
  space, and a constant buffer's rows in a word of their own. The binding variants of `Declared` gain
  `range: Option<RegisterRange>` (the first and last register, `u32::MAX` for an array of no stated size, and the
  space; `None` before 5.1), their `slot` is the id in 5.1, and `Declared::registers` gives the registers and space of
  either model. `TextureRead` gains `texture_space` and `sampler_space`, and in 5.1 its `texture` and `sampler` are the
  registers the instruction reads and its `sampler_mode` the declaration of the id. A change for code that builds or
  matches these exhaustively.
- `dxbc-reader`: `rdef` reads the Shader Model 5.1 layout (the tag `13 13 44 25` in place of `RD11`, 40-byte binding
  records) where it refused it before. `RdefBinding` gains `space` (the register space, 0 in the earlier layouts) and
  `id` (the resource's id, `Some` in 5.1 only), and `RdefVariable` gains `flags` (`D3D_SVF_USED` and the rest, stored
  at the same place in every layout): a change for code that builds these structs.
- The fixtures `reflection_sm51.hlsl` (fxc 10.0.26100.0 `ps_5_1` and `ps_5_0`: a texture array, three register spaces,
  a constant buffer variable the program never reads) and `bindings_sm51.hlsl` (`cs_5_1`: every kind of binding
  declaration, constant buffer arrays, an array of no stated size read through `NonUniformResourceIndex`) check each
  field against `fxc -dumpbin`. Over the 11,226 Shader Model 4 and 5.0 programs locum captured from eleven D3D11
  games, `rdef` and `decode` give the bindings, constant buffers and atomics locum's own readers do.

## 0.4.0 (2026-10-29)

- `dxbc-reader`: `texture_reads(&Decoded)` lists the texture reads of a program (`TextureRead`: the instruction's word and
  opcode, the `t` register, the `s` register, whether the instruction compares, how `dcl_sampler` declares the sampler),
  additive. `dxil-reader`: `sampling::texture_reads(&Module)` lists the sampling and loading `dx.op` calls with the class,
  space and register of the texture's and the sampler's handles (`Handle`, `TextureRead`), additive. Both give a register
  or a handle the program computes as unresolved (`texture_indexed`, `None`). Run over the 9,204 distinct programs of
  Sekiro and the 12,754 of Elden Ring that the render-graph work extracted, the pairs equal the instruction counts of
  fxc's and dxc's own disassembly of every one of them.
- `dxbc-reader`: every instruction opcode has an operand format, `operand_format(opcode)`: how many destination operands
  and how many source operands the token format gives it, and what each carries (`OperandClass`: float, double, integer,
  a register with no data of its own such as a resource, sampler, view or stream, or data whose type the sources disagree
  on or the resource sets). `Instruction::format` and `Instruction::destinations_and_sources` read it, and `decode`
  refuses an instruction whose operand count is not its opcode's, naming the instruction's word (a change: such a
  program was returned before, and the caller refused it). The table is the one vkd3d's `tpf.c` and DXVK's
  `dxbc_defs.cpp` both publish; their operand counts agree for every opcode both list, and every one of the 7,729
  Shader Model 4 and 5 programs of Sekiro, Riders Republic and Sledding Game decodes under it (the class of each slot
  agrees with the register it holds).
- `dxbc-reader`: typed views of the opcode token's control bits, additive: `Instruction::precise_mask` (the `precise`
  mask of bits 19 to 22), `sync_flags` (`SyncFlags`: threads in group, group shared memory, UAV group, UAV global),
  `info_return` (`InfoReturn` of `resinfo` and `sample_info`), `Declaration::global_flags` (`GlobalFlags`),
  `geometry_input_primitive`, `geometry_output_topology`, `max_output_vertex_count`, `input_control_point_count`,
  `output_control_point_count`, `tessellator_domain`, `tessellator_partitioning`, `tessellator_output_primitive`,
  `hull_max_tess_factor`, `fork_phase_instance_count` and `join_phase_instance_count`. Their expected values are read off
  Microsoft's disassembly of fxc output; the games' programs use all of them but the reciprocal-float query type and the
  join phase count.
- `dxcontainer`: `serialize` writes parts as a container (header, directory, the parts in order, exactly as given, the
  digest `checksum` computes), `repair_digest` rewrites the digest of a container edited in place, `replace_part` replaces
  or appends one part. `serialize(&chunks(bytes)?)` is `bytes` again for every container that stores the digest
  `checksum` computes: all 77,457 stock containers of the five games.
- `rsx-reader` fragment programs (breaking: `fragment::Control` changes): a `CAL` names its target (`Control::Call::target`, a
  byte offset like every other branch offset, which `decode` now requires to be an instruction boundary), `REP` has its
  own variant `Control::Repeat { counts, end_offset }` (it shared `Control::Loop`, whose `initial` and `increment` it
  does not have: Mesa found the three byte fields always filled with one value), and the end offsets of `IFE`, `LOOP`
  and `REP` are masked to 31 bits as the else offset was. `Opcode::from_code` and `Opcode::mesa_name` give the opcode of a
  number and Mesa's name for it, the table of the 55 numbers Mesa's `nvfx_shader.h` defines (11 are named differently from
  RPCS3's; `PKG`, `UPG`, `DP2`, `NRM`, `DIVSQ` and the two fences have no Mesa name). No `CAL`, `LOOP`, `REP` or `BRK` occurs in
  the 3,267 distinct fragment microcodes of Tony Hawk's SHRED (its branch opcodes are `IFE`, 536 times, with bits 30 and 31
  of the end offset clear in all, and `RET`, 3 times).
- `rsx-reader`: `vertex::decode` reads RSX vertex program microcode (128-bit slots, a vector and a scalar operation per
  slot) into typed instructions, with `Program::input_mask`, `output_mask` and `register_count` that equal a program
  header's fields in all 170 distinct vertex programs of Tony Hawk's SHRED.
- `dxil-reader` (breaking: new pub fields): the attribute groups and lists of the module are kept (`Module::attribute_groups`,
  `attribute_lists`, with `Module::function_attributes` and `string_attribute` for a function value, which names its list
  in the new field `Value::Function::attributes`), and so are the metadata kind names (`Module::kinds`, `kind_name`) and the
  metadata attached to each instruction (`Instruction::attachments`; `precise` stays) and to a function
  (`Function::attachments`). `reflection` reads the entry properties as stored (`entry_properties`) and the ones the
  games and dxc write beside the existing states: `ray_payload_size`, `ray_attribute_size`, `auto_binding_space` (and
  `library_binding_space` for the library's resource record), `wave_size`, `amplification_payload_size` (`num_threads`
  also reads an amplification program's thread group); the tail tags of signature elements (`element_tags`: stream,
  dynamically indexed components, usage mask; `usage_masks` is the same list through it); the optional fields of the
  resource records (`resource_extras`: sample count, global coherence, rasterizer order, 64-bit atomic use, the tags);
  and the entry function's denormal mode (`fp32_denorm_mode`, the string attribute `fp32-denorm-mode`). Code that builds
  an `Instruction`, a `Function` or a `Value::Function` by struct literal must add the fields. Of the 69,728 programs of
  skate. and Elden Ring, no function carries `fp32-denorm-mode` (Elden Ring's 4,281 library functions carry nine other
  string attributes), no element has a tail tag but 3, no resource record sets coherence or rasterizer order, and only
  seven views of Elden Ring (three with 2 samples, four with 4) and one of skate.'s (2 samples) have a non-zero sample count.

## 0.3.0 (2026-10-27)

Breaking:

- `dxil-reader`: `module::Instruction` has a new field `precise`, set for an instruction that carries the `dx.precise`
  attachment (the compiler writes it for HLSL's `precise`), and `Module` a new field `precise_kind`; the function
  body's `METADATA_ATTACHMENT` block is read for it (it was skipped). Code that builds an `Instruction` or a `Module`
  by struct literal (the former without `..`) must add the field; matching with `..` and reading are unaffected. In
  skate.'s stock programs 107,109 instructions of 3,185 of 3,341 vertex programs and 360 of 12 compute programs
  carry it (on calls: 88,541 `tertiary`, 13,005 `loadInput`, 3,546 `unary`, 1,421 `dot3`, 331 `legacyF16ToF32`, 307
  `binary`, 213 `dot4`, 105 `dot2`), no pixel program does, and none of Elden Ring's 50,283.

Additive (no existing item changes):

- `dxcontainer`: `feature_flags` reads a container's `SFI0` part (the shader's required features, a `u64`), `Bytecode`
  says which compiler's bits they are (`SHDR`/`SHEX` or `DXIL`), `feature_name` names a bit. Each named bit was read off
  `fxc` and `dxc` output for programs that need one feature each (bits 0 to 13 for `fxc`; 0, 2 to 6, 8 to 20, 22 to
  26 and 28 to 30 for `dxc`); the compilers' own descriptions are the names. Over the stock containers the flags
  read in all 69,728 `DXIL` containers (skate., Elden Ring) and the 21 of Unity's 4,854 `DXBC` containers that have the
  part, with no unnamed bit set; Sekiro's 432 and Riders Republic's 2,443 have no `SFI0`. The digest `checksum`
  equals the stored one in all 77,457 stock containers of the five corpora (none all-zero, none unsigned).
- `dxbc-reader`: `statistics` reads the `STAT` part of a Shader Model 4 or 5 container, the compiler's counters, with
  accessors for the words that equal `D3DReflect`'s `D3D11_SHADER_DESC` fields on every container that has the part
  (432 Sekiro, 16 Unity, 21 compiled for the purpose) and for the `movc` count; it refuses a `DXIL` container's `STAT`
  part, which is a bitcode module.
- `dxil-reader`: `psv::read` and `psv::part` read the `PSV0` part (runtime information of 36, 48 or 52 bytes, resource
  records of 16 or 24 bytes, string and semantic-index tables, 16-byte signature elements, the dependency words).
  Its stage, thread group, resource ranges, signature elements and vector counts equal the metadata's in the 19,240
  skate. and 46,002 Elden Ring stock programs that have the part. `reflection::shader_flags` reads the entry
  properties' tag 0 and `reflection::usage_masks` the usage mask of each signature element (tag 3 of its trailing tag
  list).
- `rsx-reader`: `fragment::InputSource` names an input operand's index: 1 is the first colour, `4 + k` texture
  coordinate set `k` (checked against the program header's masks in all 3,268 distinct fragment programs of Tony
  Hawk's SHRED); `SourceKind::input_source` gives it for an operand.

## 0.2.0 (2026-10-27)

- `dxbc-reader`: `patch_signature_elements` reads the `PSG1` part where a hull or domain program has no `PCSG` (fxc
  writes `PSG1` and the 32-byte `ISG1`/`OSG1` records when a `min16float` is in the program); `signature` takes
  `PSG1`. `rdef` reads the Shader Model 4 layout (28-byte header, 24-byte variable and 16-byte type records, no
  `RD11` block) of a target 4.x `RDEF` part instead of refusing it at the tag.
- `dxil-reader`: `Type::Pointer` carries its address space (`Pointer(TypeId, u32)`), so a pointer to one type in
  space 0 and one in space 3 are two types. Breaking: callers match `Type::Pointer(pointee, _)`.
- `rsx-reader`: `Instruction::perspective_input` is `interpolant_flag`. It is bit 31 of the last operand word as
  stored; the disc's programs show it is a per-interpolant flag, clear on every texture lookup's coordinate, but not
  what it selects. `input_address` is documented as it reads in those programs (bits 21 to 29 all ones whenever an
  interpolant is read). Breaking: the field is renamed.

## 0.1.1 (2026-10-27)

- Depends on `primase-foundations` 0.2 (its Oodle decoder changed; these crates do not use it), so a build has one
  copy of it. `dxil-reader` and `rsx-reader` are first published at 0.1.1.

## 0.1.0 (2026-10-27)

- First release of four crates:
  - `dxcontainer`: the DXBC container that holds Direct3D shader bytecode (Shader Model 4 to 6): its part directory and digest.
  - `dxbc-reader`: Shader Model 4 and 5 bytecode as typed declarations and instructions, with RDEF reflection and signatures.
  - `dxil-reader`: Shader Model 6 programs (LLVM bitcode) as modules, with resource, signature and RDAT reflection records.
  - `rsx-reader`: PlayStation 3 RSX texture descriptors, Cg binary program containers and fragment program microcode.
