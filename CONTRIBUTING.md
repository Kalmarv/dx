# Contributing

## Build and test

The workspace pins its toolchain in `rust-toolchain.toml` (Rust 1.99), so `rustup` installs it on first use.

```sh
cargo build --workspace
cargo test --workspace
cargo fmt --all --check
cargo clippy --workspace --all-targets --locked -- -D warnings
RUSTDOCFLAGS="-D warnings" cargo doc --workspace --no-deps
```

CI runs the format, clippy and test commands on Linux and Windows. The tests use the fixtures committed under each crate's
`tests/fixtures` and byte streams laid out by hand; they need no game files.

The library crates read byte slices and nothing else: no file, environment or process access (clippy denies it, see
`clippy.toml`), no `unsafe`, and no panics on malformed input. Errors name the position and what was expected there. A new
refusal or record needs a test with hand-built bytes; a new format feature needs a fixture or a hand-laid example, with the
source it was compiled from (the HLSL beside the shader fixtures).

## Releasing

1. Raise the version in the workspace and in the crates' dependencies on each other (a patch, 0.x.Y, for fixes and data
   or manifest additions; a minor, 0.X.0, for new API or any breaking change before 1.0; then `cargo check`, so
   `Cargo.lock` follows) and put the change's CHANGELOG lines under a `## <version> (<date>)` heading, in one commit.
2. Push it to main. Once every check has passed, release-plz publishes each crate whose version crates.io does not have
   yet (trusted publishing: no token is stored anywhere), tags the commit `v<version>` and creates the GitHub Release
   with that CHANGELOG section as its notes. Then dist (`.github/workflows/release.yml`) builds the binaries and
   attaches them to the Release, with their checksums.

A commit that raises no version only runs CI. Never release by hand. If a run fails after the tag was made, start
`release.yml` by hand with that tag.

A new crate's first version can't come from trusted publishing: the token holder publishes it by hand, then adds its
trusted-publishing config (workflow `ci.yml`).

## Reporting a file the readers cannot read

Open an issue with the "Unreadable file" template. Include:

- the crate and function you called and the **exact error message** (it names the byte, word or bit and what was expected);
- the compiler or tool that produced the file and its version, and the target (for example `ps_5_0`, `lib_6_6`, `fp40`);
- a **minimal shader or program that reproduces it**, as source (HLSL or Cg) with the command line that compiled it. A
  compiled file of a few hundred bytes that you wrote yourself is welcome as well.

Do not attach files extracted from games or other copyrighted software, or links to them: shaders, textures and containers
from shipped titles are not ours to redistribute. If the failure only happens on such a file, say which game and platform
it comes from, give the error and the position it reports, and describe the bytes around that position in words; we will
ask for more if we need it.

## Changes

Keep a change to one concern, with the test that fails without it. Commit messages say what changed and why.
By contributing you agree your work is licensed GPL-3.0-or-later, like the rest of the repository.
