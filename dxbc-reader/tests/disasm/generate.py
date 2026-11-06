"""Compile the fixtures here with Microsoft's fxc and record Microsoft's listings of them (a Windows Python: on Windows,
or under Wine).

Each `.hlsl` states its builds as `// fxc: <arguments> /Fo <name>.dxbc` lines. Every build's container is written
here; D3DDisassemble's listings of it, and of every container in `../fixtures`, go to `listings/`: `<name>.asm` with
no flags and `<name>.flag<hex>.asm` with each flags word of FLAGS (0x08, which the disassembler refuses, writes
none). `../disasm.rs` compares the disassembler with them.

    python -I generate.py [--fxc PATH] [--dll PATH]

Sources are compiled from copies in `C:\\dx-fixtures` (see STAGE). Under Wine, give the fxc and d3dcompiler_47
builds the listings were made with, as Wine paths (Z:\\...): fxc
10.0.26100.4654 and its d3dcompiler_47.dll write the same bytes there as on Windows. Windows Python needs a console
under Wine, so run it in a pseudo-terminal (`script -qec "wine python.exe generate.py ..." /dev/null`).
"""
import argparse, ctypes, glob, hashlib, itertools, os, re, shlex, shutil, subprocess, sys

# The D3D_DISASM flags that change the text, alone, in pairs and all together; 0x01 (an HTML listing) is left out
# and 0x08, which the disassembler refuses, writes none.
TEXT_FLAGS = [0x2, 0x4, 0x10, 0x20, 0x40, 0x80]
FLAGS = sorted({0x8, *TEXT_FLAGS, *(a | b for a, b in itertools.combinations(TEXT_FLAGS, 2)), sum(TEXT_FLAGS)})

# fxc /Zi stores the source's absolute path in the container (and the listing prints it), so every source is compiled
# from a copy in this folder: the stored path is the same on every machine, under Wine too (the prefix's drive_c),
# and names no user. A /Zi build still differs on every run in its digest and its PDB's GUID and timestamp; its listings
# do not, so a build whose listings under every flags word are those of the container already here keeps that
# container, and a run over unchanged sources changes no file.
STAGE = r"C:\dx-fixtures"


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


def same_listings(disasm, old, new):
    """Whether the container at `old` exists and D3DDisassemble lists it as the one at `new` under every flags word."""
    if not os.path.exists(old):
        return False
    a, b = open(old, "rb").read(), open(new, "rb").read()
    return a == b or all(disasm(a, flags) == disasm(b, flags) for flags in [0] + FLAGS)


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
    os.makedirs(STAGE, exist_ok=True)
    for original in sorted(glob.glob(os.path.join(here, "*.hlsl"))):
        src = os.path.join(STAGE, os.path.basename(original))
        shutil.copyfile(original, src)
        for line in open(src, encoding="utf-8"):
            m = re.match(r"//\s*fxc:\s*(.*)", line)
            if not m:
                continue
            args = shlex.split(m.group(1), posix=False)
            out = os.path.join(here, args[args.index("/Fo") + 1])
            fresh = out + ".new"
            args[args.index("/Fo") + 1] = fresh
            cmd = [a.fxc, "/nologo", *args, src]
            r = subprocess.run(cmd, capture_output=True, text=True)
            if r.returncode != 0:
                failed += 1
                print(f"FAIL {os.path.basename(out)}: {r.stderr.strip() or r.stdout.strip()}")
                if os.path.exists(fresh):
                    os.remove(fresh)
                continue
            if same_listings(disasm, out, fresh):
                os.remove(fresh)
            else:
                os.replace(fresh, out)
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
