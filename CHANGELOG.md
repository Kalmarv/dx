# Changelog

## Unreleased

- `dxbc-reader`: every instruction opcode has an operand format, `operand_format(opcode)`: how many destination operands
  and how many source operands the token format gives it, and what each carries (`OperandClass`: float, double, integer,
  a register with no data of its own such as a resource, sampler, view or stream, or data whose type the sources disagree
  on or the resource sets). `Instruction::format` and `Instruction::destinations_and_sources` read it, and `decode`
  refuses an instruction whose operand count is not its opcode's, naming the instruction's word (a change: such a
  program was returned before, and the caller refused it). The table is the one vkd3d's `tpf.c` and DXVK's
  `dxbc_defs.cpp` both publish; their operand counts agree for every opcode both list, and every one of the 7,729
  Shader Model 4 and 5 programs of Sekiro, Riders Republic and Sledding Game decodes under it (the class of each slot
  agrees with the register it holds).
- `dxcontainer`: `serialize` writes parts as a container (header, directory, the parts in order, exactly as given, the
  digest `checksum` computes), `repair_digest` rewrites the digest of a container edited in place, `replace_part` replaces
  or appends one part. `serialize(&chunks(bytes)?)` is `bytes` again for every container that stores the digest
  `checksum` computes: all 77,457 stock containers of the five games.
- `rsx-reader`: `vertex::decode` reads RSX vertex program microcode (128-bit slots, a vector and a scalar operation per
  slot) into typed instructions, with `Program::input_mask`, `output_mask` and `register_count` that equal a program
  header's fields in all 170 distinct vertex programs of Tony Hawk's SHRED.

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
