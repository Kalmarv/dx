"""The differential of dx's disassembler against Microsoft's (D3DDisassemble in d3dcompiler_47, SDK 10.0.26100.4654)
over generated programs. Windows Python, run with -I.

    python -I differ.py hlsl  --cases N --seed S --out DIR     random HLSL (hlslgen.py), compiled by D3DCompile
    python -I differ.py edit  --cases N --seed S --out DIR     edits of compiled programs' bytecode, re-hashed

Each batch is written to DIR/batch-<seed>: the programs (NAME.dxbc, or NAME.bin for a Direct3D 9 token stream),
Microsoft's listings under every flags word (NAME.ms.FF.txt, or NAME.ms.FF.err with the HRESULT), dx's (dxlist:
NAME.dx.FF.txt / .err). Every program where they differ (a listing differs, or one lists what the other refuses) is
copied to DIR/findings/<kind>/ with its source or edit, and the batch summary goes to DIR/summary.jsonl.

dx's listings come from dxlist (dxlist/, which weekly.sh builds into target/); Microsoft's from $DX_D3DCOMPILER, by
default the Windows SDK 10.0.26100.0 d3dcompiler_47.dll."""
import argparse, ctypes, hashlib, itertools, json, os, random, re, shutil, struct, subprocess, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import dxbc_hash, hlslgen  # noqa: E402

DLL = os.environ.get("DX_D3DCOMPILER",
                     r"C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\d3dcompiler_47.dll")
DXLIST = os.path.join(HERE, "target", "release", "dxlist.exe")
TEXT_FLAGS = [0x2, 0x4, 0x10, 0x20, 0x40, 0x80]
FLAGS = sorted({0, 0x8, *TEXT_FLAGS, *(a | b for a, b in itertools.combinations(TEXT_FLAGS, 2)), sum(TEXT_FLAGS)})


class Compiler:
    def __init__(self, path=DLL):
        dll = ctypes.WinDLL(path)
        self.compile_ = dll.D3DCompile
        self.compile_.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p, ctypes.c_void_p, ctypes.c_void_p,
                                  ctypes.c_char_p, ctypes.c_char_p, ctypes.c_uint, ctypes.c_uint,
                                  ctypes.POINTER(ctypes.c_void_p), ctypes.POINTER(ctypes.c_void_p)]
        self.compile_.restype = ctypes.c_long
        self.disasm_ = dll.D3DDisassemble
        self.disasm_.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_uint, ctypes.c_char_p,
                                 ctypes.POINTER(ctypes.c_void_p)]
        self.disasm_.restype = ctypes.c_long

    @staticmethod
    def blob(p):
        if not p:
            return None
        vt = ctypes.cast(p, ctypes.POINTER(ctypes.POINTER(ctypes.c_void_p))).contents
        ptr = ctypes.WINFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p)(vt[3])(p)
        size = ctypes.WINFUNCTYPE(ctypes.c_size_t, ctypes.c_void_p)(vt[4])(p)
        data = ctypes.string_at(ptr, size)
        ctypes.WINFUNCTYPE(ctypes.c_ulong, ctypes.c_void_p)(vt[2])(p)
        return data

    def compile(self, src, target, flags, entry="main"):
        code, errors = ctypes.c_void_p(), ctypes.c_void_p()
        data = src.encode()
        hr = self.compile_(data, len(data), b"gen.hlsl", None, None, entry.encode(), target.encode(), flags, 0,
                           ctypes.byref(code), ctypes.byref(errors))
        text = self.blob(errors.value)
        program = self.blob(code.value)
        return (program if hr == 0 else None), (text or b"").decode(errors="replace")

    def disassemble(self, data, flags):
        out = ctypes.c_void_p()
        buf = ctypes.create_string_buffer(data, len(data))
        hr = self.disasm_(buf, len(data), flags, None, ctypes.byref(out))
        if hr != 0:
            return None, hr & 0xFFFFFFFF
        return self.blob(out.value).rstrip(b"\0"), 0


