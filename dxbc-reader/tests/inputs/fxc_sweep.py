"""/Zi sweep: compile HLSL corpora with fxc /Zi and /Zi /Od, list each container with D3DDisassemble under the 23 flag
words dx's fixtures use, and store programs and listings for `dx disasm --check`.

    python -I fxc_sweep.py CORPUS OUT FXC_DIR

CORPUS holds dxc/ (DirectXShaderCompiler, tools/clang/test), vkd3d/ (tests/hlsl/*.shader_test), vkd3d-proton/
(tests/shaders, targets in the file names) and dgs/ (DirectX-Graphics-Samples MiniEngine). OUT gets one folder per
build kind (zi, zod) of NAME.dxbc and NAME.dxbc[.flagNN].asm, and jobs.tsv / log.tsv, with fxc's output for each
build that fails in OUT/fail/BUILD/NAME.txt.
"""
import ctypes, glob, itertools, os, re, shlex, subprocess, sys, threading
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
    """A Shader Model 4 or 5 target for `target` (`ps_6_2` -> `ps_5_0`) and the one to try where fxc refuses it (5.1
    for a 6.x target, whose register spaces and resource indexing 5.0 lacks); None for a stage fxc has not."""
    m = re.fullmatch(r"([a-z]+)_(\d)_(\w+)", target)
    if not m or m.group(1) not in STAGES:
        return None, None
    if m.group(2) in "45":
        return target, None
    return f"{m.group(1)}_5_0", f"{m.group(1)}_5_1"


def name_of(*parts):
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", "__".join(parts))[-120:]


# (name, source, entry, target, defines, include dirs, other fxc options, None or the (name, target) to try where fxc
# refuses the target)
jobs = []
seen = set()

# dxc's tests: every distinct (input, entry, target, defines, include dirs) of the RUN lines. A RUN line compiles the
# test (%s) or a file it names (%S/Inputs/x.hlsl), with -I directories relative to the test's folder (%S), and the
# options fxc shares with dxc (matrix packing, backwards compatibility, IEEE strictness, flow control, aliasing).
SHARED = {"Zpr": "/Zpr", "Zpc": "/Zpc", "Gec": "/Gec", "Gis": "/Gis", "Gfa": "/Gfa", "Gfp": "/Gfp",
          "res-may-alias": "/res_may_alias"}
for src in sorted(glob.glob(os.path.join(corpus, "dxc", "tools", "clang", "test", "**", "*.hlsl"), recursive=True)):
    try:
        text = open(src, encoding="utf-8", errors="replace").read()
    except OSError:
        continue
    here = os.path.dirname(src)
    # a RUN line ending with a backslash goes on in the next
    runs = "\n".join(re.findall(r"^//\s*RUN:(.*)$", text, re.M))
    for line in re.sub(r"\\\s*\n", " ", runs).splitlines():
        line = line.split("|")[0]
        try:
            words = shlex.split(line)
        except ValueError:
            words = line.split()
        at = next((n for n, w in enumerate(words) if w.endswith("%dxc") or w == "dxc"), None)
        if at is None:
            continue
        options, inputs = {}, []
        words = words[at + 1 :]
        n = 0
        while n < len(words):
            w = words[n]
            m = re.fullmatch(r"[-/](T|E|D|I|Fo|Fc|Fe|Fd|Fh|Fre|Frs|Fsh|Vn|HV)(.*)", w)
            if m and (m.group(1) in ("T", "E", "D", "I") or m.group(2) == ""):
                value = m.group(2)
                if value == "" and n + 1 < len(words):
                    value = words[n + 1]
                    n += 1
                options.setdefault(m.group(1), []).append(value.strip())
            elif w == "%s" or re.fullmatch(r"%S/\S+\.hlsli?", w):
                inputs.append(w)
            elif w[:1] in "-/" and w[1:] in SHARED:
                options.setdefault("shared", []).append(SHARED[w[1:]])
            n += 1
        target, retry = sm5((options.get("T") or [""])[-1])
        if not target or len(inputs) != 1:
            continue
        source = src if inputs[0] == "%s" else os.path.normpath(inputs[0].replace("%S", here))
        if not os.path.isfile(source):
            continue
        entry = (options.get("E") or ["main"])[-1]
        defines = tuple(sorted(d.replace(" ", "") for d in options.get("D", [])))
        includes = tuple(os.path.normpath(i.replace("%S", here)) for i in options.get("I", []))
        shared = tuple(sorted(set(options.get("shared", []))))
        key = (source, entry, target, defines, includes, shared)
        if key in seen:
            continue
        seen.add(key)
        rel = os.path.relpath(source, os.path.join(corpus, "dxc"))
        parts = ("dxc", rel, entry, *defines, *(o[1:] for o in shared))
        retry = retry and (name_of(*parts[:3], retry, *parts[3:]), retry)
        jobs.append((name_of(*parts[:3], target, *parts[3:]), source, entry, target, defines, includes, shared, retry))

