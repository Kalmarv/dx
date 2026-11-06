# t7_dxbc test programs

The 19 test programs of [t7_dxbc](https://github.com/McReaper/t7_dxbc) (a DXBC disassembler and decompiler in Go,
MIT licence, `LICENSE` here), copied from its `testdata/` at commit 7b8fa07: each program's HLSL, the container fxc
compiled from it, and `D3DDisassemble`'s listing of that container with no flags, as t7_dxbc's
`internal/genfixtures` wrote them. `../../disasm.rs` compares this crate's listing of each with that one. They are
programs written by others than this crate's fixtures, so they check the listing against HLSL it was not tuned on.
