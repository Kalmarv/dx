"""Record the name dxc's listing gives each bit of a DXIL container's SFI0 part: `bits.txt`, one line per bit it names.

Each of the 64 bits is set alone in the SFI0 part of `wave.dxil` (a copy, written to a temporary folder), and the
lines dxc -dumpbin lists under "shader requires additional functionality" or "shader has optional feature flags set"
are the bit's name. `../../features.rs` checks the reader's names against the table.

    python -I bits.py --dxc <dxc folder>

The dxc folder holds `bin/dxc` and `lib/`, as for `dxil-reader/tests/disasm/generate.py`.
"""
import argparse, os, struct, subprocess, sys, tempfile

VERSION = "libdxcompiler.so: 1.9(5512-01b62ad4)(1.9.2609.5)"
HERE = os.path.dirname(os.path.abspath(__file__))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dxc", required=True, help="the folder with bin/dxc and lib/")
    a = ap.parse_args()
    dxc = os.path.join(os.path.abspath(a.dxc), "bin", "dxc")
    env = dict(os.environ, LD_LIBRARY_PATH=os.path.join(os.path.abspath(a.dxc), "lib"))
    version = subprocess.run([dxc, "--version"], capture_output=True, text=True, env=env).stdout.strip()
    if version != VERSION:
        sys.exit(f"dxc is {version!r}, the table is {VERSION!r}")
    container = open(os.path.join(HERE, "wave.dxil"), "rb").read()
    count = struct.unpack_from("<I", container, 28)[0]
    sfi0 = [o for o in struct.unpack_from(f"<{count}I", container, 32) if container[o : o + 4] == b"SFI0"][0] + 8
    rows = []
    with tempfile.TemporaryDirectory() as tmp:
        path = os.path.join(tmp, "bit.dxil")
        for bit in range(64):
            edited = bytearray(container)
            struct.pack_into("<Q", edited, sfi0, 1 << bit)
            open(path, "wb").write(edited)
            r = subprocess.run([dxc, "-dumpbin", path], capture_output=True, text=True, env=env, check=True)
            names = []
            for line in r.stdout.splitlines():
                if line.startswith(";       "):
                    names.append(line[8:])
                elif not line.startswith("; Note:") and line != ";":
                    break
            if len(names) > 1:
                sys.exit(f"bit {bit}: {names}")
            if names:
                rows.append(f"{bit}\t{names[0]}")
    with open(os.path.join(HERE, "bits.txt"), "w", newline="\n") as f:
        f.write(f"# bit\tthe name dxc -dumpbin lists for a DXIL container's SFI0 part with that bit alone set ({VERSION}).\n")
        f.write("# Written by bits.py; bits not listed have no name.\n")
        f.write("\n".join(rows) + "\n")
    print(f"{len(rows)} named bits")


if __name__ == "__main__":
    main()