# vkd3d's shader tests, read as tests/shader_runner.c reads them for the Direct3D 11 runner (shader models 4.0 to 5.1):
# a section's source is its lines but those starting with % and the empty ones; a [require] section sets the shader
# model range and the compile options of the sections after it, until the next; a [header] can limit the file's
# models (test-shader-models). Each HLSL section is built once, at 5.0 where the range allows it, else at the range's
# model nearest 5.0, unless it is to fail there (fail or notimpl, alone or with arguments that hold at that model: either
# expects D3DCompile's failure). Byte-code sections (d3dbc-hex, dxbc-tpf-hex, dxbc-dxil-hex) are not HLSL. An options
# line is read as shader_runner reads it, the names in OPTIONS' order, each where the one before it ended (so
# `column-major row-major` is column-major alone), and backcompat is dropped from 5.1 up.
MODELS = ["2.0", "3.0", "4.0", "4.1", "5.0", "5.1", "6.0", "6.1", "6.2", "6.5", "6.6"]
OPTIONS = {"none": None, "row-major": "/Zpr", "column-major": "/Zpc", "backcompat": "/Gec", "ieee-strictness": "/Gis",
           "unbounded-descriptor-arrays": "/enable_unbounded_descriptor_tables"}


def runner_options(line):
    """The fxc options of a [require] section's `options:` line, matched as shader_runner.c matches them."""
    found = []
    for name, option in OPTIONS.items():
        rest = line.lstrip()
        if rest.startswith(name) and (len(rest) == len(name) or rest[len(name)] in " \t\r\n()]"):
            line = rest[len(name):]
            if option:
                found.append(option)
    return found
stage_of = {"vertex": "vs", "pixel": "ps", "compute": "cs", "geometry": "gs", "hull": "hs", "domain": "ds"}
gen = os.path.join(out, "vkd3d-src")
os.makedirs(gen, exist_ok=True)


def model(text):
    """The index in MODELS of the shader model `text` names ("5.1", "6", "4")."""
    m = re.match(r"(\d)(?:\.(\d))?", text)
    return MODELS.index(f"{m.group(1)}.{m.group(2) or 0}")


def holds(args, sm):
    """Whether qualifier arguments such as `sm<4 | sm>=6` or `sm>=4 & sm<6` hold at model `sm` (a tag never does)."""
    for conjunction in args.split("|"):
        ok = True
        for term in conjunction.split("&"):
            m = re.fullmatch(r"\s*sm(>=|<|=)(\S+)\s*", term)
            if not m:
                ok = False
                break
            at = model(m.group(2))
            ok = ok and {">=": sm >= at, "<": sm < at, "=": sm == at}[m.group(1)]
        if ok:
            return True
    return False


LOW, HIGH, FIVE = MODELS.index("4.0"), MODELS.index("5.1"), MODELS.index("5.0")
for test in sorted(glob.glob(os.path.join(corpus, "vkd3d", "tests", "hlsl", "*.shader_test"))):
    lines = open(test, encoding="utf-8", errors="replace", newline="").read().splitlines(keepends=True)
    lines = [l.replace("\r\n", "\n") for l in lines]
    base = os.path.basename(test)[: -len(".shader_test")]
    allowed = set(range(len(MODELS)))
    if lines and lines[0] == "[header]\n":
        for line in lines[1:]:
            if line.startswith("["):
                break
            m = re.match(r"test-shader-models\s*\((.*)\)", line)
            if m:
                allowed = {model(w) for w in m.group(1).split()}
    low, high, options = LOW, HIGH, []
    n = 0
    i = 0
    while i < len(lines):
        head = lines[i].strip()
        i += 1
        if head == "[require]":
            low, high, options = LOW, HIGH, []
            while i < len(lines) and not lines[i].startswith("["):
                r = lines[i].strip()
                i += 1
                m = re.match(r"shader model (>=|=|<) *(\S+)", r)
                if m:
                    at = model(m.group(2))
                    if m.group(1) == ">=":
                        low = max(low, at)
                    elif m.group(1) == "<":
                        high = min(high, at - 1)
                    else:
                        low, high = max(low, at), min(high, at)
                elif r.startswith("options:"):
                    options = runner_options(r[len("options:"):])
            continue
        h = re.fullmatch(r"\[(\w+)[ -]shader(.*)\]", head)
        if not h or h.group(1) not in stage_of:
            continue
        n += 1
        body = []
        while i < len(lines) and not lines[i].startswith("["):
            if not lines[i].startswith("%") and lines[i] != "\n":
                body.append(lines[i])
            i += 1
        candidates = [m for m in range(low, high + 1) if m in allowed]
        qualifiers = h.group(2)
        if not candidates or re.search(r"\b(d3dbc|dxbc-tpf|dxbc-dxil)-hex\b", qualifiers):
            continue
        sm = min(candidates, key=lambda m: (abs(m - FIVE), -m))
        fails = re.findall(r"\b(?:fail|notimpl)(?:\(([^)]*)\))?", qualifiers)
        if any(args == "" or holds(args, sm) for args in fails):
            continue
        stage = stage_of[h.group(1)]
        target = f"{stage}_{MODELS[sm].replace('.', '_')}"
        path = os.path.join(gen, f"{base}.{n}.hlsl")
        open(path, "w", encoding="utf-8", newline="").write("".join(body))
        used = tuple(o for o in options if o != "/Gec" or sm < MODELS.index("5.1"))
        jobs.append((name_of("vkd3d", base, str(n), target), path, "main", target, (), (), used, None))

