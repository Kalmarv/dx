"""/Zi sweep: compile HLSL corpora with fxc /Zi and /Zi /Od, list each container with D3DDisassemble under the 23 flag
words dx's fixtures use, and store programs and listings for `dx disasm --check`.

    python -I fxc_sweep.py CORPUS OUT FXC_DIR

CORPUS holds dxc/ (DirectXShaderCompiler, tools/clang/test), vkd3d/ (tests/hlsl/*.shader_test), vkd3d-proton/
(tests/shaders, targets in the file names) and dgs/ (DirectX-Graphics-Samples MiniEngine). OUT gets one folder per
build kind (zi, zod) of NAME.dxbc and NAME.dxbc[.flagNN].asm, and jobs.tsv / log.tsv.
"""
import ctypes, glob, itertools, os, re, subprocess, sys, threading
from collections import Counter
from concurrent.futures import ThreadPoolExecutor

LOCK = threading.Lock()  # D3DDisassemble is called from one thread at a time

TEXT = [0x2, 0x4, 0x10, 0x20, 0x40, 0x80]
FLAGS = sorted({0, *TEXT, *(a | b for a, b in itertools.combinations(TEXT, 2)), sum(TEXT)})
BUILDS = {"zi": ["/Zi"], "zod": ["/Zi", "/Od"]}
STAGES = {"vs", "ps", "cs", "gs", "hs", "ds"}

corpus, out, fxc_dir = sys.argv[1:4]
fxc = os.path.join(fxc_dir, "fxc.exe")
dll = ctypes.WinDLL(os.path.join(fxc_dir, "d3dcompiler_47.dll"))
fn = dll.D3DDisassemble
fn.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_uint, ctypes.c_char_p, ctypes.POINTER(ctypes.c_void_p)]
fn.restype = ctypes.c_long


def disasm(data, flags):
    with LOCK:
        return disasm_locked(data, flags)


def disasm_locked(data, flags):
    o = ctypes.c_void_p()
    b = ctypes.create_string_buffer(data, len(data))
    if fn(b, len(data), flags, None, ctypes.byref(o)):
        return None
    vt = ctypes.cast(o, ctypes.POINTER(ctypes.POINTER(ctypes.c_void_p))).contents
    p = ctypes.WINFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p)(vt[3])(o)
    n = ctypes.WINFUNCTYPE(ctypes.c_size_t, ctypes.c_void_p)(vt[4])(o)
    t = ctypes.string_at(p, n)
    ctypes.WINFUNCTYPE(ctypes.c_ulong, ctypes.c_void_p)(vt[2])(o)
    return t.rstrip(b"\0")


def sm5(target):
    """A Shader Model 4 or 5 target for `target` (`ps_6_2` -> `ps_5_0`); None for a stage fxc has not."""
    m = re.fullmatch(r"([a-z]+)_(\d)_(\w+)", target)
    if not m or m.group(1) not in STAGES:
        return None
    if m.group(2) in "45":
        return target
    return f"{m.group(1)}_5_0"


jobs = []  # (name, source, entry, target, defines, include dir)


def name_of(*parts):
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", "__".join(parts))[-120:]


# dxc's tests: every distinct (entry, target, defines) of the RUN lines
for src in sorted(glob.glob(os.path.join(corpus, "dxc", "tools", "clang", "test", "**", "*.hlsl"), recursive=True)):
    try:
        text = open(src, encoding="utf-8", errors="replace").read()
    except OSError:
        continue
    seen = set()
    for line in re.findall(r"^//\s*RUN:(.*)$", text, re.M):
        if "dxc" not in line and "%dxc" not in line:
            continue
        line = line.split("|")[0]
        t = re.search(r"[-/]T\s*([a-z]+_\d_\w+)", line)
        if not t:
            continue
        target = sm5(t.group(1))
        if not target:
            continue
        e = re.search(r"[-/]E\s*(\w+)", line)
        entry = e.group(1) if e else "main"
        defines = tuple(sorted(re.findall(r"[-/]D\s*(\w+(?:=[^\s]+)?)", line)))
        key = (entry, target, defines)
        if key in seen:
            continue
        seen.add(key)
        rel = os.path.relpath(src, os.path.join(corpus, "dxc"))
        jobs.append((name_of("dxc", rel, entry, target, *defines), src, entry, target, defines, os.path.dirname(src)))

