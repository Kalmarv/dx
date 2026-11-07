#!/usr/bin/env bash
# seed.sh CORPUS: start the corpora with the programs committed in the readers' tests. The dxbc and d3d9 targets take
# a first byte choosing the flags word, here 0 (no flags).
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(dirname "$here")
corpus=$1
mkdir -p "$corpus"/{container,dxbc,d3d9,dxil,rsx}
for f in "$root"/dxbc-reader/tests/{disasm,fixtures}/*.dxbc "$root"/dxil-reader/tests/fixtures/*.dxil; do
    cp "$f" "$corpus/container/"
done
for f in "$root"/dxbc-reader/tests/{disasm,fixtures}/*.dxbc; do
    { printf '\0'; cat "$f"; } >"$corpus/dxbc/$(basename "$f")"
done
for f in "$root"/d3d9-reader/tests/{disasm,assembled}/*.bin; do
    { printf '\0'; cat "$f"; } >"$corpus/d3d9/$(basename "$f")"
done
cp "$root"/dxil-reader/tests/fixtures/*.dxil "$corpus/dxil/"
# the Cg binary containers of rsx-reader/tests/cgbinary.rs, a fragment and a vertex program
cp "$here"/seeds/rsx/*.cgb "$corpus/rsx/"
echo "seeded: $(find "$corpus" -type f | wc -l) inputs in $corpus"
