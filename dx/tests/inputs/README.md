# Real-data inputs

What this crate's real-data test (`tests/slim.rs`) reads, as tests/inputs/mod.rs declares it: the keys of the
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
| `oracles.corpus` | shader programs gathered from outside sources, each with the listing Microsoft's tools write of it | independent: open-source shader tests and the user's own installs; Microsoft's d3dcompiler_47.dll and dxc |

#### Declared files

| key | status | gate | about | source |
| --- | --- | --- | --- | --- |
| `oracles.corpus.general/slim` | live | yes | the slim shader set: 8,287 programs (`programs/<family>/<sha256>.<family>`: 557 `d3d9`, 3,671 `dxbc`, 4,059 `dxil`) that reach every region and branch side of the readers the full pool of 108,000 does, each with Microsoft's listing beside it (`.d3d9.asm` and `.dxbc.asm` D3DDisassemble 10.0.26100.4654 with no flags, `.dxil.txt` dxc 1.9.2609 `-dumpbin`) but the 10 programs `microsoft-refused.tsv` names; tests/slim.rs | independent: programs of open-source shader tests and of the user's own installs, listed by Microsoft's d3dcompiler_47.dll and dxc; programs and listings stay outside the repository |

<!-- end of real-data inputs -->
