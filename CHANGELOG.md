# Changelog

## 0.1.0 (2026-10-27)

- First release of four crates:
  - `dxcontainer`: the DXBC container that holds Direct3D shader bytecode (Shader Model 4 to 6): its part directory and digest.
  - `dxbc-reader`: Shader Model 4 and 5 bytecode as typed declarations and instructions, with RDEF reflection and signatures.
  - `dxil-reader`: Shader Model 6 programs (LLVM bitcode) as modules, with resource, signature and RDAT reflection records.
  - `rsx-reader`: PlayStation 3 RSX texture descriptors, Cg binary program containers and fragment program microcode.
