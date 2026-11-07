# Changelog

## 0.11.0 (2026-11-07)

Fixes for the four programs the rerun of the weekly differential (seed 20261107, with the new fixtures among the
edits' sources) found listed differently from Microsoft's `D3DDisassemble`, which 0.10.0 listed differently too, and
for the rules found while probing them. Each rule has fixtures and their listings from that disassembler; 0.10.1
lists 112 of the new fixtures' 230 listings differently. A minor release: `d3d9_reader::Options` has a new field.

- `d3d9-reader`: the values the constant table stores for its constants are written under
  `D3D_DISASM_ENABLE_DEFAULT_VALUE_PRINTS` (0x02), the new `Options::default_values`; before, the flag changed
  nothing. After the registers, a `Default values` block names each constant that has values, in register order,
  with a row for each of its registers: a bool as `true` (any word but 0) or `false`, an int4 as four signed integers
  and a float4 as four floats as C's `%g` writes them (`c7   = { 0.1, 1e-008, 1.23457e+008, 1.#INF };`).
  Fixtures `defaults.ps30`, `defaults.vs30`, `defaults.ps20`, `defaults.specials.ps30` and
  `pixel.twosets.default.ps30` (a value at an odd byte of the table, which Microsoft reads there). A value that runs
  past the table is still refused: Microsoft's disassembler reads what follows the table for it, or writes
  `<invalid default value offset>` and ends the listing's comments there.
- `dxbc-reader`: an immediate constant buffer register with an immediate index is written as a temp's number is
  (`icb5`, `icb-2`); before, in brackets (`icb[5]`). A relative index is still in brackets (`icb[r0.x + 5]`).
  Fixture `icb_numbers.ps50`.
- `dxbc-reader`: the patch constant signature's Used column is an output's (the lanes written, the complement of the
  never-written mask) in any program but a domain program, whatever stage the version token names; before, in a
  hull program alone. Fixtures `stage_pixel.hs` and `stage_hull.ds`.
- `dxbc-reader`: the tessellation tables follow the `STAT` part whatever the stage: the domain table where the domain
  or the control point count is not 0 (`Undefined` for a domain of 0), the output primitive table where the primitive
  or the partitioning is not 0, in any program; a value with no name is `<internal error>`, as Microsoft writes it.
  Before, the domain table was written where the domain was not 0, the other in a hull program alone, and a value
  with no name was `Undefined`. Fixtures `tessellation_values.hs` and `tessellation_values.ps50`.

## 0.10.1 (2026-11-07)

Fixes for what the first weekly differential run (seed 20261107) found: 13 programs Microsoft's `D3DDisassemble`
(d3dcompiler_47 10.0.26100.4654) listed differently. Ten now list as Microsoft's do, each rule with a fixture and its
listings from that disassembler; 0.10.0 lists 165 of the new fixtures' 230 listings differently and refuses 23. The
other three are malformed input Microsoft lists by reading past it, and are refused with the reason.

- `dxbc-reader`: a conditional's immediate (`if`, `breakc`, `continuec`, `retc`, `discard`, `callc`) is written as an
  integer, as Microsoft writes it (`discard_nz l(0xbf800000)`); before, by what its bits looked like (`l(-1.000000)`).
  Fixtures `conditionals.ps50`, `conditionals_continuec.ps50` and `conditionals_retc.gs50`.
- `dxbc-reader`: the register of a relative index is written with one component: the one a four-component scalar
  selection names, and `x` for any other selection or component count (`x0[r0.x + 0]` for a register selected by the
  mask `yz`). Fixture `relative_index.ps50`.
- `dxbc-reader`: the opcodes the format reserves (107, 209, 218 and 235, `reserved0`) take no operands:
  `Instruction::operands` is empty and the words after the opcode tokens are skipped, as Microsoft's disassembler
  skips them. The listing names 107 `jmp` and the others nothing, with their control bits and extended groups
  (`jmp_sat `, ` [precise(xz)] `, `_aoffimmi(1,2,3) `). Before, the words were read as operands. Fixture
  `reserved.ps50`.
- `dxbc-reader`: in a `/Zi` build, the variable locations after an `else` and after a `call` are labelled
  (`Prior locations:`, `Post-call locations:`) by the opcode, so `else_sat` and `call_sat` keep the label. Fixtures
  `saturated_calls.ps50.zi` and `saturated_else.vs93.zi`.
- `dxbc-reader`: refused, as Microsoft's listing reads the words after them as what is missing: a `call` or `label`
  with no operand and a `callc` with fewer than two, and a `dcl_maxout`, `dcl_hs_max_tessfactor`, hull-phase instance
  count or `dcl_gsinstances` with no word for its value. In `tests/decode.rs`.
- `d3d9-reader`: the register a `def`, `defi` or `defb` defines is written as any destination is, with its result
  modifiers after the mnemonic (`def_sat_pp_centroid`, `defi_x2`, `defb_d2`) and a mask that is not all four lanes
  (`c0.x`, `i0.`). Fixture `versions.definitions.ps30`.
- `d3d9-reader`: a sampler source's swizzle is written (`texld r0, t0, s0.wwxx`); before, it was left out. Fixture
  `pixel.samplers.ps2a`.
- `d3d9-reader`: the header's Parameters are in the constant table's order, as Microsoft lists them; fxc writes the
  table sorted by name, the order dx gave them. Adjacent constants of one name are still one parameter. Fixture
  `pixel.order.ps30`.
- `d3d9-reader`: a `DBUG` comment whose line records do not follow the program is refused: fxc writes a record for each
  declaration, definition and instruction, in stream order, at its byte offset. Microsoft's disassembler follows no one
  rule for such a table: the first record's offset moved past the program drops every note and `#line`, the last
  one's drops its `#line` and keeps its note, two offsets swapped drop a `#line`, and an offset a byte off keeps its
  note. In `tests/stream.rs`.
- Tests: the corpora tests and the slim gate read a folder tree's files one at a time (reads of many files at once
  from a network share failed at random with Windows error 1450) and the rest from zips, on primase-testdata 0.2.5
  (the Elden Ring dxc listings are a zip there).
