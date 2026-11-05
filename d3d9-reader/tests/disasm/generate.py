"""Compile the Direct3D 9 fixtures here with Microsoft's fxc and record D3DDisassemble's listings of them (a Windows
Python: on Windows, or under Wine).

Each `.hlsl` states its builds as `// fxc: <arguments> /Fo <name>.bin` lines. Every build's program is written here
and its listing with no flags to `listings/<name>.asm`; `../disasm.rs` compares the disassembler with them.

    python -I generate.py --fxc PATH --dll PATH

Give the fxc and d3dcompiler_47 builds the listings were made with (10.0.26100.4654); under Wine as Wine paths
(Z:\\...), in a pseudo-terminal, since Windows Python needs a console there
(`script -qec "wine python.exe generate.py ..." /dev/null`).
"""
import argparse, ctypes, glob, hashlib, os, re, shlex, subprocess, sys


def disassembler(path):
    fn = ctypes.WinDLL(path).D3DDisassemble
    fn.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_uint, ctypes.c_char_p, ctypes.POINTER(ctypes.c_void_p)]
    fn.restype = ctypes.c_long

    def call(data):
        out = ctypes.c_void_p()
        hr = fn(ctypes.create_string_buffer(data, len(data)), len(data), 0, None, ctypes.byref(out))
        if hr != 0:
            return None, hr & 0xFFFFFFFF
        vt = ctypes.cast(out, ctypes.POINTER(ctypes.POINTER(ctypes.c_void_p))).contents
        ptr = ctypes.WINFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p)(vt[3])(out)
        size = ctypes.WINFUNCTYPE(ctypes.c_size_t, ctypes.c_void_p)(vt[4])(out)
        text = ctypes.string_at(ptr, size)
        ctypes.WINFUNCTYPE(ctypes.c_ulong, ctypes.c_void_p)(vt[2])(out)
        return text, 0

    return call


def sha256(path):
    return hashlib.sha256(open(path, "rb").read()).hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fxc", required=True)
    ap.add_argument("--dll", required=True)
    a = ap.parse_args()
    here = os.path.dirname(os.path.abspath(__file__))
    listings = os.path.join(here, "listings")
    os.makedirs(listings, exist_ok=True)
    disasm = disassembler(a.dll)
    print(f"fxc {a.fxc} {sha256(a.fxc)}")
    print(f"dll {a.dll} {sha256(a.dll)}")
    built, failed = [], 0
    for src in sorted(glob.glob(os.path.join(here, "*.hlsl"))):
        for line in open(src, encoding="utf-8"):
            m = re.match(r"//\s*fxc:\s*(.*)", line)
            if not m:
                continue
            args = shlex.split(m.group(1), posix=False)
            out = os.path.join(here, args[args.index("/Fo") + 1])
            args[args.index("/Fo") + 1] = out
            r = subprocess.run([a.fxc, "/nologo", *args, src], capture_output=True, text=True)
            if r.returncode != 0:
                failed += 1
                print(f"FAIL {os.path.basename(out)}: {r.stderr.strip() or r.stdout.strip()}")
                continue
            built.append(out)
    for path in built:
        text, hr = disasm(open(path, "rb").read())
        if text is None:
            failed += 1
            print(f"D3DDisassemble {os.path.basename(path)}: hr {hr:#010x}")
            continue
        name = os.path.basename(path)[: -len(".bin")] + ".asm"
        open(os.path.join(listings, name), "wb").write(text.rstrip(b"\0"))
        print(f"ok {os.path.basename(path)}")
    print(f"{len(built)} built, {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
