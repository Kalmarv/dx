"""Compile the fixtures here with Microsoft's fxc and record Microsoft's listings of them (a Windows Python: on Windows,
or under Wine).

Each `.hlsl` states its builds as `// fxc: <arguments> /Fo <name>.dxbc` lines. Every build's container is written
here; D3DDisassemble's listings of it, and of every container in `../fixtures`, go to `listings/`: `<name>.asm` with
no flags and `<name>.flag<hex>.asm` with each D3D_DISASM flag but the HTML one (0x08, which the disassembler refuses,
writes none). `../disasm.rs` compares the disassembler with them.

    python -I generate.py [--fxc PATH] [--dll PATH]

Under Wine, give the fxc and d3dcompiler_47 builds the listings were made with, as Wine paths (Z:\\...): fxc
10.0.26100.4654 and its d3dcompiler_47.dll write the same bytes there as on Windows. Windows Python needs a console
under Wine, so run it in a pseudo-terminal (`script -qec "wine python.exe generate.py ..." /dev/null`).
"""
import argparse, ctypes, glob, hashlib, os, re, shlex, subprocess, sys

FLAGS = [0x2, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80]


def find_fxc():
    hits = sorted(glob.glob(r"C:\Program Files (x86)\Windows Kits\10\bin\10.*\x64\fxc.exe"))
    return hits[-1] if hits else "fxc.exe"




def disassembler(path):
    dll = ctypes.WinDLL(path)
    fn = dll.D3DDisassemble
    fn.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_uint, ctypes.c_char_p, ctypes.POINTER(ctypes.c_void_p)]
    fn.restype = ctypes.c_long

    def call(data, flags):
        out = ctypes.c_void_p()
        buf = ctypes.create_string_buffer(data, len(data))
        hr = fn(buf, len(data), flags, None, ctypes.byref(out))
        if hr != 0:
            return None, hr & 0xFFFFFFFF
        vt = ctypes.cast(out, ctypes.POINTER(ctypes.POINTER(ctypes.c_void_p))).contents
        proto = ctypes.WINFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p)
        size_proto = ctypes.WINFUNCTYPE(ctypes.c_size_t, ctypes.c_void_p)
        ptr = proto(vt[3])(out)
        size = size_proto(vt[4])(out)
        text = ctypes.string_at(ptr, size)
        ctypes.WINFUNCTYPE(ctypes.c_ulong, ctypes.c_void_p)(vt[2])(out)
        return text, 0

    return call


def version(path):
    """The file version in a binary's version resource, as `major.minor.build.revision`."""
    api = ctypes.WinDLL("version")
    size = api.GetFileVersionInfoSizeW(path, None)
    data = ctypes.create_string_buffer(size)
    if not size or not api.GetFileVersionInfoW(path, 0, size, data):
        return "unknown"
    info, length = ctypes.c_void_p(), ctypes.c_uint()
    if not api.VerQueryValueW(data, "\\", ctypes.byref(info), ctypes.byref(length)):
        return "unknown"
    # VS_FIXEDFILEINFO: signature, struct version, then the file version's high and low words
    high, low = ctypes.cast(info, ctypes.POINTER(ctypes.c_uint32))[2:4]
    return f"{high >> 16}.{high & 0xFFFF}.{low >> 16}.{low & 0xFFFF}"


def sha256(path):
    return hashlib.sha256(open(path, "rb").read()).hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fxc", default=find_fxc())
    ap.add_argument("--dll", default=r"C:\Windows\System32\d3dcompiler_47.dll")
    a = ap.parse_args()
    here = os.path.dirname(os.path.abspath(__file__))
    listings = os.path.join(here, "listings")
    os.makedirs(listings, exist_ok=True)
    disasm = disassembler(a.dll)
    print(f"fxc {a.fxc} {version(a.fxc)} {sha256(a.fxc)}")
    print(f"dll {a.dll} {version(a.dll)} {sha256(a.dll)}")
    built, failed = sorted(glob.glob(os.path.join(here, "..", "fixtures", "*.dxbc"))), 0
    for src in sorted(glob.glob(os.path.join(here, "*.hlsl"))):
        for line in open(src, encoding="utf-8"):
            m = re.match(r"//\s*fxc:\s*(.*)", line)
            if not m:
                continue
            args = shlex.split(m.group(1), posix=False)
            out = os.path.join(here, args[args.index("/Fo") + 1])
            args[args.index("/Fo") + 1] = out
            cmd = [a.fxc, "/nologo", *args, src]
            r = subprocess.run(cmd, capture_output=True, text=True)
            if r.returncode != 0:
                failed += 1
                print(f"FAIL {os.path.basename(out)}: {r.stderr.strip() or r.stdout.strip()}")
                continue
            built.append(out)
    for path in built:
        data = open(path, "rb").read()
        stem = os.path.join(listings, os.path.basename(path)[: -len(".dxbc")])
        for flags in [0] + FLAGS:
            text, hr = disasm(data, flags)
            name = stem + (".asm" if flags == 0 else f".flag{flags:02x}.asm")
            if text is None:
                print(f"D3DDisassemble {os.path.basename(path)} flags {flags:#x}: hr {hr:#010x}")
                continue
            open(name, "wb").write(text.rstrip(b"\0"))
        print(f"ok {os.path.basename(path)}")
    print(f"{len(built)} built, {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
