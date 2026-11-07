#!/usr/bin/env bash
# run.sh [SECONDS] [TARGET...]: run the fuzz targets at once, each for SECONDS (default 60), so the wall-clock time is
# SECONDS whatever their number. Exits 1 when a target found something.
#
# The corpora are $DX_FUZZ_CORPUS (default ./corpus): a directory with one folder per target, or a .tar of one. A .tar
# is read once into a local folder and written back once at the end, so a corpus on a network share costs two file
# operations, not one per input. After the run each target's corpus is merged down to the inputs that add coverage.
# What crashes, hangs or runs out of memory is written to artifacts/<target> beside the corpus. A first run seeds the
# corpora with the committed programs (seed.sh).
set -u -o pipefail
here=$(cd "$(dirname "$0")" && pwd)
seconds=${1:-60}
shift || true
targets=("$@")
[ ${#targets[@]} -eq 0 ] && targets=(container dxbc d3d9 dxil rsx)
store=${DX_FUZZ_CORPUS:-$here/corpus}
artifacts=$(dirname "$store")/artifacts
cd "$here"
# on Windows the targets are built with MSVC's address sanitizer, the one libFuzzer links with there, and load its
# runtime from the Visual Studio that vswhere finds
case $(uname -s) in
MINGW* | MSYS* | CYGWIN*)
    vswhere="C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe"
    asan=$("$vswhere" -latest -products '*' -find 'VC/Tools/MSVC/**/bin/Hostx64/x64/clang_rt.asan_dynamic-x86_64.dll' | head -1 | tr -d '\r')
    [ -n "$asan" ] || { echo "no clang_rt.asan_dynamic-x86_64.dll: install the MSVC address sanitizer" >&2; exit 2; }
    PATH="$(cygpath -u "$(dirname "$asan")"):$PATH"
    ;;
esac
cargo fuzz build -O || exit 2
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
case $store in
*.tar)
    corpus=$work/corpus
    mkdir -p "$corpus"
    if [ -f "$store" ]; then
        tar --force-local -xf "$store" -C "$corpus" || exit 2
    else
        bash "$here/seed.sh" "$corpus"
    fi
    ;;
*)
    corpus=$store
    [ -d "$corpus" ] || bash "$here/seed.sh" "$corpus"
    ;;
esac
start=$(date +%s)
for t in "${targets[@]}"; do
    mkdir -p "$corpus/$t" "$artifacts/$t"
    # one process per target; 10 s on one input is a hang, 2 GB a runaway allocation
    cargo fuzz run -O "$t" "$corpus/$t" -- -max_total_time="$seconds" -timeout=10 -rss_limit_mb=2048 \
        -artifact_prefix="$artifacts/$t/" -print_final_stats=1 >"$work/$t.log" 2>&1 &
done
wait
fuzzed=$(date +%s)
# keep the inputs that add coverage
for t in "${targets[@]}"; do
    mkdir -p "$work/merged/$t"
    cargo fuzz run -O "$t" "$work/merged/$t" "$corpus/$t" -- -merge=1 -timeout=10 -rss_limit_mb=2048 \
        -artifact_prefix="$work/merge-artifacts-$t-" >"$work/$t.merge.log" 2>&1 &
done
wait
for t in "${targets[@]}"; do
    if grep -q 'MERGE-OUTER: [0-9]* new files' "$work/$t.merge.log"; then
        rm -rf "${corpus:?}/$t" && mv "$work/merged/$t" "$corpus/$t"
    else
        echo "$t: the merge failed, its corpus is kept as it grew; $(tail -1 "$work/$t.merge.log")"
    fi
done
case $store in
*.tar) tar --force-local -cf "$store.new" -C "$corpus" . && mv -f "$store.new" "$store" || exit 2 ;;
esac
found=0
for t in "${targets[@]}"; do
    runs=$(grep -m1 -o 'stat::number_of_executed_units: *[0-9]*' "$work/$t.log" | grep -o '[0-9]*$')
    inputs=$(find "$corpus/$t" -type f | wc -l)
    crashes=$(find "$artifacts/$t" -type f | wc -l)
    echo "$t: ${runs:-?} runs, corpus $inputs, artifacts $crashes"
    if [ "$crashes" -gt 0 ] || ! grep -q 'Done [0-9]* runs' "$work/$t.log"; then
        found=1
        grep -E 'panicked|ERROR|SUMMARY|deadly signal|timeout|out-of-memory' "$work/$t.log" | head -5
        cp "$work/$t.log" "$artifacts/$t.run-$start.log"
    fi
done
echo "fuzzed $((fuzzed - start)) s, merged and stored $(($(date +%s) - fuzzed)) s; corpora $store"
exit $found
