"""report.py DIR: the report of a run's batches (DIR/summary.jsonl, DIR/findings/), as Markdown on stdout. Exits 1 when
a batch found something to fix: a listing that differs, a panic, or a program dx lists where Microsoft's disassembler
refuses it; 0 when every difference is dx refusing a program as malformed where Microsoft's disassembler lists it
anyway, a refusal dx keeps (README.md). Windows Python, run with -I."""
import collections
import json
import os
import sys


def held(kind):
    """Whether a finding's kind is dx refusing a malformed program, which dx keeps."""
    return kind.startswith("refused_")


def main():
    out = sys.argv[1]
    batches = [json.loads(line) for line in open(os.path.join(out, "summary.jsonl"), encoding="utf-8")]
    new, refusals = collections.Counter(), collections.Counter()
    for b in batches:
        for kind, n in b["kinds"].items():
            (refusals if held(kind) else new)[kind] += n
    lines = ["# dx differential against D3DDisassemble", ""]
    lines += ["| batch | seed | programs | differing | D3DDisassemble crashed | D3DDisassemble hung | seconds |",
              "|---|---|---|---|---|---|---|"]
    for b in batches:
        name = b["mode"] + ("-" + "-".join(b["edits"]) if b.get("edits") else "")
        lines.append(f"| {name} | {b['seed']} | {b['programs']} | {b['differing']} | {b['D3DDisassemble crashed']} "
                     f"| {b['D3DDisassemble hung']} | {b['made_s'] + b['compared_s']:.0f} |")
    lines += ["", f"## To fix: {sum(new.values())} programs", ""]
    if new:
        for kind, n in new.most_common():
            folder = os.path.join(out, "findings", kind)
            first = sorted(n for n in os.listdir(folder) if n.endswith(".json"))[:1] if os.path.isdir(folder) else []
            lines.append(f"- {n} {kind}" + (f" (first: findings/{kind}/{first[0]})" if first else ""))
    else:
        lines.append("None.")
    lines += ["", f"## Refused as malformed, which dx keeps: {sum(refusals.values())} programs", ""]
    lines += [f"- {n} {kind[len('refused_'):]}" for kind, n in refusals.most_common()] or ["None."]
    print("\n".join(lines))
    return 1 if new else 0


if __name__ == "__main__":
    sys.exit(main())
