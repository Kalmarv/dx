"""Compile the Direct3D 9 fixtures here with Microsoft's fxc and record D3DDisassemble's listings of them (a Windows
Python: on Windows, or under Wine).

Each `.hlsl` states its builds as `// fxc: <arguments> /Fo <name>.bin` lines. Every build's program is written here
and its listings to `listings/`: `<name>.asm` with no flags and `<name>.flag<hex>.asm` with each other flags word of
FLAGS; `../disasm.rs` compares the disassembler with them. fxc no longer compiles Shader Model 1, so the programs of
SM1 are written from the tokens in HAND_BUILT.

    python -I generate.py --fxc PATH --dll PATH

Give the fxc and d3dcompiler_47 builds the listings were made with (10.0.26100.4654); under Wine as Wine paths
(Z:\\...), in a pseudo-terminal, since Windows Python needs a console there
(`script -qec "wine python.exe generate.py ..." /dev/null`).
"""
import argparse, ctypes, glob, hashlib, itertools, os, re, shlex, struct, subprocess, sys

# No flags, and the D3D_DISASM flags that change the text alone, in pairs and all together (0x01, an HTML listing,
# and 0x08, which the disassembler refuses, left out).
TEXT_FLAGS = [0x2, 0x4, 0x10, 0x20, 0x40, 0x80]
FLAGS = sorted({0, *TEXT_FLAGS, *(a | b for a, b in itertools.combinations(TEXT_FLAGS, 2)), sum(TEXT_FLAGS)})


# Shader Model 1 programs, as their tokens (the assembly they are in the comments).
HAND_BUILT = {
    # tex t0; mov r0, t0; mov r0.xyz, c0; + mov r0.w, v0
    "sm1.coissue.ps11": [0xFFFF0101, 0x00000042, 0xB00F0000, 0x00000001, 0x800F0000, 0xB0E40000, 0x00000001,
                         0x80070000, 0xA0E40000, 0x40000001, 0x80080000, 0x90E40000, 0x0000FFFF],
    # tex t0; mov r0, t0; + mov r0.w, v0.w
    "sm1.coissue.ps12": [0xFFFF0102, 0x00000042, 0xB00F0000, 0x00000001, 0x800F0000, 0xB0E40000, 0x40000001,
                         0x80080000, 0x90FF0000, 0x0000FFFF],
    # tex t0; mov r0, t0
    "sm1.plain.ps13": [0xFFFF0103, 0x00000042, 0xB00F0000, 0x00000001, 0x800F0000, 0xB0E40000, 0x0000FFFF],
    # texld r0, t0; phase; mul r0, r0, v0; mov r0.xyz, c0; + mov r0.w, c0
    "sm1.coissue.ps14": [0xFFFF0104, 0x00000042, 0x800F0000, 0xB0E40000, 0x0000FFFD, 0x00000005, 0x800F0000,
                         0x80E40000, 0x90E40000, 0x00000001, 0x80070000, 0xA0E40000, 0x40000001, 0x80080000,
                         0xA0E40000, 0x0000FFFF],
    # def c0, 1, 0.5, 0, 1; tex t0; tex t1; mul_x2 r0, t0_bx2, v0; add_sat r0, r0, 1-t1; cnd r0, r0.w, c0, v0
    "sm1.modifiers.ps11": [0xFFFF0101, 0x00000051, 0xA00F0000, 0x3F800000, 0x3F000000, 0x00000000, 0x3F800000,
                           0x00000042, 0xB00F0000, 0x00000042, 0xB00F0001, 0x00000005, 0x810F0000, 0xB4E40000,
                           0x90E40000, 0x00000002, 0x801F0000, 0x80E40000, 0xB6E40001, 0x00000050, 0x800F0000,
                           0x80FF0000, 0xA0E40000, 0x90E40000, 0x0000FFFF],
    # dcl_position v0; mov oPos, v0
    "sm1.plain.vs11": [0xFFFE0101, 0x0000001F, 0x80000000, 0x900F0000, 0x00000001, 0xC00F0000, 0x90E40000,
                       0x0000FFFF],
    # dcl_position v0; m4x4 oPos, v0, c0; mov a0.x, v0.x; mov oD0, c4[a0.x]
    "sm1.relative.vs11": [0xFFFE0101, 0x0000001F, 0x80000000, 0x900F0000, 0x00000014, 0xC00F0000, 0x90E40000,
                          0xA0E40000, 0x00000001, 0xB0010000, 0x90000000, 0x00000001, 0xD00F0000, 0xA0E42004,
                          0x0000FFFF],
    # tex t0; tex t1; mul r0.xyz, t0, v0; + mul_x2 r0.w, t1, v0; add r0.xyz, r0, t1; + add_sat r0.w, r0, c0;
    # mov r1, r0
    "sm1.pairs.ps11": [0xFFFF0101, 0x00000042, 0xB00F0000, 0x00000042, 0xB00F0001, 0x00000005, 0x80070000,
                       0xB0E40000, 0x90E40000, 0x40000005, 0x81080000, 0xB0E40001, 0x90E40000, 0x00000002,
                       0x80070000, 0x80E40000, 0xB0E40001, 0x40000002, 0x80180000, 0x80E40000, 0xA0E40000,
                       0x00000001, 0x800F0001, 0x80E40000, 0x0000FFFF],
}


def disassembler(path):
    fn = ctypes.WinDLL(path).D3DDisassemble
    fn.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_uint, ctypes.c_char_p, ctypes.POINTER(ctypes.c_void_p)]
    fn.restype = ctypes.c_long

    def call(data, flags):
        out = ctypes.c_void_p()
        hr = fn(ctypes.create_string_buffer(data, len(data)), len(data), flags, None, ctypes.byref(out))
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
    for name, words in HAND_BUILT.items():
        out = os.path.join(here, name + ".bin")
        open(out, "wb").write(struct.pack(f"<{len(words)}I", *words))
        built.append(out)
    for path in built:
        data = open(path, "rb").read()
        stem = os.path.join(listings, os.path.basename(path)[: -len(".bin")])
        for flags in FLAGS:
            text, hr = disasm(data, flags)
            if text is None:
                failed += 1
                print(f"D3DDisassemble {os.path.basename(path)} flags {flags:#x}: hr {hr:#010x}")
                continue
            name = stem + (".asm" if flags == 0 else f".flag{flags:02x}.asm")
            open(name, "wb").write(text.rstrip(b"\0"))
        print(f"ok {os.path.basename(path)}")
    print(f"{len(built)} built, {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
