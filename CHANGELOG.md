# Changelog

## 0.1.1 (2026-10-27)

- Depends on `primase-foundations` 0.2 (its Oodle decoder changed; these crates do not use it), so a build has one
  copy of it. `dxil-reader` and `rsx-reader` are first published at 0.1.1.

## 0.1.0 (2026-10-27)

- First release of four crates:
  - `dxcontainer`: the DXBC container that holds Direct3D shader bytecode (Shader Model 4 to 6): its part directory and digest.
  - `dxbc-reader`: Shader Model 4 and 5 bytecode as typed declarations and instructions, with RDEF reflection and signatures.
  - `dxil-reader`: Shader Model 6 programs (LLVM bitcode) as modules, with resource, signature and RDAT reflection records.
  - `rsx-reader`: PlayStation 3 RSX texture descriptors, Cg binary program containers and fragment program microcode.
