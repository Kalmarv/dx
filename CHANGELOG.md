# Changelog

## Unreleased

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
