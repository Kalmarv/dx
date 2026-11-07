"""Re-list every kept finding of a run (findings/<kind>/<stem>.dxbc) with the current dxlist, under each flags word
Microsoft's listing was kept for, and print the ones that still differ with their first difference."""
import collections
import glob
import os
import shutil
import subprocess
import sys

import differ

run = sys.argv[1]
work = os.path.join(run, "recheck")
shutil.rmtree(work, ignore_errors=True)
os.makedirs(work)
origin = {}
for p in glob.glob(os.path.join(run, "findings", "*", "*.dxbc")):
    stem = os.path.basename(p)[:-5]
    shutil.copy(p, work)
    origin[stem] = os.path.dirname(p)
flags = sorted({os.path.basename(p).split(".")[-2] for p in glob.glob(os.path.join(run, "findings", "*", "*.ms.*.txt"))})
subprocess.run([differ.DXLIST, work, *flags], check=True, capture_output=True)
still = collections.Counter()
for stem, folder in sorted(origin.items()):
    first = None
    for f in flags:
        ms = os.path.join(folder, f"{stem}.ms.{f}.txt")
        if not os.path.exists(ms):
            continue
        theirs = open(ms, encoding="utf-8", errors="replace").read().replace("\r", "").split("\n")
        dx = os.path.join(work, f"{stem}.dx.{f}.txt")
        if not os.path.exists(dx):
            err = os.path.join(work, f"{stem}.dx.{f}.err")
            first = (f, "(a listing)", "refused: " + (open(err).read().strip()[:120] if os.path.exists(err) else "no output"))
            break
        ours = open(dx, encoding="utf-8", errors="replace").read().replace("\r", "").split("\n")
        if ours != theirs:
            n = next((i for i, (a, b) in enumerate(zip(theirs, ours)) if a != b), min(len(ours), len(theirs)))
            first = (f, theirs[n] if n < len(theirs) else "(end)", ours[n] if n < len(ours) else "(end)")
            break
    if first:
        still[os.path.basename(folder)] += 1
        print(f"{os.path.basename(folder)}/{stem} flags {first[0]}: ms {first[1]!r} dx {first[2]!r}")
print("still differing:", sum(still.values()), "of", len(origin), dict(still))
