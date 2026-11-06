# Real-data inputs

What this crate's real-data tests (`tests/corpora.rs`) read, as tests/inputs/mod.rs declares them: the keys of the
configuration file `GAME_DATA` names (its layout is described by
[primase-testdata](https://github.com/Kalmarv/primase-testdata)), the oracle sets and the files of each. A test whose
input is not configured skips with a line naming its key.

<!-- real-data inputs: made by primase_testdata::doc::tables from tests/inputs/mod.rs -->

#### Configuration keys

| key | gate | about | source |
| --- | --- | --- | --- |
| `scratch.root` | - | where real-data tests write their outputs (the OS temporary folder when unset) | - |

#### Oracle sets (`<oracles.root>/<set>/<game>/`)

| set | about | source |
| --- | --- | --- |
| `oracles.d3d-disassembler` | Microsoft's D3D shader disassembly of a game's shader programs: each program with its listing beside it | independent: Microsoft d3dcompiler_47.dll D3DDisassemble, run over the user's own install |

#### Declared files

| key | status | gate | about | source |
| --- | --- | --- | --- | --- |
| `oracles.d3d-disassembler.general/sm3` | live | yes | a raw ps_3_0 program (`pixel.bin`) and two vs_3_0 ones (`vertex.bin`, `vertex-layered.bin`), each with Microsoft's listing with no flags (`.asm`); tests/corpora.rs | independent: Microsoft d3dcompiler_47.dll D3DDisassemble on shipped Shaun White Skateboarding SDB2 programs; programs and listings stay outside the repository |
| `oracles.d3d-disassembler.shaun-white/sdb2` | live | yes | every distinct vertex (`.vs`) and pixel (`.ps`) program of Shaun White Skateboarding's three SDB2 bundles, 7,306 in all, each with Microsoft's listing with no flags (`.vs.asm`, `.ps.asm`); tests/corpora.rs | independent: Microsoft d3dcompiler_47.dll D3DDisassemble over the programs of the user's own Shaun White Skateboarding install; programs and listings stay outside the repository |

<!-- end of real-data inputs -->
