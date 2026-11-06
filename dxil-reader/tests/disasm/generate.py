"""Compile dx's DXIL fixtures with Microsoft's dxc and record dxc's listing of each (`dxc -dumpbin`).

Every `.hlsl` in the folders of SOURCES states its builds as `// dxc: <arguments> -Fo <name>.dxil` lines; each build is
compiled in that folder, from that file. Then dxc's listing of every container in LISTED goes to `listings/`:
`<name>.txt` for `<name>.dxil`. `../disasm.rs` compares the disassembler with them.

    python -I generate.py --dxc <dxc folder>

`fixtures/debug_nodes.dxil` is not compiled: `assemble.py` (a Windows Python with dxcompiler.dll 1.9.2609) assembles it
from `fixtures/debug_nodes.ll`, LLVM IR with the debug nodes no HLSL compiler writes; it is listed as the others are.

The dxc folder holds `bin/dxc` and `lib/` (the layout of Microsoft's Linux release, and of the oracle home's
`tools/dxc-linux-1.9.2609`). The fixtures and listings are those of dxc 1.9.2609 (VERSION); another build is refused,
since its listing differs, unless --any-version is given.
"""
import argparse, glob, hashlib, os, re, shlex, subprocess, sys

VERSION = "libdxcompiler.so: 1.9(5512-01b62ad4)(1.9.2609.5)"
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
# The folders whose sources are compiled, and those whose containers are listed (from the repository root).
SOURCES = ["dxil-reader/tests/fixtures", "dxil-reader/tests/disasm", "dxcontainer/tests/fixtures/features"]
LISTED = ["dxil-reader/tests/fixtures", "dxil-reader/tests/disasm"]


def sha256(path):
    return hashlib.sha256(open(path, "rb").read()).hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dxc", required=True, help="the folder with bin/dxc and lib/")
    ap.add_argument("--any-version", action="store_true", help="accept a dxc other than " + VERSION)
    a = ap.parse_args()
    dxc = os.path.join(os.path.abspath(a.dxc), "bin", "dxc")
    env = dict(os.environ, LD_LIBRARY_PATH=os.path.join(os.path.abspath(a.dxc), "lib"))
    version = subprocess.run([dxc, "--version"], capture_output=True, text=True, env=env).stdout.strip()
    print(f"dxc {dxc} {version} {sha256(dxc)}")
    if version != VERSION and not a.any_version:
        sys.exit(f"dxc is {version!r}, the fixtures are {VERSION!r}: give that build or --any-version")
    failed = 0
    for folder in SOURCES:
        for src in sorted(glob.glob(os.path.join(ROOT, folder, "*.hlsl"))):
            for line in open(src, encoding="utf-8"):
                m = re.match(r"//\s*dxc:\s*(.*)", line)
                if not m:
                    continue
                args = shlex.split(m.group(1))
                r = subprocess.run([dxc, *args, os.path.basename(src)], cwd=os.path.dirname(src),
                                   capture_output=True, text=True, env=env)
                out = args[args.index("-Fo") + 1]
                if r.returncode != 0:
                    failed += 1
                    print(f"FAIL {folder}/{out}: {r.stderr.strip() or r.stdout.strip()}")
                    continue
                print(f"built {folder}/{out}")
    listings = os.path.join(HERE, "listings")
    os.makedirs(listings, exist_ok=True)
    for folder in LISTED:
        for path in sorted(glob.glob(os.path.join(ROOT, folder, "*.dxil"))):
            r = subprocess.run([dxc, "-dumpbin", path], capture_output=True, env=env)
            name = os.path.basename(path)[: -len(".dxil")] + ".txt"
            if r.returncode != 0:
                failed += 1
                print(f"FAIL dumpbin {folder}/{os.path.basename(path)}: {r.stderr.decode(errors='replace').strip()}")
                continue
            open(os.path.join(listings, name), "wb").write(r.stdout)
    print(f"{failed} failed")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
