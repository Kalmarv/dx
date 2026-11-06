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
| `oracles.d3d-disassembler.riders/shader-pack` | live | yes | the 2,443 Shader Model 5 programs of Riders Republic's shader pack (`NNNN.dxbc`), each with Microsoft's listing with no flags (`NNNN.txt`); tests/corpora.rs | independent: Microsoft's D3D Shader Disassembler over the programs of the user's own Riders Republic install; programs and listings stay outside the repository |
| `oracles.d3d-disassembler.sekiro/programs` | live | yes | Sekiro's 432 Shader Model 5 programs (`NAME.ppo`, `NAME.vpo`), each with Microsoft's listing under no flags (`NAME.ppo.asm`) and 22 other flag words (`NAME.ppo.flagNN.asm`); tests/corpora.rs | independent: d3dcompiler_47.dll 10.0.26100.4654 D3DDisassemble (primase-oracles tools/wine/d3d_disassemble.py) over the programs of the user's own Sekiro install; programs and listings stay outside the repository |
| `oracles.d3d-disassembler.sledding/corpus-unity` | live | yes | the 4,854 Shader Model 4.0 and 5.0 programs of Sledding Game's Unity player (`NNNNN.dxbc`), each with Microsoft's listing with no flags (`NNNNN.dxbc.asm`); 16 carry an SPDB part; tests/corpora.rs | independent: d3dcompiler_47.dll 10.0.26100.4654 D3DDisassemble (primase-oracles tools/wine/d3d_disassemble.py) over the programs of the user's own Sledding Game install; programs and listings stay outside the repository |

<!-- end of real-data inputs -->