# vkd3d-proton: the Shader Model 4 or 5 target its file name states
for src in sorted(glob.glob(os.path.join(corpus, "vkd3d-proton", "tests", "shaders", "**", "*.hlsl"), recursive=True)):
    targets = [t for t in re.findall(r"([a-z]s_[45]_[01])", os.path.basename(src))]
    if targets:
        rel = os.path.relpath(src, os.path.join(corpus, "vkd3d-proton"))
        jobs.append((name_of("proton", rel, targets[0]), src, "main", targets[0], (), (), (), None))

# MiniEngine: the stage its file name ends with
for src in sorted(glob.glob(os.path.join(corpus, "dgs", "MiniEngine", "**", "Shaders", "*.hlsl"), recursive=True)):
    m = re.search(r"(VS|PS|CS|GS|HS|DS)\.hlsl$", os.path.basename(src))
    if m:
        rel = os.path.relpath(src, os.path.join(corpus, "dgs"))
        jobs.append((name_of("mini", rel), src, "main", m.group(1).lower() + "_5_1", (), (), (), None))

# names that differ only in case (defines such as ATY=matrix and ATY=MATRIX) would share their files on Windows: the
# later ones get __2, __3, ...
folded = Counter()
for n, j in enumerate(jobs):
    for k in (0,) + ((7,) if j[7] else ()):
        name = j[k] if k == 0 else j[7][0]
        folded[name.lower()] += 1
        if folded[name.lower()] > 1:
            name = f"{name}__{folded[name.lower()]}"
        j = (name, *j[1:]) if k == 0 else (*j[:7], (name, j[7][1]))
    jobs[n] = j

with open(os.path.join(out, "jobs.tsv"), "w", newline="") as f:
    for j in jobs:
        retry = "\t".join(j[7]) if j[7] else "\t"
        f.write("\t".join([j[0], j[1], j[2], j[3], " ".join(j[4]), ";".join(j[5]), " ".join(j[6]), retry]) + "\n")
print(f"{len(jobs)} jobs", flush=True)


def build(job, kind):
    """Build `job` (at its retry target where fxc refuses its own) and list it under every flag word."""
    name, src, entry, target, defines, includes, options, retry = job
    result = compile_one(name, src, entry, target, defines, includes, options, kind)
    if result[2] == "fxc-fail" and retry:
        again = compile_one(retry[0], src, entry, retry[1], defines, includes, options, kind, name)
        if again[2] != "fxc-fail":
            os.remove(os.path.join(out, "fail", kind, name + ".txt"))
            return again
    return result


def compile_one(name, src, entry, target, defines, includes, options, kind, log=None):
    """fxc's build of one target; where it fails, a line naming the target and how fxc ended (its exit code, or a
    timeout) and fxc's output go to fail/KIND/LOG.txt (LOG: the name)."""
    folder = os.path.join(out, kind)
    obj = os.path.join(folder, name + ".dxbc")
    if os.path.exists(obj):
        return (name, kind, "cached")
    here = os.path.dirname(src)
    args = [fxc, "/nologo", "/T", target, "/E", entry, *BUILDS[kind], *options, "/I", here]
    for inc in includes:
        args += ["/I", inc]
    if target.endswith("_5_1") and "/enable_unbounded_descriptor_tables" not in options:
        args.append("/enable_unbounded_descriptor_tables")
    # fxc takes `/D NAME=` as wanting the next argument for its value; `NAME= ` defines it empty, as clang's -DNAME=
    for d in defines:
        args += ["/D", d + " " if d.endswith("=") else d]
    args += ["/Fo", obj, src]
    try:
        r = subprocess.run(args, capture_output=True, timeout=120, cwd=here)
        ended, output = f"exit {r.returncode & 0xFFFFFFFF:#x}", r.stdout + r.stderr
    except subprocess.TimeoutExpired as e:
        r, ended, output = None, "timeout 120 s", (e.stdout or b"") + (e.stderr or b"")
    if r is None or r.returncode != 0:
        if os.path.exists(obj):
            os.remove(obj)
        os.makedirs(os.path.join(out, "fail", kind), exist_ok=True)
        with open(os.path.join(out, "fail", kind, (log or name) + ".txt"), "ab") as f:
            f.write(f"fxc /T {target}: {ended}\n".encode() + output)
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
