"""Compile the Direct3D 9 fixtures here with Microsoft's fxc and record D3DDisassemble's listings of them (a Windows
Python: on Windows, or under Wine).

Each `.hlsl` states its builds as `// fxc: <arguments> /Fo <name>.bin` lines. Every build's program is written here
and its listings to `listings/`: `<name>.asm` with no flags and `<name>.flag<hex>.asm` with each other flags word of
FLAGS; `../disasm.rs` compares the disassembler with them. fxc no longer compiles Shader Model 1, so the programs of
SM1 are written from the tokens in HAND_BUILT.

Sources are compiled from copies in `C:\\dx9-fixtures` (see STAGE), with the `.hlsli` files they include.

    python -I generate.py --fxc PATH --dll PATH

Give the fxc and d3dcompiler_47 builds the listings were made with (10.0.26100.4654); under Wine as Wine paths
(Z:\\...), in a pseudo-terminal, since Windows Python needs a console there
(`script -qec "wine python.exe generate.py ..." /dev/null`).
"""
import argparse, ctypes, glob, hashlib, itertools, os, re, shlex, shutil, struct, subprocess, sys

# No flags, and the D3D_DISASM flags that change the text alone, in pairs and all together (0x01, an HTML listing,
# and 0x08, which the disassembler refuses, left out).
TEXT_FLAGS = [0x2, 0x4, 0x10, 0x20, 0x40, 0x80]
FLAGS = sorted({0, *TEXT_FLAGS, *(a | b for a, b in itertools.combinations(TEXT_FLAGS, 2)), sum(TEXT_FLAGS)})

# fxc /Zi stores the source's absolute path in the program (and the listing prints it), so every source is compiled
# from a copy in this folder: the stored path is the same on every machine, under Wine too (the prefix's drive_c),
# and names no user.
STAGE = r"C:\dx9-fixtures"


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



# Every version, for the programs below: vs_1_1 to vs_3_0 (vs_2_x as 2.1) and ps_1_1 to ps_3_0.
VERSIONS = {"vs11": 0xFFFE0101, "vs20": 0xFFFE0200, "vs2x": 0xFFFE0201, "vs30": 0xFFFE0300, "ps11": 0xFFFF0101,
            "ps12": 0xFFFF0102, "ps13": 0xFFFF0103, "ps14": 0xFFFF0104, "ps20": 0xFFFF0200, "ps2x": 0xFFFF0201,
            "ps30": 0xFFFF0300}

# The operands of each opcode, (destination, sources), as Microsoft's disassembler reads them in every version; tex,
# texcoord, sgn and sincos read more or fewer by version (see `operands`), and dcl, def, defi, defb and phase are
# written apart.
OPERANDS = {
    **dict.fromkeys([0, 28, 29, 39, 42, 43, 44], (False, 0)),           # nop ret endloop endrep else endif break
    **dict.fromkeys([25, 30, 38, 40, 96], (False, 1)),                  # call label rep if breakp
    **dict.fromkeys([26, 27, 41, 45], (False, 2)),                      # callnz loop if_comp break_comp
    **dict.fromkeys([65, 87], (True, 0)),                               # texkill texdepth
    **dict.fromkeys([1, 6, 7, 14, 15, 16, 19, 35, 36, 46, 78, 79, 91, 92, 67, 68, 69, 70, 71, 72, 73, 74, 77, 82, 83,
                     84, 85, 86], (True, 1)),
    **dict.fromkeys([2, 3, 5, 8, 9, 10, 11, 12, 13, 17, 20, 21, 22, 23, 24, 32, 33, 76, 89, 94, 95], (True, 2)),
    **dict.fromkeys([4, 18, 80, 88, 90], (True, 3)),                    # mad lrp cnd cmp dp2add
    93: (True, 4),                                                      # texldd
}


def operands(op, version):
    major, minor = (version >> 8) & 0xFF, version & 0xFF
    if op == 66:                                                        # tex: t0; texld r0, t0 in 1.4; + s0 from 2.0
        return (True, (1 if minor == 4 else 0) if major == 1 else 2)
    if op == 64:                                                        # texcoord t0; texcrd r0, t0 in 1.4
        return (True, 1 if minor == 4 else 0)
    if op in (34, 37):                                                  # sgn and sincos read three sources before 3.0
        return (True, 3 if major < 3 else 1)
    return OPERANDS[op]


def instruction(version, op, destination, sources, flags=0):
    """An instruction's tokens: its token (with its length from Shader Model 2 on) and its operand tokens."""
    words = ([destination] if destination is not None else []) + list(sources)
    length = 0 if (version >> 8) & 0xFF == 1 else len(words)
    return [op | flags | (length << 24), *words]


