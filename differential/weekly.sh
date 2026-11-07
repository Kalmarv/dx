#!/usr/bin/env bash
# weekly.sh [CASES]: the differential's weekly run (README.md), on Windows with Microsoft's d3dcompiler_47.dll: one
# batch of CASES (default 1500) edited programs for each kind of edit, seeded by the date, then report.py. The batches
# are made in a temporary folder; what is kept (the report, summary.jsonl, the findings to fix and the programs that
# crashed or hung Microsoft's disassembler) is copied to $DX_DIFF_STORE/<date> (default differential/runs), and the
# report to $DX_DIFF_STORE/latest.md as well. Exits 1 when a batch found something to fix, 2 when the run failed.
set -u -o pipefail
here=$(cd "$(dirname "$0")" && pwd)
cases=${1:-1500}
store=${DX_DIFF_STORE:-$here/runs}
python=${PYTHON:-python}
day=$(date -u +%Y-%m-%d)
seed=$(date -u +%Y%m%d)
started=$(date +%s)
(cd "$here/.." && cargo build -q --release --locked -p dxlist --target-dir "$here/target") || exit 2
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
# Windows Python reads Windows paths
out=$(cygpath -m "$work")
for edits in swizzle control immediate byte special; do
    "$python" -I "$here/differ.py" edit --kinds "$edits" --cases "$cases" --seed "$seed" --out "$out" >/dev/null || exit 2
done
"$python" -I "$here/report.py" "$out" >"$work/report.md"
status=$?
[ "$status" -le 1 ] || exit 2
echo "" >>"$work/report.md"
echo "$(date -u +%Y-%m-%dT%H:%MZ), $(( $(date +%s) - started )) s, dx $(git -C "$here" rev-parse --short HEAD)" >>"$work/report.md"
kept="$store/$day"
mkdir -p "$kept/findings" || exit 2
cp "$work/report.md" "$work/summary.jsonl" "$kept/" || exit 2
for folder in "$work"/findings/*/ "$work"/microsoft-crashes/ "$work"/microsoft-hangs/; do
    [ -d "$folder" ] || continue
    name=$(basename "$folder")
    case $name in refused_*) continue ;; esac
    case $folder in */findings/*) cp -r "$folder" "$kept/findings/" ;; *) cp -r "$folder" "$kept/" ;; esac || exit 2
done
cp "$work/report.md" "$store/latest.md" || exit 2
cat "$work/report.md"
exit "$status"