# vkd3d's shader tests: each shader section that is not expected to fail
stage_of = {"vertex": "vs", "pixel": "ps", "compute": "cs", "geometry": "gs", "hull": "hs", "domain": "ds"}
gen = os.path.join(out, "vkd3d-src")
os.makedirs(gen, exist_ok=True)
for test in sorted(glob.glob(os.path.join(corpus, "vkd3d", "tests", "hlsl", "*.shader_test"))):
    lines = open(test, encoding="utf-8", errors="replace").read().splitlines()
    sm6_only = False
    n = 0
    i = 0
    while i < len(lines):
        h = re.fullmatch(r"\[(\w+)[ -]shader(.*)\]", lines[i].strip())
        if lines[i].strip() == "[require]":
            j = i + 1
            sm6_only = False
            while j < len(lines) and not lines[j].startswith("["):
                if re.search(r"shader model >= 6", lines[j]):
                    sm6_only = True
                j += 1
        if h and h.group(1) in stage_of and "fail" not in h.group(2) and not sm6_only:
            j = i + 1
            body = []
            while j < len(lines) and not lines[j].startswith("["):
                body.append(lines[j])
                j += 1
            n += 1
            base = os.path.basename(test)[: -len(".shader_test")]
            path = os.path.join(gen, f"{base}.{n}.hlsl")
            open(path, "w", newline="").write("\n".join(body) + "\n")
            stage = stage_of[h.group(1)]
            jobs.append((name_of("vkd3d", base, str(n), stage), path, "main", f"{stage}_5_0", (), gen))
            i = j
            continue
        i += 1

# vkd3d-proton: the Shader Model 4 or 5 target its file name states
for src in sorted(glob.glob(os.path.join(corpus, "vkd3d-proton", "tests", "shaders", "**", "*.hlsl"), recursive=True)):
    targets = [t for t in re.findall(r"([a-z]s_[45]_[01])", os.path.basename(src))]
    if targets:
        rel = os.path.relpath(src, os.path.join(corpus, "vkd3d-proton"))
        jobs.append((name_of("proton", rel, targets[0]), src, "main", targets[0], (), os.path.dirname(src)))

# MiniEngine: the stage its file name ends with
for src in sorted(glob.glob(os.path.join(corpus, "dgs", "MiniEngine", "**", "Shaders", "*.hlsl"), recursive=True)):
    m = re.search(r"(VS|PS|CS|GS|HS|DS)\.hlsl$", os.path.basename(src))
    if m:
        rel = os.path.relpath(src, os.path.join(corpus, "dgs"))
        jobs.append((name_of("mini", rel), src, "main", m.group(1).lower() + "_5_1", (), os.path.dirname(src)))

with open(os.path.join(out, "jobs.tsv"), "w", newline="") as f:
    for j in jobs:
        f.write("\t".join([j[0], j[1], j[2], j[3], " ".join(j[4])]) + "\n")
print(f"{len(jobs)} jobs", flush=True)


def build(job, kind):
    name, src, entry, target, defines, inc = job
    folder = os.path.join(out, kind)
    obj = os.path.join(folder, name + ".dxbc")
    if os.path.exists(obj):
        return (name, kind, "cached")
    args = [fxc, "/nologo", "/T", target, "/E", entry, *BUILDS[kind], "/I", inc]
    if target.endswith("_5_1"):
        args.append("/enable_unbounded_descriptor_tables")
    for d in defines:
        args += ["/D", d]
    args += ["/Fo", obj, src]
    try:
        r = subprocess.run(args, capture_output=True, timeout=120, cwd=inc)
    except subprocess.TimeoutExpired:
        return (name, kind, "timeout")
    if r.returncode != 0:
        if os.path.exists(obj):
            os.remove(obj)
        return (name, kind, "fxc-fail")
    data = open(obj, "rb").read()
    for flags in FLAGS:
        text = disasm(data, flags)
        if text is None:
            continue
        open(obj + (".asm" if flags == 0 else f".flag{flags:02x}.asm"), "wb").write(text)
    return (name, kind, "ok")


for kind in BUILDS:
    os.makedirs(os.path.join(out, kind), exist_ok=True)
results = []
with ThreadPoolExecutor(8) as pool:
    for r in pool.map(lambda jk: build(*jk), [(j, k) for j in jobs for k in BUILDS]):
        results.append(r)
        if len(results) % 500 == 0:
            print(len(results), flush=True)
with open(os.path.join(out, "log.tsv"), "w", newline="") as f:
    for r in results:
        f.write("\t".join(r) + "\n")
print(Counter((k, s) for _, k, s in results))