def every_opcode(version):
    """Every Direct3D 9 instruction once, in opcode order, whatever the version's own list: r0 written and r1 to r4
    read, the comparison of if_comp, break_comp and setp_comp `gt`, and dcl, def, defi, defb and phase with their own
    operands; then a dcl, which like the definitions after `if` is inside the `if` that no `endif` closes."""
    body = []
    for op in [*range(0, 31), 31, *range(32, 47), 47, 48, *range(64, 75), *range(76, 81), 81, *range(82, 97), 0xFFFD]:
        if op == 31:
            body += instruction(version, 31, None, [0x80000005, 0x900F0000])        # dcl_texcoord v0
        elif op == 81:
            body += instruction(version, 81, None, [0xA00F0000, 0x3F800000, 0, 0, 0x3F800000])  # def c0, 1, 0, 0, 1
        elif op == 48:
            body += instruction(version, 48, None, [0xF00F0000, 1, 2, 3, 4])        # defi i0, 1, 2, 3, 4
        elif op == 47:
            body += instruction(version, 47, None, [0xE00F0800, 1])                 # defb b0, true
        elif op == 0xFFFD:
            body.append(0xFFFD)                                                     # phase
        else:
            destination, count = operands(op, version)
            control = 1 << 16 if op in (41, 45, 94) else 0
            body += instruction(version, op, 0x800F0000 if destination else None,
                                [0x80E40001 + n for n in range(count)], control)
    # and a dcl inside the `if` left open
    body += instruction(version, 31, None, [0x80010005, 0x900F0001])            # dcl_texcoord1 v1
    return [version, *body, 0xFFFF]


def every_register(version):
    """A co-issued first instruction; every register type as the source of `mov r0, X` and the destination of
    `mov X, r1` (the three rasterizer outputs, vPos and vFace each); a dcl of every usage at index 0 and 1; and the
    flags of other versions: each result shift, relative destinations and sources, co-issue, and predication, plain and
    negated."""
    kind = lambda t: ((t & 7) << 28) | ((t & 0x18) << 8)
    sm1 = (version >> 8) & 0xFF == 1
    body = instruction(version, 1, 0x80070000, [0x90E40000], 0x40000000)
    for t, numbers in [(t, [0]) for t in range(16) if t != 4] + [(4, [0, 1, 2]), (17, [0, 1]), (18, [0]), (19, [0])]:
        for n in numbers:
            body += instruction(version, 1, 0x800F0000, [0x80E40000 | kind(t) | n])
            body += instruction(version, 1, 0x800F0000 | kind(t) | n, [0x80E40001])
    for usage in range(14):
        for index in (0, 1):
            body += instruction(version, 31, None, [0x80000000 | usage | index << 16, 0x900F0000 | usage * 2 + index])
    for shift in (1, 2, 3, 13, 14, 15):
        body += instruction(version, 1, 0x800F0000 | shift << 24, [0x90E40000])
    address = [] if sm1 else [0xB0000000]                               # a0.x (tN.x in a pixel program)
    body += instruction(version, 1, 0x800F2000, [*address, 0x90E40000])
    body += instruction(version, 1, 0x800F0000, [0xA0E42000, *address])
    body += instruction(version, 1, 0x80070000, [0x90E40000])
    body += instruction(version, 1, 0x80080001, [0x90E40001], 0x40000000)
    body += instruction(version, 1, 0x800F0000, [0xB0E41000, 0x90E40000], 0x10000000)
    body += instruction(version, 2, 0x800F0000, [0xBD001000, 0x90E40000, 0x90E40001], 0x10000000)
    return [version, *body, 0xFFFF]


# Each version's instructions and registers, read whatever its own lists, as tokens.
for _name, _version in VERSIONS.items():
    HAND_BUILT[f"versions.opcodes.{_name}"] = every_opcode(_version)
    HAND_BUILT[f"versions.registers.{_name}"] = every_register(_version)



def ctab_types(data):
    """ctab.many.ps30 with each parameter tNN's type set to NN for NN up to 71 (its class scalar), and the classes 6 and
    7 on t72 and t73: every D3DXPARAMETER_TYPE and D3D_SHADER_VARIABLE_TYPE value, those past them, and classes past
    struct, which the compiler never writes."""
    data = bytearray(data)
    assert data[4:6] == b"\xfe\xff" and data[8:12] == b"CTAB"
    base = 12
    count, info = struct.unpack_from("<II", data, base + 12)
    for n in range(count):
        name, _, _, _, _, type_info, _ = struct.unpack_from("<I4HII", data, base + info + 20 * n)
        number = int(data[base + name:data.index(b"\0", base + name)].decode()[1:])
        if number < 72:
            struct.pack_into("<HH", data, base + type_info, 0, number)
        else:
            struct.pack_into("<H", data, base + type_info, number - 66)
    return bytes(data)


# Programs written from a built one with bytes changed, for what the compiler never writes: name -> (built, change).
PATCHED = {"ctab.types.ps30": ("ctab.many.ps30", ctab_types)}


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
    os.makedirs(STAGE, exist_ok=True)
    for include in sorted(glob.glob(os.path.join(here, "*.hlsli"))):
        shutil.copyfile(include, os.path.join(STAGE, os.path.basename(include)))
    for original in sorted(glob.glob(os.path.join(here, "*.hlsl"))):
        src = os.path.join(STAGE, os.path.basename(original))
        shutil.copyfile(original, src)
        for line in open(original, encoding="utf-8"):
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
    for name, (source, change) in PATCHED.items():
        out = os.path.join(here, name + ".bin")
        open(out, "wb").write(change(open(os.path.join(here, source + ".bin"), "rb").read()))
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