- Differential: a program Microsoft's disassembler spends 3 s on is set aside as a hang, where it was 10 s: none of
  the first weekly run's 126 hangs finished in 120 s, and a program's listings under every flags word take at most
  0.44 s, so hangs were most of the run. The weekly run of seed 20261107 took 1,671 s with the old patience and
  805 s with 3 s (its special edits 1,053 s and 478 s), on a set of programs a little different, as the new fixtures
  are among the edits' sources. `recheck.py` lists Direct3D 9 findings (`.bin`) as well.

## 0.10.0 (2026-11-07)

Rules of Microsoft's listings found by a differential: dx against `D3DDisassemble` (d3dcompiler_47 10.0.26100.4654)
on generated HLSL and on fxc builds with chosen words edited and the digest redone. Each rule has a fixture with its
listings from that disassembler. Of the 27 new DXBC fixtures' 621 listings, 0.9.1 lists 446 differently (in 22 of
the fixtures) and refuses 32 (`level9_min16`'s two wherever the header is written); in Direct3D 9 it lists
`pixel.specials.ps30` differently and refuses `pixel.precision.ps30`.

- Breaking, `d3d9-reader`: an operand's minimum precision (`D3DSP_MIN_PRECISION`, bits 14 to 15 of a destination or
  source token, which fxc writes in a feature level 9 program's Direct3D 9 part for a `min16float` value) reads as
  `Destination::precision` and `Source::precision` (new `Precision`), and the listing writes it after the operand
  (`{min16f}`, `{min2_8f}`, nothing for 3); before, the operand was refused ("sets reserved bits 14 to 15"). A
  predicate's bits 14 to 15 are read and not written, as Microsoft's listing leaves them out. New fixtures
  `pixel.precision.ps30` (`pixel.ps30` with a precision on every operand but the `dcl` usage tokens) and, in
  `dxbc-reader`, `level9_min16` (`ps_4_0_level_9_1` and `9_3`). A `dcl` usage token with bits 14 to 15 set is still
  refused: Microsoft's listing then writes `dcl vFace` as `dcl_position vFace`.
- `d3d9-reader`: a `def` value that is an infinity or NaN is written as MSVC's `%g` writes it, `1.#INF`, `-1.#INF`,
  `-1.#IND` for the default NaN (0xffc00000) and `1.#QNAN` for another; before, `inf`, `-inf` and `NaN`. New fixture
  `pixel.specials.ps30` (`pixel.flow.ps30` with infinities, NaNs, a denormal and -0 as its `def` values; fxc refuses
  such literals, X4579).
- Breaking, `dxbc-reader`: `Reflection::system_value_name` returns a `&'static str`, and a system value no
  `D3D_NAME` names is `NONE`, as Microsoft writes it. The name of a `dcl_input_*_siv`/`_sgv` and `dcl_output_siv`/
  `_sgv` declaration is the low 16 bits of its token (`D3D10_SB_NAME_MASK`; the rest is reserved), and a name
  Microsoft's listing has no word for is written empty.
- Breaking, `dxbc-reader`: a shader message (`printf`, `errorf`) is read as Microsoft reads it.
  `Declared::ShaderMessage` gains `characters`, the character count the message states, and its `text` is the
  string up to its first zero byte, whatever the count. A message whose count is not less than the bytes after its
  operands is `Declared::CustomData { class: 4 }`, listed `undecipherable custom data` and numbered and counted as
  an instruction, as Microsoft does before it reads the operands. A string with no zero byte in the block is
  refused: Microsoft's listing then runs on into the bytes after the block, and differs from run to run. Fixture
  `message_strings` (an undecipherable message, a count of 0, a zero byte inside a string).
- Breaking, `dxbc-reader`: the binding declarations (`Declared::Sampler`, `Resource`, `ResourceRaw`,
  `ResourceStructured`, `UavTyped`, `UavRaw`, `UavStructured`) and `GroupSharedRaw` and `GroupSharedStructured` have
  their `operand`, and the new `Declared::operand()` gives the operand of every declaration that has one. In Shader
  Model 4 and 5.0 the listing writes a binding declaration's selection after its register (`t0.wyxx`, `s0.z`, `u4.x`),
  as Microsoft does; Shader Model 5.1's binding declarations have none; `dcl_tgsm_raw` and `dcl_tgsm_structured` write
  theirs in both. Fixtures `selections` (pixel and compute).
- `dxbc-reader`: an instruction's control bits are written as Microsoft writes them, on every instruction: `_sat`
  (bit 13) after the extended suffixes (`_aoffimmi`, `_indexable`) and before `_nz`/`_z`, the sync flags and the
  rest, `sync` included (`sync_sat_ugroup_g_t`); ` [precise(..)]` (bits 19 to 22) after it, `resinfo`, `sampleinfo`,
  `sync` and `label` included. `hs_control_point_phase`, `hs_fork_phase` and `hs_join_phase` take both, then a space;
  `hs_decls` neither. Fixtures `controls` (pixel, geometry and compute) and `controls_fork` and `controls_join` (hull).
- `dxbc-reader`: declaration fields Microsoft has no name for are written as it writes them: a resource or UAV
  dimension of 0 or 13 to 31 `<unknown dimension>` (in an extended resource-dimension token too); a sampler mode of 3
  to 15 nothing (no `, mode_…`); an interpolation mode of 0 `undefined` and of 8 to 15 `???`; the tessellator domain
  from bits 11 to 12 (`Declaration::tessellator_domain` reads those two alone), 0 `???`; a partitioning or output
  primitive of 0 or 5 to 7 `???` and the bare `dcl_tessellator_output_primitive`; an unnamed output topology or
  input primitive `???`. In the `controls` fixtures.
- `dxbc-reader`: of an instruction's extended tokens, Microsoft keeps the last of each kind and writes its group once
  for each token of that kind, offsets, then resource dimension, then return types, whatever their order; a kind with
  no token writes no group. Fixture `extended`.
- `dxbc-reader`: the `#line` with the file name before a function body's `label` is written for the `label`
  instruction with a function-body operand, whatever its text. Fixture `labels.ps50.zi` (the `/Zi` class program with
  its labels' control bits set).
- `dx`: the command is a library too (`dx::check`, `dx::files`, `dx::reflect`; not published), so its tests call
  what the command does in-process, and `dx disasm --check`'s comparison is `dx::check::compare`.
- Tests: `dx/tests/slim.rs` reads the slim shader set (`oracles.corpus.general/slim`, 8,287 programs that reach
  every region and branch side of the readers the full pool does): each program's listing against Microsoft's and
  its `dx reflect` and `dx info`, in seconds. It is the run before every push to main (CONTRIBUTING.md). The
  real-data tests take primase-testdata 0.2.2.
- `dxbc-reader`: more rules of the listing, each with a fixture:
  - the immediates of `ld_raw`, `ld_structured`, their `_feedback` forms, `resinfo`, `sample_pos` and
    `eval_sample_index` are integers (`l(4)`), as those of `ld` already were; `store_raw`, `store_structured` and
    `store_uav_typed` keep the hex-or-float style; fixture `load_integers`;
  - every register number and index is signed: `r-2`, `v-2`, `cb-2[-2]`, `cb0[r0.x + -1]`, `x-2[-2]`, `fb-2`, Shader
    Model 5.1's `T`, `S`, `U` and `CB` operands, Shader Model 5.0's declared `t`, `s`, `u` and `g`; and so are
    `dcl_temps`, `dcl_indexableTemp`'s register and size, `dcl_indexrange`'s count, the hull phases' instance counts
    and every field of a Shader Model 5.1 `dcl_constantbuffer`. A Shader Model 5.1 resource, sampler or UAV's id,
    range and space, strides, `dcl_maxout`, `dcl_thread_group`, `dcl_gsinstances`, `dcl_function_body` and
    `dcl_tgsm_*` sizes stay unsigned. Fixtures `indices` (Shader Model 5.0 and 5.1) and `indices_negated` (their
    numbers bit-inverted);
  - `dcl_interface` writes its id's low 16 bits; fixture `interface_id`;
  - `dcl_indexableTemp`'s component count is written clamped to 1 to 4; a return type of 0 or 10 to 15 is
    `<unknown resource return type>`, 8 `<continued>` and 9 `<unused>`; fixture `indices_names` (with an unknown
    siv and sgv name and two unknown signature system values);
  - an empty mask on a four-component operand is its dot alone (`r0.`, `dcl_output o0.`); fixture `empty_masks`;
  - the header's "shader requires additional functionality" notes take, besides the `SFI0` bits, those
    `dcl_globalFlags` states: double precision, forced early depth-stencil, minimum precision and the two 11.1
    extensions; fixtures `global_flags` (with `/Od` and Shader Model 5.1 `/all_resources_bound`) and
    `globalflags_all` (every flag set).
- Tests: every reader has property tests over generated inputs, and `fuzz/` has cargo-fuzz targets for the five
  (`fuzz/run.sh`, corpora outside the repository). `dxil-reader`'s Elden Ring corpus test tells programs by their
  extension and compares them on `primase_testdata::threads()` threads.

## 0.9.1 (2026-11-06)

- `dxbc-reader`: a double immediate that is a signaling NaN (the mantissa's highest bit clear) lists as Microsoft's
  disassembler lists it, `1.#SNAN0l` and `-1.#SNAN0l`; before, it was `1.#QNAN0l`. A float's spelling is unchanged.
  New fixture `double_specials` (infinities, signaling, quiet and default NaNs as double immediates) and its 23
  listings, found by comparing dx with `fxc /dumpbin` on a program written for it. No corpus program has a double NaN
  or infinity.

## 0.9.0 (2026-11-06)

- Breaking, `dxil-reader`: a `PSV0` part with the 24-byte runtime info validator 1.0 writes reads, and its program
  lists as dxc 1.9.2609 lists it; before, the part was refused ("a runtime info of 24 bytes") and with it the listing.
  Such a part ends with its resource records. `psv::RuntimeInfo::signature` (a `psv::StageSignature`) holds the
  stage, the view-id flag, the stage's u16, the element and vector counts, which were `RuntimeInfo`'s own fields and
  are `None` for 24 bytes; the listing then takes the stage from the program header. Six new fixtures
  (`validator10.*`, one per Shader Model 6.0 stage) and their dxc listings.
- `dxil-reader`: a buffer field whose type is a high-level matrix (`class.matrix.*`), which dxc 1.4 and 1.5 leave in a
  library's structured and constant buffer types (dxc 1.6 and later write lowered `hostlayout.*` types), lists as dxc
  1.9.2609 lists it (its matrix type, and a one-level matrix array without its length); before, the listing was
  refused ("a buffer field of an HLSL matrix type is not supported"). A matrix-annotated field of a struct that is not
  a matrix is still refused, naming the field and the struct. New fixture `matrix_lib15`, a `lib_6_3` library built by
  dxc 1.5.2010.
- Breaking, `dxil-reader`: a program built with debug information in its module (`-Zi -Qembed_debug`, or a debug
  module's `ILDB` part) reads and lists as dxc 1.9.2609 lists it; before, it was refused ("debug information is not
  supported"). The module keeps every LLVM 3.7 debug node as `Metadata::Debug` (`debug_info::DebugNode`: locations,
  types, scopes, variables, expressions and the rest, read as dxc's bitcode reader reads their records), each
  instruction's `debug_loc`, a body's own metadata (`Function::metadata`, from `Function::first_metadata`) and the
  metadata a call passes to a `metadata` parameter as a body value, `Value::Metadata` (new variants: matches on
  `Value` and `Metadata` need them). The listing prints the nodes, the `!dbg` locations (uniqued as `DILocation::get`
  does) and dxc's `; line:` and `; var:` comments. Ten new fixtures: `debug_info.*` (every stage and a library,
  optimized and `-Od`) and `debug_nodes`, assembled with dxcompiler's `IDxcAssembler` from IR holding the debug nodes
  no HLSL compiler writes (generic, lexical block file, module, Objective-C property, imported entity, and invalid
  expressions); 128 more programs built with dxc 1.4.1907, 1.5.2010, 1.6.2112 and 1.9.2609 (`-Zi -Qembed_debug`, with
  `-Od` and `-Zss`, six stages and two libraries) list as dxc 1.9.2609 lists them.
- `dxbc-reader`: six more rules of Microsoft's listings, found by the larger sweep below. Each has a fixture, which
  0.8.0 lists differently:
  - a buffer variable's default value is written before the line naming the registers it holds (`// Sampler: s0`);
    fixture `defaults_samplers`;
  - the initial locations end at the first whose path Microsoft's disassembler cannot find: that location, its
    `// <internal error> ...` line and an empty line, and none after it; fixture `zi_object_input` (textures in an
    input struct, which the debug information gives no size);
  - a multisampled texture's sample count is a signed number, so `Texture2DMS<float4, -1>` is `2dMS-1`; fixture
    `ms_sample_counts`;
  - a variable typed through a `typedef` of a `typedef` (modifiers before, between or after them) has no length for
    Microsoft: a location of one of more than one value is named by the variable alone with
    `// <internal error> unable to get type length from PDB`; one `typedef` is followed to its type; fixture
    `zi_typedefs`;
  - a struct offset no member holds is not named by the member before it: the location ends with Microsoft's
    `could not get find UDT child with correct offset in PDB`; fixture `zi_texture_buffer` (a `TextureBuffer` struct
    with an array member);
  - a UAV's location is named whole, as the instructions name it, by the variable alone where it holds it from its
    start: `U1 <- local` from Shader Model 5.1; fixture `zi_uav_local`.
- `dxbc-reader`: the sweep (`tests/inputs/fxc_sweep.py`) reads its corpora as their own runners do, and is larger:
  6,870 jobs, of which fxc builds 4,613 with `/Zi` and 4,614 with `/Zi /Od` (0.8.0's sweep had 4,304 of each), and
  `tests/corpora.rs` compares their 106,099 and 106,122 listings. The jobs fxc refuses (2,257 and 2,256) are code fxc
  has no form of: Vulkan-only tests, Shader Model 6 features, 16-bit types, HLSL 2021, tests written to fail, fxc's
  stricter rules and its own internal errors and crashes. What changed: a dxc test's `RUN` lines are joined where they
  end in `\`, `%S` names the test's folder and `-I` its include folders, and the last `/E` wins; a `-D NAME=` defines
  `NAME` empty; vkd3d's shader tests are cut as `tests/shader_runner.c` cuts them (lines starting with `%` and empty
  lines dropped, `[require]` resetting the model range and options, `[header] test-shader-models`, `fail` and
  `notimpl` qualifiers with their model arguments, an `options:` line matched in shader_runner's table order,
  backcompat dropped from 5.1 up); a Shader Model 6 job is tried at 5.0, then 5.1; job names differing only in case get
  `__2`, `__3`; and a build fxc refuses keeps fxc's messages and exit code (`fail/BUILD/NAME.txt`). The two oracle
  entries, `d3d-disassembler.general/fxc-sweep-zi` and `fxc-sweep-zod`, are now required inputs of a full run
  (`gate: true`): primase-testdata 0.1.16, which the workspace now needs, records their manifests.
- `dxbc-reader`: eight new fixture programs of the six sources above and their 184 listings (`tests/disasm`; 5,037
  listings of 219 programs, 114 of them `/Zi` builds).
- `dxbc-reader`: three more rules of Microsoft's listings, found over Wine's, vkd3d's and vkd3d-proton's tests. A
  `dcl_globalFlags` with no flags is `dcl_globalFlagsnone`. The four-component immediate of a load (`ld_structured`,
  `ld_raw`) has a space after each comma, where a move's and a store's have none. An XNA build's `XNAP` and `XNAS`
  parts are listed after the level 9 program as the `Aon9` part is (its tables, then its program), as "XNA Prepass
  shader bytecode" and "XNA shader bytecode", in that order whatever the container's; before, dx listed neither. Four
  patched fixtures (`examples/patched_fixtures.rs`) and their 92 listings, which the listing before this differs from.
- `dxil-reader`: a library's resources bound to no register, which dxc writes with lower bound and space -1, read and
  list as dxc 1.9.2609 lists them (`U0u4294967295,space4294967295`); before, the module was refused ("lower bound: -1 is
  out of range"). A resource's tags other than the element type and stride are not read, so the reorder-coherent tag
  4, whose value is `i1 true`, no longer refuses it. New fixtures `lib_unbound` (`lib_6_6`) and `lib_unbound.69`
  (`lib_6_9`, with a `reordercoherent` UAV array) and their dxc listings; both are refused by the reader before this.
- `dxil-reader`: a multisampled texture declared with a sample count of -1 (`Texture2DMS<float4, -1>`, as in dxc's
  `texture2dms.hlsl` test) reads, its sample count 4294967295 as dxc lists it (`2dMS4294967295`); before, the module was
  refused ("sample count: -1 is out of range"). New fixture `ms_unsized`, with counts of none, -1 (a `Texture2DMS` and a
  `Texture2DMSArray`) and 8, and its dxc listing; the reader before this refuses it.
- `d3d9-reader`: four differences from Microsoft's listings, found over Wine's and vkd3d's tests, and what the probes of
  them found. A constant table parameter's type is named as Microsoft's disassembler names it, which is the name of
  `D3D_SHADER_VARIABLE_TYPE` (`Texture2D`, `TextureCube`, `uint`, `PixelShader`, `UNKNOWN` for 26, 27, 40 to 51 and
  past 57; was `texture2D`, `textureCUBE`), and a class past struct has no type name. A struct in the Parameters list
  has a blank line between it and the item before or after it, none before the first or after the last. A pixel
  program's `dcl` of usage 0 and index 0 has no usage (`dcl v0`), on any register; any other usage is named, `t`
  registers' and pixel 2.x's included. An instruction, register type or operand flag of another version is read and
  listed, as Microsoft's disassembler lists it: an opcode outside its version's list (`defb` in `ps_2_0`, `cnd` in
  `vs_1_1`, `texld` in `vs_3_0`, named `texld` and `texcrd` from 2.0 in either stage), a register type (`i0` in
  `vs_1_1`, `s0` in `ps_1_4`, `o0` in `ps_3_0`, a pixel program's relative index `t0.x`), co-issue outside pixel 1.x,
  predication in 1.x and 2.0, a result shift outside pixel 1.x, and relative addressing in Shader Model 1; before, each
  was refused. Their slots are Microsoft's: texture-addressing instructions take a texture slot in every version, a
  pixel 1.x instruction at most one arithmetic slot, `bem` and `dp2add` two elsewhere, and a co-issued first
  instruction its own; a definition or declaration inside flow control is indented. Malformed streams are still refused
  at the word that breaks them, where Microsoft's disassembler lists them as garbage: an unknown opcode (`???`), a
  version that is none of 1.0 to 3.0 (`ps_2_254`), a reserved bit, an unknown register type, usage or result shift, a
  register past its bank (`a1`); `tests/stream.rs` pins four such streams. New fixtures (`tests/disasm`): four fxc
  builds of `ctab.hlsl` and one with its constant table's types and classes changed, and for each of the 11 versions
  one program with every instruction and one with every register type, `dcl` usage and flag, with their 621 listings
  (1,656 listings of 72 programs); the reader before this lists one of the 27 as Microsoft does, differs on four and
  refuses 22.

## 0.8.0 (2026-11-06)

- `dxbc-reader`: `/Zi` listings name and order the variables' locations as Microsoft's disassembler does, so the
  sweep of 0.7.0 (4,304 programs, each built with `/Zi` and with `/Zi /Od`) is Microsoft's under every one of the 23
  flag words: 8,608 of 8,608 listings, none differing or refused. What changed:
  - a variable of one value (a scalar, a one-component vector, a one-element array, a one-member struct, nested) is
    named by its own name, and a vector's component always has its lane, a one-component vector's too (`.x`); an
    interface pointer is four values;
  - a struct's member is the first whose bytes hold the offset;
  - an indexable temp or `m#` register is numbered by its first index, and named by the variable alone where it holds
    the variable from its start;
  - a minimum-precision scalar inside a struct is written as Microsoft's `<unknown HLSL built-in N offset M>`;
  - where Microsoft's disassembler cannot name the byte (a static member before the member, an offset past its type,
    an offset inside a vector's component where fxc's structured-buffer layout differs from the PDB's), the
    location ends with its `// <internal error> ...` line and the instruction's later locations are left out;
  - the locations after a `call` are `Post-call locations`, a `#line` before a label has the file only before a
    function body's (`label fb...`), and the initial locations put an inlined call's variables before its caller's,
    where an instruction's locations put a scope's own first.
- `dxbc-reader`: two new fixture programs, `zi_names` built with `/Zi` and with `/Zi /Od`, and their 46 listings
  (`tests/disasm`; 4,853 listings of 211 programs, 108 of them `/Zi` builds), which fail before the change under the
  16 flag words that write the names; a build with the initial locations in an instruction's order fails
  `classes_hull` and `tess_stages.line`.
- `dxbc-reader`: the sweep is a real-data test: `tests/corpora.rs` compares the oracle entries
  `d3d-disassembler.general/fxc-sweep-zi` and `fxc-sweep-zod` (each 4,304 programs, 98,992 listings) with
  Microsoft's under all 23 flag words; with the initial locations in an instruction's order, 768 of the `/Zi` build's
  listings and 16 of the `/Zi /Od` build's differ. They are not yet required inputs of a full run (`gate: false`) until the
  primase-testdata release that records their manifests.
- `rsx-reader`: a parameter's default value reads for every numeric `CGtype` (half, float, fixed, int and bool scalars,
  vectors and matrices, 105 types), one stored word per component; before, only float types read and the others were
  refused. `cgbinary::components` gives a type's component count from Cg's `cg_datatypes.h`; a default on a sampler,
  string, program, texture or unknown type is refused as not numeric. All 8,041,219 parameters of SHRED's 380,868
  programs read, as before.

## 0.7.0 (2026-11-06)

- `dxbc-reader`: listings are Microsoft's where a sweep of outside programs found them refused or different outside
  the `/Zi` variable names. The sweep is fxc 10.0.26100.4654's builds of the HLSL in dxc's tests, vkd3d's and
  vkd3d-proton's shader tests and MiniEngine: 4,304 programs, each built with `/Zi` and with `/Zi /Od`, listed under
  the 23 flag words. None is refused now, and under every flag word that leaves out the variable names (those with
  0x10) all 8,608 listings are Microsoft's; the names are the next release's (95 `/Zi` and 189 `/Zi /Od` listings
  still differ under the others). What changed:
  - the residency-status forms (`sample_l_s`, `ld_s`, `gather4_c_s`, ...) write their operands in the number styles of
    the plain forms, and a gather with programmable offsets (`gather4_po`, `gather4_po_c` and their `_s` forms) writes
    every operand as an integer, its address and reference value too;
  - the word fxc leaves after the operands of `sample_d_cl_s` (0x2000) is skipped, as after `samplepos` and
    `sample_cl_s`, where the program was refused;
  - no `{x as y}` precision is written on an instruction with a resource operand;
  - shader messages (`customdata` class 4) are read: `printf` and `errorf` with their text, escaped as Microsoft does
    (`\b \t \n \r \\`, other bytes outside 0x20 to 0x7f as `.`), and their operands, other ids and formats as
    `<unknown>`, numbered and indented as instructions. `Declared::ShaderMessage` is new, and `Declared` is
    `#[non_exhaustive]`;
  - the note `SHADER WILL ONLY WORK WITH THE DEBUG SDK LAYER ENABLED` is written where the container's digest is not
    the one `dxcontainer::checksum` computes: fxc stores another for a program with `printf`, `errorf` or `abort`;
  - a subroutine's label is `label0` (it was `l0`), a geometry program's patch input `patch2` (it was
    `2_control_point_patch`);
  - the reflection header writes an empty struct with no inner line, a blank line before a struct member and before
    the member after an empty struct, default values four words to a line, and an output's Used column as the
    complement of its never-written mask (all four lanes for an `SV_ClipDistance` of three);
  - with hex literals (0x80) a 64-bit immediate is written as its four words; a one-component 64-bit immediate is read
    as one word, as Microsoft's disassembler reads it;
  - a `/Zi` listing with no initial locations has a blank line before its first `#line`;
  - `/Zi` programs whose types fxc records as classes, typedefs, base classes and interfaces, static members, methods
    or forward references are read, where they were refused.
- `dxbc-reader`: 13 new fixture programs and their 299 listings (`tests/disasm`; 4,807 listings of 209 programs, 106
  of them `/Zi` builds), each failing before its change: `ps_feedback`, `min16_resources`, `messages`,
  `header_layout`, `ps_calls`, `gs_patch`, `ps_doubles`, `zi_compute`, `zi_types`, and in `tests/fixtures` two builds
  edited into programs fxc does not write (`<unknown>` messages and a repaired digest, a one-word 64-bit immediate),
  which `examples/patched_fixtures.rs` makes. `tests/inputs/fxc_sweep.py` makes the sweep's programs and listings.
- `dxil-reader`: three fixtures of texture buffers beside a constant buffer (`tbuffers`, `ps_6_0`, `/Od` and `ps_6_6`):
  a `tbuffer` block and `TextureBuffer<T>` views, one in a register space and one an array, in the Buffer Definitions
  and Resource Bindings tables.

## 0.6.0 (2026-11-06)

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