def d3d9(program):
    return program[2:4] in (b"\xfe\xff", b"\xff\xff")


def program_path(folder, stem):
    for ext in (".dxbc", ".bin"):
        if os.path.exists(os.path.join(folder, stem + ext)):
            return os.path.join(folder, stem + ext)
    raise FileNotFoundError(stem)


def write_program(folder, stem, program):
    ext = ".bin" if d3d9(program) and program[:4] != b"DXBC" else ".dxbc"
    open(os.path.join(folder, stem + ext), "wb").write(program)


def ms_worker(folder, listing):
    """Microsoft's listings of the programs named in `listing`, in this process; `.current` names the one being
    listed, so a parent can tell which crashed D3DDisassemble."""
    cc = Compiler()
    for stem in open(listing).read().split():
        open(os.path.join(folder, ".current"), "w").write(stem)
        write_ms(cc, folder, stem, open(program_path(folder, stem), "rb").read())
    os.remove(os.path.join(folder, ".current"))


def list_ms(folder, stems, patience=10):
    """Microsoft's listings of every program, in worker processes. One D3DDisassemble crashes on, or spends more than
    `patience` seconds on, is set aside, and the rest are listed: returns those crashed and those hung."""
    crashed, hung, left = [], [], list(stems)
    current = os.path.join(folder, ".current")
    while left:
        listing = os.path.join(folder, ".todo")
        open(listing, "w").write(" ".join(left))
        if os.path.exists(current):
            os.remove(current)
        worker = subprocess.Popen([sys.executable, "-I", os.path.abspath(__file__), "ms-worker", folder, listing],
                                  stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        seen, since = None, time.time()
        while worker.poll() is None:
            time.sleep(0.2)
            now = open(current).read().strip() if os.path.exists(current) else None
            if now != seen:
                seen, since = now, time.time()
            elif now and time.time() - since > patience:
                worker.kill()
                worker.wait()
                break
        if worker.returncode == 0:
            break
        stuck = open(current).read().strip()
        (hung if worker.returncode in (None, 1) and time.time() - since > patience else crashed).append(stuck)
        left = left[left.index(stuck) + 1:]
    return crashed, hung


def write_ms(cc, folder, stem, program):
    for f in FLAGS:
        text, hr = cc.disassemble(program, f)
        if text is None:
            open(os.path.join(folder, f"{stem}.ms.{f:02x}.err"), "w").write(f"{hr:#010x}")
        else:
            open(os.path.join(folder, f"{stem}.ms.{f:02x}.txt"), "wb").write(text)


def first_difference(a, b):
    x, y = a.split("\n"), b.split("\n")
    for i in range(max(len(x), len(y))):
        p = x[i] if i < len(x) else "<end>"
        q = y[i] if i < len(y) else "<end>"
        if p != q:
            return i + 1, p, q
    return None


def kind_of(line):
    """A differing line's kind, for grouping: a comment's first words, an instruction's mnemonic."""
    t = line.strip()
    # the instruction number (0x04) and offset (0x20) prefixes
    while t and (t.split(" ")[0].rstrip(":").isdigit() or t.startswith("0x")) and " " in t:
        t = t.split(" ", 1)[1].strip()
    if t.startswith("//"):
        return "comment:" + " ".join(t[2:].split()[:2])
    return t.split(" ")[0].split("(")[0] if t else "<blank>"


def reason(error):
    """A refusal's reason without its numbers, for grouping."""
    detail = error.split(": ", 1)[1] if ": " in error else error
    return re.sub(r"-?\b\d+\b", "N", re.sub(r"\b0x[0-9a-f]+\b", "X", detail))[:50]


def compare(folder, stems):
    """Run dxlist over the batch and compare: the differences, by program, under each flags word."""
    subprocess.run([DXLIST, folder, *[f"{f:x}" for f in FLAGS]], check=True, capture_output=True)
    out = {}
    for stem in stems:
        diffs = []
        for f in FLAGS:
            ms = os.path.join(folder, f"{stem}.ms.{f:02x}")
            dx = os.path.join(folder, f"{stem}.dx.{f:02x}")
            ms_text = open(ms + ".txt", "rb").read().decode(errors="replace").replace("\r\n", "\n") \
                if os.path.exists(ms + ".txt") else None
            dx_text = open(dx + ".txt", encoding="utf-8").read() if os.path.exists(dx + ".txt") else None
            if os.path.exists(dx + ".panic"):
                diffs.append({"flags": f, "kind": "dx panics"})
                continue
            if ms_text is None and dx_text is None:
                continue
            if ms_text is None:
                diffs.append({"flags": f, "kind": "dx lists what Microsoft refuses",
                              "ms": open(ms + ".err").read()})
            elif dx_text is None:
                why = open(dx + ".err", encoding="utf-8").read()
                diffs.append({"flags": f, "kind": "refused " + reason(why), "dx": why})
            else:
                d = first_difference(ms_text, dx_text)
                if d:
                    diffs.append({"flags": f, "kind": "line: " + kind_of(d[1] if d[1] != "<end>" else d[2]),
                                  "line": d[0], "ms": d[1], "dx": d[2]})
        if diffs:
            out[stem] = diffs
    return out


def keep(findings, folder, stem, diffs, meta):
    """Copy a differing program to findings/<kind of its first difference>/, with what made it."""
    kind = re.sub(r"[^A-Za-z0-9_.+-]+", "_", diffs[0]["kind"]).strip("_.")[:60] or "unnamed"
    dest = os.path.join(findings, kind)
    os.makedirs(dest, exist_ok=True)
    for name in os.listdir(folder):
        if name.startswith(stem + "."):
            shutil.copy(os.path.join(folder, name), dest)
    json.dump({**meta, "differences": diffs}, open(os.path.join(dest, stem + ".json"), "w"), indent=1)
    return kind


def run_hlsl(cc, args, folder):
    rng = random.Random(args.seed)
    made, refused, stems, meta = 0, 0, [], {}
    for i in range(args.cases):
        target, src, flags = hlslgen.generate(rng)
        program, errors = cc.compile(src, target, flags)
        if program is None:
            refused += 1
            if args.keep_refused:
                open(os.path.join(folder, f"refused{i}.hlsl"), "w").write(f"// {target} {flags:#x}\n{src}\n/*\n{errors}*/\n")
            continue
        stem = f"h{args.seed}_{i}"
        write_program(folder, stem, program)
        open(os.path.join(folder, stem + ".hlsl"), "w").write(f"// {target} D3DCompile flags {flags:#x}\n{src}")
        stems.append(stem)
        meta[stem] = {"mode": "hlsl", "seed": args.seed, "case": i, "target": target, "compile_flags": flags}
        made += 1
    return stems, meta, {"compiled": made, "refused by fxc": refused}


REPO = os.path.join(HERE, "..")
# bit patterns an edit writes into a word: special floats (a signaling NaN among them), small integers, sign bits
SPECIAL_WORDS = [0x7F800000, 0xFF800000, 0x7FC00000, 0xFFC00000, 0x7FA00000, 0x7F800001, 0xFFBFFFFF, 0x00000001,
                 0x807FFFFF, 0x7F7FFFFF, 0x80000000, 0xFFFFFFFF, 0, 1, 2, 3, 0x3F800000, 0xBF800000]


def sources(args):
    """The programs an edit starts from: the committed ones, and those of earlier hlsl batches in --out."""
    out = []
    for d in ["dxbc-reader/tests/disasm", "dxbc-reader/tests/fixtures", "d3d9-reader/tests/disasm",
              "d3d9-reader/tests/assembled"]:
        folder = os.path.join(REPO, d)
        out += [os.path.join(folder, n) for n in sorted(os.listdir(folder)) if n.endswith((".dxbc", ".bin"))]
    for b in sorted(os.listdir(args.out)):
        if b.startswith("batch-hlsl-"):
            folder = os.path.join(args.out, b)
            out += [os.path.join(folder, n) for n in sorted(os.listdir(folder)) if n.endswith((".dxbc", ".bin"))]
    return out


def parts(program):
    count = struct.unpack_from("<I", program, 28)[0]
    out = []
    for i in range(count):
        at = struct.unpack_from("<I", program, 32 + 4 * i)[0]
        kind, size = program[at:at + 4], struct.unpack_from("<I", program, at + 4)[0]
        out.append((kind, at + 8, size))
    return out


# what an edit changes: an immediate's value, an operand token's swizzle or mask bits (4 to 11), a register number (the
# word after an operand token with an immediate index), a control bit of an instruction token (11 to 23), or a byte
EDIT_KINDS = ["immediate", "swizzle", "register", "control", "byte", "special"]


def immediates(data, start, words):
    """The words of immediate values: those after an operand token of type immediate32 (4) with one or four components."""
    out = []
    i = 0
    while i < words - 1:
        t = struct.unpack_from("<I", data, start + 4 * i)[0]
        if (t >> 12) & 0xFF == 4 and t & 3 in (1, 2) and not t & 0x80000000:
            n = 1 if t & 3 == 1 else 4
            out += [start + 4 * (i + 1 + k) for k in range(n) if i + 1 + k < words]
            i += 1 + n
            continue
        i += 1
    return out


def operand_tokens(data, start, words):
    """Words that look like operand tokens of a register with a 1D immediate index (register types 0 to 3)."""
    out = []
    for i in range(words - 1):
        t = struct.unpack_from("<I", data, start + 4 * i)[0]
        if (t >> 12) & 0xFF in (0, 1, 2, 3) and (t >> 20) & 3 == 1 and (t >> 22) & 7 == 0 and t & 3 == 2 \
                and not t & 0x80000000:
            out.append(start + 4 * i)
    return out


def edit(rng, program, kinds):
    """Change a few words of a program, by edits of `kinds`: in a DXBC container mostly its code part, then re-hash it."""
    data = bytearray(program)
    container = data[:4] == b"DXBC"
    if container:
        ps = parts(program)
        code = [p for p in ps if p[0] in (b"SHDR", b"SHEX")]
        if not code and set(kinds) <= {"immediate", "swizzle", "register", "control"}:
            return None, None
        kind, start, size = rng.choice(code) if code and (rng.random() < 0.8 or kinds != EDIT_KINDS) else rng.choice(ps)
    else:
        if set(kinds) <= {"immediate", "swizzle", "register", "control"}:
            return None, None
        kind, start, size = b"D3D9", 0, len(data)
    words = size // 4
    if words == 0:
        return None, None
    changes = []
    for _ in range(rng.randint(1, 3)):
        how = rng.choice(kinds)
        if how == "immediate":
            spots = immediates(data, start, words)
            if not spots:
                continue
            at = rng.choice(spots)
            new = rng.choice(SPECIAL_WORDS + [rng.getrandbits(32), rng.randrange(-20000, 20000) & 0xFFFFFFFF])
        elif how in ("swizzle", "register"):
            spots = operand_tokens(data, start, words)
            if not spots:
                continue
            at = rng.choice(spots)
            old = struct.unpack_from("<I", data, at)[0]
            if how == "swizzle":
                new = (old & ~0xFF0) | (rng.randrange(256) << 4)
            else:
                at += 4
                new = rng.choice([0, 1, 7, 15, 31, 4095, 0x7FFFFFFF, 0x80000000, 0xFFFFFFFF, rng.getrandbits(32)])
        elif how == "control":
            spots = [start + 4 * i for i in range(2, words)
                     if struct.unpack_from("<I", data, start + 4 * i)[0] & 0x7FF < 0xFF
                     and (struct.unpack_from("<I", data, start + 4 * i)[0] >> 24) & 0x7F > 0]
            if not spots:
                continue
            at = rng.choice(spots)
            new = struct.unpack_from("<I", data, at)[0] ^ (1 << rng.randrange(11, 24))
        else:
            at = start + 4 * rng.randrange(words)
            old = struct.unpack_from("<I", data, at)[0]
            if how == "special":
                new = rng.choice(SPECIAL_WORDS)
            else:
                new = (old & ~(0xFF << (8 * rng.randrange(4)))) | (rng.randrange(256) << (8 * rng.randrange(4)))
        new &= 0xFFFFFFFF
        old = struct.unpack_from("<I", data, at)[0]
        struct.pack_into("<I", data, at, new)
        changes.append({"kind": how, "part": kind.decode(errors="replace"), "byte": at, "old": f"{old:#010x}",
                        "new": f"{new:#010x}"})
    if not changes:
        return None, None
    out = bytes(data)
    if container:
        out = dxbc_hash.rehash(out)
    return out, changes


def run_edit(cc, args, folder):
    rng = random.Random(args.seed)
    pool = sources(args)
    blobs = {}
    stems, meta, both_refuse = [], {}, 0
    for i in range(args.cases):
        path = rng.choice(pool)
        if path not in blobs:
            blobs[path] = open(path, "rb").read()
        program, changes = edit(rng, blobs[path], args.kinds)
        if program is None:
            continue
        stem = f"e{args.seed}_{i}"
        write_program(folder, stem, program)
        stems.append(stem)
        meta[stem] = {"mode": "edit", "seed": args.seed, "case": i, "from": os.path.relpath(path, HERE),
                      "changes": changes}
    return stems, meta, {"edited": len(stems)}


def main():
    if sys.argv[1:2] == ["ms-worker"]:
        return ms_worker(sys.argv[2], sys.argv[3])
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["hlsl", "edit"])
    ap.add_argument("--cases", type=int, default=200)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--out", required=True)
    ap.add_argument("--keep-refused", action="store_true")
    ap.add_argument("--kinds", type=lambda t: t.split(","), default=EDIT_KINDS,
                    help="the edits to make, of " + ",".join(EDIT_KINDS))
    args = ap.parse_args()
    cc = Compiler()
    tag = "" if args.mode == "hlsl" or args.kinds == EDIT_KINDS else "-" + "-".join(args.kinds)
    folder = os.path.join(args.out, f"batch-{args.mode}{tag}-{args.seed}")
    shutil.rmtree(folder, ignore_errors=True)
    os.makedirs(folder)
    start = time.time()
    if args.mode == "hlsl":
        stems, meta, counts = run_hlsl(cc, args, folder)
    else:
        stems, meta, counts = run_edit(cc, args, folder)
    crashed, hung = list_ms(folder, stems)
    for name, which in (("microsoft-crashes", crashed), ("microsoft-hangs", hung)):
        for stem in which:
            dest = os.path.join(args.out, name)
            os.makedirs(dest, exist_ok=True)
            shutil.copy(program_path(folder, stem), dest)
            json.dump(meta[stem], open(os.path.join(dest, stem + ".json"), "w"), indent=1)
    stems = [s for s in stems if s not in crashed and s not in hung]
    counts["D3DDisassemble crashed"] = len(crashed)
    counts["D3DDisassemble hung"] = len(hung)
    made = time.time()
    diffs = compare(folder, stems)
    kinds = {}
    for stem, d in diffs.items():
        k = keep(os.path.join(args.out, "findings"), folder, stem, d, meta[stem])
        kinds[k] = kinds.get(k, 0) + 1
    summary = {"mode": args.mode, "edits": args.kinds if args.mode == "edit" and args.kinds != EDIT_KINDS else [],
               "seed": args.seed, "cases": args.cases, **counts, "programs": len(stems),
               "differing": len(diffs), "kinds": kinds, "made_s": round(made - start, 1),
               "compared_s": round(time.time() - made, 1)}
    open(os.path.join(args.out, "summary.jsonl"), "a").write(json.dumps(summary) + "\n")
    print(json.dumps(summary))


if __name__ == "__main__":
    main()
