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
| `oracles.d3d-disassembler.general/fxc-sweep-zi` | live | - | the /Zi sweep's 4,613 programs (`NAME.dxbc`): fxc 10.0.26100.4654 `/Zi` builds of the HLSL in dxc's tests, vkd3d's and vkd3d-proton's shader tests and MiniEngine, each with Microsoft's listing under no flags (`NAME.dxbc.asm`) and 22 other flag words (`NAME.dxbc.flagNN.asm`); tests/corpora.rs | independent: fxc and d3dcompiler_47.dll 10.0.26100.4654 D3DDisassemble (tests/inputs/fxc_sweep.py) over outside open-source HLSL, the commits in the set's MANIFEST.toml; programs and listings stay outside the repository |
| `oracles.d3d-disassembler.general/fxc-sweep-zod` | live | - | the /Zi sweep's 4,614 programs built with `/Zi /Od` (`NAME.dxbc`), as `fxc-sweep-zi` otherwise: each with Microsoft's listing under no flags and 22 other flag words; tests/corpora.rs | independent: fxc and d3dcompiler_47.dll 10.0.26100.4654 D3DDisassemble (tests/inputs/fxc_sweep.py) over outside open-source HLSL, the commits in the set's MANIFEST.toml; programs and listings stay outside the repository |

<!-- end of real-data inputs -->

`fxc_sweep.py` makes the `/Zi` sweep's programs and listings: it compiles the HLSL of four outside corpora
(DirectXShaderCompiler's tests, vkd3d's and vkd3d-proton's shader tests, MiniEngine) with fxc `/Zi` and `/Zi /Od`, and
lists each program with Microsoft's D3DDisassemble under the 23 flag words the fixtures use (`python -I fxc_sweep.py
CORPUS OUT FXC_DIR`; its docstring names the corpus layout). Its two builds are the oracle entries
`general/fxc-sweep-zi` and `general/fxc-sweep-zod`, which tests/corpora.rs compares under every flag word.
