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
| `oracles.corpus` | a game's own files, copied out of its install unchanged | the user's own install |
| `oracles.dxc` | what Microsoft's DXC writes of a game's DXIL programs | independent: Microsoft's DXC (Linux release) run over the programs of the user's own install |

#### Declared files

| key | status | gate | about | source |
| --- | --- | --- | --- | --- |
| `oracles.corpus.elden/shaders` | live | yes | Elden Ring's 50,283 DXIL programs (`.ppo`, `.vpo` and the other stages, nested by shader bundle), as the game stores them; tests/corpora.rs | the user's own Elden Ring install; programs stay outside the repository |
| `oracles.dxc.elden/shader-listings` | live | yes | dxc 1.9.2609's `-dumpbin` listing of each of Elden Ring's 50,283 programs (`<path>.txt`, mirroring `oracles.corpus.elden/shaders`); tests/corpora.rs | independent: Microsoft's DXC 1.9.2609 Linux release (primase-oracles tools/dxc/dumpbin_tree.py) over the programs of the user's own Elden Ring install; programs and listings stay outside the repository |

<!-- end of real-data inputs -->
