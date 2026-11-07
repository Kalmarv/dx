# Fuzz targets

[cargo-fuzz](https://github.com/rust-fuzz/cargo-fuzz) targets for the readers. They are libFuzzer with a nightly
toolchain, which `rust-toolchain.toml` here selects. This folder is its own workspace, so the stable checks and CI
don't build it.

| target | reads | checks |
|---|---|---|
| `container` | `dxcontainer`: the part directory, the digest, the feature flags | no panic or hang; bytes it accepts are what `serialize` writes for what it read, digest aside |
| `dxbc` | `dxbc-reader`: the listing under the flags word the first byte picks, the reflection, signatures, statistics, interfaces, feature level 9 part, the decoded token stream and its texture reads | no panic or hang |
| `d3d9` | `d3d9-reader`: `read`, `frame`, the listing under the flags word the first byte picks | no panic or hang |
| `dxil` | `dxil-reader`: the listing, the module and its reflection, texture reads, `PSV0`, `RDAT`, the bitstream alone | no panic or hang |
| `rsx` | `rsx-reader`: a Cg binary container, fragment and vertex microcode | no panic or hang |

A hang is 10 s on one input. A runaway allocation is over 2 GB.

```sh
cargo install cargo-fuzz
bash fuzz/run.sh 60                 # every target at once for 60 s: before a push
bash fuzz/run.sh 1500               # 25 min, the weekly run
bash fuzz/run.sh 300 dxbc dxil      # some targets
```

- `run.sh` runs the targets at the same time, so the wall-clock time is the seconds given, whatever the number of
  targets. Its exit code is 1 when a target found something.
- `$DX_FUZZ_CORPUS` holds the corpora, one folder per target (default `fuzz/corpus`, ignored by git). It can be a
  `.tar`, which `run.sh` reads into a local folder and writes back at the end: the shared corpora are
  `X:/modding-archive/scratch/dx-fuzz/corpus.tar` from the desktop, on the NAS and not in the repository. After a run
  each corpus is merged down to the inputs that add coverage. A first run seeds the corpora from the programs
  committed in the readers' tests and the two Cg binary containers in `seeds/rsx` (`seed.sh`).
- What a target finds is written to `artifacts/<target>` beside the corpus, with the target's log beside it.
- On Windows the targets are built with MSVC's address sanitizer, as libFuzzer needs there; `run.sh` puts its runtime
  (`clang_rt.asan_dynamic-x86_64.dll`, from the Visual Studio C++ tools) on `PATH`.
- A crash, hang or runaway allocation becomes a regression fixture. The input goes under the reader's `tests/fuzz/`,
  with a test that reads it as the target does, next to the fix.
