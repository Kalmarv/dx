"""Compile the fixtures here with Microsoft's fxc and record Microsoft's listings of them (Windows only).

Each `.hlsl` states its builds as `// fxc: <arguments> /Fo <name>.dxbc` lines. For every build this writes the
container, fxc's own listing (`<name>.fxc.txt`, from `/Fc`) and D3DDisassemble's listing with no flags
(`<name>.asm`), the listing the disassembler tests compare against. With `--flags` it also writes one listing per
D3D_DISASM flag (`<name>.flag<hex>.asm`), to see which flags change the text.

    python -I generate.py [--fxc PATH] [--dll PATH] [--flags] [--out DIR] [extra .dxbc files...]
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
    out = subprocess.run(["powershell", "-NoProfile", "-Command", f"(Get-Item '{path}').VersionInfo.FileVersion"],
                         capture_output=True, text=True)
    return out.stdout.strip()


def sha256(path):
    return hashlib.sha256(open(path, "rb").read()).hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fxc", default=find_fxc())
    ap.add_argument("--dll", default=r"C:\Windows\System32\d3dcompiler_47.dll")
    ap.add_argument("--flags", action="store_true")
    ap.add_argument("--out", default=os.path.dirname(os.path.abspath(__file__)))
    ap.add_argument("extra", nargs="*")
    a = ap.parse_args()
    here = os.path.dirname(os.path.abspath(__file__))
    disasm = disassembler(a.dll)
    print(f"fxc {a.fxc} {version(a.fxc)} {sha256(a.fxc)}")
    print(f"dll {a.dll} {version(a.dll)} {sha256(a.dll)}")
    built, failed = list(a.extra), 0
    for src in sorted(glob.glob(os.path.join(here, "*.hlsl"))):
        for line in open(src, encoding="utf-8"):
            m = re.match(r"//\s*fxc:\s*(.*)", line)
            if not m:
                continue
            args = shlex.split(m.group(1), posix=False)
            out = os.path.join(a.out, args[args.index("/Fo") + 1])
            args[args.index("/Fo") + 1] = out
            stem = out[: -len(".dxbc")]
            cmd = [a.fxc, "/nologo", *args, "/Fc", stem + ".fxc.txt", src]
            r = subprocess.run(cmd, capture_output=True, text=True)
            if r.returncode != 0:
                failed += 1
                print(f"FAIL {os.path.basename(out)}: {r.stderr.strip() or r.stdout.strip()}")
                continue
            built.append(out)
    for path in built:
        data = open(path, "rb").read()
        stem = path[: -len(".dxbc")] if path.endswith(".dxbc") else path
        for flags in [0] + (FLAGS if a.flags else []):
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
