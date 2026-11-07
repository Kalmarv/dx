"""Random HLSL programs for the differential against D3DDisassemble: typed expressions over a program's inputs, a
constant buffer and resources, with statements (branches, loops, switches, indexed arrays, atomics), for Direct3D 9
(SM 1 to 3), feature level 9, and Shader Models 4 and 5 targets. Each program is well typed by construction;
what fxc still refuses (an instruction limit, an unrolled loop) is counted by the caller and dropped."""
import struct

# (target, stage, family): family d3d9 (SM 1 to 3), l9 (4_0_level_9_x), 4, 41, 5, 51
PROFILES = [
    ("vs_1_1", "vs", "d3d9"), ("vs_2_0", "vs", "d3d9"), ("vs_2_a", "vs", "d3d9"), ("vs_3_0", "vs", "d3d9"),
    ("ps_2_0", "ps", "d3d9"), ("ps_2_a", "ps", "d3d9"), ("ps_2_b", "ps", "d3d9"), ("ps_3_0", "ps", "d3d9"),
    ("vs_4_0_level_9_1", "vs", "l9"), ("vs_4_0_level_9_3", "vs", "l9"),
    ("ps_4_0_level_9_1", "ps", "l9"), ("ps_4_0_level_9_3", "ps", "l9"),
    ("vs_4_0", "vs", "4"), ("ps_4_0", "ps", "4"), ("vs_4_1", "vs", "41"), ("ps_4_1", "ps", "41"),
    ("vs_5_0", "vs", "5"), ("ps_5_0", "ps", "5"), ("cs_5_0", "cs", "5"),
    ("vs_5_1", "vs", "51"), ("ps_5_1", "ps", "51"), ("cs_5_1", "cs", "51"),
]

# D3DCOMPILE_* flags words the compiles draw from
COMPILE_FLAGS = {
    "debug": 1 << 0, "skip_optimization": 1 << 2, "row_major": 1 << 3, "partial_precision": 1 << 5,
    "avoid_flow": 1 << 9, "prefer_flow": 1 << 10, "ieee": 1 << 13, "o0": 1 << 14, "o2": (1 << 14) | (1 << 15),
    "o3": 1 << 15, "all_bound": 1 << 21,
}

FLOATS = ["0.0", "-0.0", "1.0", "-1.0", "0.5", "2.0", "3.14159", "1e-7", "1e-38", "3.4e38", "-3.4e38", "65504.0",
          "0.333333", "1e10", "-7.25", "100.0", "0.1"]
# bit patterns written as asfloat(): infinities, quiet and signaling NaNs, denormals, the largest finite
FLOAT_BITS = [0x7F800000, 0xFF800000, 0x7FC00000, 0xFFC00000, 0x7FA00000, 0x7F800001, 0xFFBFFFFF, 0x00000001,
              0x807FFFFF, 0x7F7FFFFF, 0x80000000, 0x3F800001]
INTS = ["0", "1", "-1", "2", "7", "31", "32", "255", "-128", "65535", "0x7fffffff", "-2147483647", "0x10000", "12345"]
UINTS = ["0u", "1u", "2u", "31u", "0xffffffffu", "0x80000000u", "0x55555555u", "65536u", "1000u"]
DOUBLE_BITS = [0x7FF0000000000000, 0xFFF0000000000000, 0x7FF8000000000000, 0x7FF4000000000000,
               0x0000000000000001, 0x8000000000000000, 0x7FEFFFFFFFFFFFFF, 0x3FF0000000000001]


class Gen:
    def __init__(self, rng, target, stage, family):
        self.r, self.target, self.stage, self.family = rng, target, stage, family
        self.sm = {"d3d9": 3 if target.endswith("3_0") else 2, "l9": 2, "4": 4, "41": 4.1, "5": 5, "51": 5.1}[family]
        self.d3d9 = family == "d3d9"
        self.legacy = family in ("d3d9", "l9")
        self.vars = []  # (name, base, n)
        self.readonly = set()  # the constant buffer's members
        self.n = 0
        self.globals_ = []
        self.cb = []
        self.textures = []  # (name, kind) kind 2d/2darray/cube/3d
        self.buffers = []  # (name, kind, base, n)
        self.uavs = []  # (name, kind)
        self.arrays = []  # (name, base, n, length)
        self.loop_depth = 0
        self.statements_left = 0
        self.bases = ["float"] * 6 + ([] if self.legacy else ["int"] * 2 + ["uint"] * 2 + ["bool"])
        if self.sm >= 5 and self.r.random() < 0.3:
            self.bases += ["double"]
        if not self.d3d9 and self.r.random() < 0.15:
            self.bases += ["min16float"]

    def fresh(self, prefix="v"):
        self.n += 1
        return f"{prefix}{self.n}"

    def ty(self, base, n):
        return base if n == 1 else f"{base}{n}"

    # ---- leaves
    def literal(self, base, n):
        r = self.r
        def one():
            if base in ("float", "min16float"):
                if not self.legacy and r.random() < 0.15:
                    return f"asfloat({r.choice(FLOAT_BITS):#x}u)"
                return r.choice(FLOATS)
            if base == "int":
                return r.choice(INTS)
            if base == "uint":
                return r.choice(UINTS)
            if base == "bool":
                return r.choice(["true", "false"])
            if base == "double":
                if r.random() < 0.3:
                    bits = r.choice(DOUBLE_BITS)
                    return f"asdouble({bits & 0xFFFFFFFF:#x}u, {bits >> 32:#x}u)"
                return r.choice(["0.0L", "1.0L", "-2.5L", "1e-300L", "1e300L", "0.1L", "3.0L"])
        if n == 1:
            return one()
        return f"{self.ty(base, n)}({', '.join(one() for _ in range(n))})"

    def leaf(self, base, n):
        r = self.r
        pool = [v for v in self.vars if v[1] == base and v[2] >= n]
        if pool and r.random() < 0.75:
            name, _, m = r.choice(pool)
            if m == n and r.random() < 0.6:
                return name
            comps = "xyzw"[:m] if r.random() < 0.5 else "rgba"[:m]
            return f"{name}.{''.join(r.choice(comps) for _ in range(n))}"
        return self.literal(base, n)

    # ---- expressions
    def expr(self, base, n, d):
        r = self.r
        if d <= 0 or r.random() < 0.2:
            return self.leaf(base, n)
        choices = [self.binary, self.binary, self.unary, self.intrinsic, self.intrinsic, self.cast, self.ternary,
                   self.construct]
        if base in ("float", "min16float") and n <= 4:
            choices += [self.texture_read, self.texture_read]
        if not self.legacy and base in ("float", "uint", "int") and self.buffers:
            choices += [self.buffer_read]
        if self.arrays and any(a[1] == base and a[2] == n for a in self.arrays):
            choices += [self.array_read]
        return r.choice(choices)(base, n, d - 1)

    def index(self, length, d):
        """An integer index below `length`, from a computed value where the target allows it."""
        if self.legacy or self.r.random() < 0.3:
            return str(self.r.randrange(length))
        return f"(({self.expr('uint', 1, d)}) % {length}u)"

    def binary(self, base, n, d):
        r = self.r
        if base == "bool":
            if r.random() < 0.5 and not self.legacy:
                op = r.choice(["&&", "||"])
                return f"({self.expr('bool', n, d)} {op} {self.expr('bool', n, d)})"
            b = r.choice([x for x in self.bases if x != "bool"])
            op = r.choice(["<", "<=", ">", ">=", "==", "!="])
            return f"({self.expr(b, n, d)} {op} {self.expr(b, n, d)})"
        ops = ["+", "-", "*"]
        if base in ("float", "min16float"):
            ops += ["/"] + ([] if self.d3d9 else ["%"])
        if base in ("int", "uint"):
            ops += ["/", "%", "&", "|", "^", "<<", ">>"]
        if base == "double":
            ops += ["/"] if self.r.random() < 0.3 else []
        op = r.choice(ops)
        a, b = self.expr(base, n, d), self.expr(base, n, d)
        if op in ("/", "%") and base in ("int", "uint"):
            b = f"(({b}) | 1)"
        return f"({a} {op} {b})"

    def unary(self, base, n, d):
        if base == "bool":
            return f"(!{self.expr('bool', n, d)})"
        if base == "uint" or (base == "int" and self.r.random() < 0.4):
            return f"(~{self.expr(base, n, d)})"
        return f"(-{self.expr(base, n, d)})"

    def intrinsic(self, base, n, d):
        r = self.r
        e = lambda b=base, m=n: self.expr(b, m, d)
        if base in ("float", "min16float"):
            one = ["abs", "saturate", "frac", "floor", "ceil", "sqrt", "rsqrt", "exp2", "log2", "sin", "cos",
                   "sign", "exp", "log", "round", "trunc", "radians", "degrees", "tan", "asin", "acos", "atan"]
            if self.stage == "ps" and (not self.d3d9 or self.target in ("ps_2_a", "ps_3_0")):
                one += ["ddx", "ddy", "fwidth"] + (["ddx_fine", "ddy_coarse"] if self.sm >= 5 else [])
            if self.sm >= 5 and base == "float":
                one += ["rcp"]
            pick = r.randrange(9)
            if pick < 4:
                f = r.choice(one)
                if f == "sign":
                    return f"(({base}{'' if n == 1 else n})sign({e()}))"
                return f"{f}({e()})"
            if pick == 4:
                return f"{r.choice(['min', 'max', 'pow', 'atan2', 'step', 'fmod'])}({e()}, {e()})"
            if pick == 5:
                return f"{r.choice(['lerp', 'clamp', 'smoothstep', 'mad'])}({e()}, {e()}, {e()})"
            if pick == 6 and n == 1:
                m = r.randint(1, 4)
                return f"{r.choice(['dot', 'distance'])}({e(base, m)}, {e(base, m)})" if r.random() < 0.7 \
                    else f"length({e(base, m)})"
            if pick == 7 and n == 3:
                return f"cross({e()}, {e()})" if r.random() < 0.5 else f"normalize({e()})"
            if pick == 8 and not self.legacy and base == "float":
                if self.sm >= 5 and r.random() < 0.5:
                    return f"f16tof32({e('uint', n)})"
                return f"asfloat({e(r.choice(['uint', 'int']), n)})"
            return f"abs({e()})"
        if base in ("int", "uint"):
            pick = r.randrange(6)
            if pick == 0:
                return f"{r.choice(['min', 'max'])}({e()}, {e()})"
            if pick == 1:
                return f"clamp({e()}, {e()}, {e()})"
            if pick == 2 and self.sm >= 5:
                f = r.choice(["countbits", "reversebits", "firstbithigh", "firstbitlow"])
                return f"(({self.ty(base, n)}){f}({e('uint', n)}))"
            if pick == 3:
                return f"as{base}({e('float', n)})"
            if pick == 4 and base == "int":
                return f"abs({e()})"
            if pick == 5 and self.sm >= 5 and base == "uint":
                return f"f32tof16({e('float', n)})"
            return f"(({self.ty(base, n)}){e('float', n)})"
        if base == "bool":
            if n == 1:
                return f"{r.choice(['any', 'all'])}({e(r.choice(self.bases), r.randint(1, 4))})"
            return f"isnan({e('float', n)})" if r.random() < 0.5 else f"isinf({e('float', n)})"
        if base == "double":
            pick = r.randrange(3)
            if pick == 0:
                return f"{r.choice(['min', 'max'])}({e()}, {e()})"
            if pick == 1:
                return f"fma({e()}, {e()}, {e()})"
            return f"abs({e()})"
        return self.leaf(base, n)

    def cast(self, base, n, d):
        other = self.r.choice([b for b in self.bases if b != base] or [base])
        return f"(({self.ty(base, n)}){self.expr(other, n, d)})"

    def ternary(self, base, n, d):
        c = self.expr("bool", 1 if self.legacy or self.r.random() < 0.6 else n, d)
        return f"({c} ? {self.expr(base, n, d)} : {self.expr(base, n, d)})"

    def construct(self, base, n, d):
        if n == 1:
            return self.expr(base, 1, d)
        parts, left = [], n
        while left:
            k = self.r.randint(1, left)
            parts.append(self.expr(base, k, d))
            left -= k
        return f"{self.ty(base, n)}({', '.join(parts)})"

    def texture_read(self, base, n, d):
        r = self.r
        sw = "xyzw"[:n]
        if self.d3d9:
            if not self.textures:
                return self.leaf(base, n)
            name, kind = r.choice(self.textures)
            fn, m = {"2d": ("tex2D", 2), "cube": ("texCUBE", 3), "3d": ("tex3D", 3)}[kind]
            if self.stage == "vs" or (self.sm >= 3 and r.random() < 0.3):
                if self.sm < 3:
                    return self.leaf(base, n)
                return f"(({self.ty(base, 4)}){fn}lod({name}, float4({self.expr('float', m, d)}, 0, {self.expr('float', 1, d)}))).{sw}"
            if r.random() < 0.3:
                return f"(({self.ty(base, 4)}){fn}proj({name}, {self.expr('float', 4, d)})).{sw}"
            if r.random() < 0.2:
                return f"(({self.ty(base, 4)}){fn}bias({name}, {self.expr('float', 4, d)})).{sw}"
            return f"(({self.ty(base, 4)}){fn}({name}, {self.expr('float', m, d)})).{sw}"
        if not self.textures:
            return self.leaf(base, n)
        name, kind = r.choice(self.textures)
        m = {"2d": 2, "2darray": 3, "cube": 3, "3d": 3}[kind]
        s = "s0"
        pick = r.randrange(8)
        lod_ok = not (self.family == "l9" and self.stage == "vs")
        if self.stage == "ps" and pick < 3:
            call = f"{name}.Sample({s}, {self.expr('float', m, d)})"
        elif pick < 4 and self.stage == "ps":
            call = f"{name}.SampleBias({s}, {self.expr('float', m, d)}, {self.expr('float', 1, d)})"
        elif pick < 5 and not self.legacy and kind != "cube" and kind != "3d":
            # an offset is a literal
            off = ", ".join(str(r.randint(-8, 7)) for _ in range(2))
            call = f"{name}.SampleLevel({s}, {self.expr('float', m, d)}, {self.expr('float', 1, d)}, int2({off}))"
        elif pick < 6 and not self.legacy and kind != "cube":
            coords = m + 1
            call = f"{name}.Load({self.expr('int', coords, d)})"
        elif pick < 7 and self.sm >= 4.1 and kind in ("2d", "2darray", "cube"):
            g = r.choice(["Gather"] + (["GatherRed", "GatherGreen", "GatherAlpha"] if self.sm >= 5 else []))
            call = f"{name}.{g}({s}, {self.expr('float', m, d)})"
        elif pick < 8 and not self.legacy and kind == "2d" and self.r.random() < 0.5:
            call = f"{name}.SampleCmpLevelZero(sc, {self.expr('float', 2, d)}, {self.expr('float', 1, d)}).xxxx"
        elif lod_ok:
            call = f"{name}.SampleLevel({s}, {self.expr('float', m, d)}, {self.expr('float', 1, d)})"
        else:
            return self.leaf(base, n)
        return f"(({self.ty(base, 4)}){call}).{sw}"

    def buffer_read(self, base, n, d):
        r = self.r
        name, kind, b, m = r.choice(self.buffers)
        sw = "xyzw"[:n] if m >= n else ("x" * n)
        i = self.expr("uint", 1, d)
        if kind == "buffer":
            v = f"{name}[{i}]" if r.random() < 0.6 else f"{name}.Load({i})"
        elif kind == "structured":
            v = f"{name}[{i}].{r.choice(['a', 'b'])}"
            b, m = "float", 4
            sw = "xyzw"[:n]
        else:
            v = f"{name}.Load{'' if m == 1 else m}(({i}) & ~3u)"
            b = "uint"
        return f"(({self.ty(base, n)})({v}).{sw})" if m > 1 or kind == "structured" else f"(({self.ty(base, n)}){v})"

    def array_read(self, base, n, d):
        name, _, _, length = self.r.choice([a for a in self.arrays if a[1] == base and a[2] == n])
        return f"{name}[{self.index(length, d)}]"

    # ---- statements
    def statement(self, out, indent, d):
        r = self.r
        self.statements_left -= 1
        pad = "    " * indent
        pick = r.randrange(12)
        if pick < 4 or self.statements_left <= 0:
            base, n = r.choice(self.bases), r.randint(1, 4)
            name = self.fresh()
            out.append(f"{pad}{'precise ' if r.random() < 0.05 and not self.d3d9 else ''}{self.ty(base, n)} {name} = {self.expr(base, n, d)};")
            self.vars.append((name, base, n))
            return
        if pick < 6:
            pool = [v for v in self.vars if v[0] not in self.readonly]
            if pool:
                name, base, n = r.choice(pool)
                ops = ["=", "+=", "*="] + (["|=", "^=", "&="] if base in ("int", "uint") else [])
                op = r.choice(ops) if base != "bool" else "="
                lhs = name
                if n > 1 and r.random() < 0.4:
                    comps = r.sample("xyzw"[:n], r.randint(1, n))
                    lhs, n = f"{name}.{''.join(comps)}", len(comps)
                out.append(f"{pad}{lhs} {op} {self.expr(base, n, d)};")
            return
        if pick < 8:
            attr = r.choice(["", "[branch] ", "[flatten] "]) if not self.d3d9 or self.sm >= 3 else ""
            out.append(f"{pad}{attr}if ({self.expr('bool', 1, d)}) {{")
            self.block(out, indent + 1, d, r.randint(1, 3))
            if r.random() < 0.5:
                out.append(f"{pad}}} else {{")
                self.block(out, indent + 1, d, r.randint(1, 3))
            out.append(f"{pad}}}")
            return
        if pick < 9 and self.loop_depth < 2:
            i = self.fresh("i")
            count = r.randint(1, 8)
            attr = r.choice(["", "[loop] ", "[unroll] ", f"[unroll({r.randint(1, 4)})] "]) if not self.legacy else "[unroll] "
            ity = "int" if not self.legacy else "float"
            out.append(f"{pad}{attr}for ({ity} {i} = 0; {i} < {count}; {i}++) {{")
            self.loop_depth += 1
            self.vars.append((i, ity, 1))
            self.block(out, indent + 1, d, r.randint(1, 3))
            if not self.legacy and r.random() < 0.3:
                out.append(f"{pad}    if ({self.expr('bool', 1, d)}) {r.choice(['break', 'continue'])};")
            self.vars.remove((i, ity, 1))
            self.loop_depth -= 1
            out.append(f"{pad}}}")
            return
        if pick < 10 and not self.legacy:
            attr = r.choice(["", "[branch] ", "[flatten] ", "[forcecase] ", "[call] "])
            out.append(f"{pad}{attr}switch ({self.expr('int', 1, d)}) {{")
            for c in sorted(r.sample(range(-2, 9), r.randint(1, 4))):
                out.append(f"{pad}case {c}:")
                self.block(out, indent + 1, d, r.randint(1, 2))
                if r.random() < 0.8:
                    out.append(f"{pad}    break;")
            out.append(f"{pad}default:")
            self.block(out, indent + 1, d, 1)
            out.append(f"{pad}    break;")
            out.append(f"{pad}}}")
            return
        if pick < 11 and (not self.legacy or self.sm >= 3):
            base, n = r.choice([b for b in self.bases if b != "bool"]), r.randint(1, 4)
            length = r.randint(2, 6)
            name = self.fresh("a")
            init = ", ".join(self.expr(base, n, d - 1) for _ in range(length))
            out.append(f"{pad}{self.ty(base, n)} {name}[{length}] = {{ {init} }};")
            out.append(f"{pad}{name}[{self.index(length, d)}] = {self.expr(base, n, d)};")
            self.arrays.append((name, base, n, length))
            return
        if self.stage == "ps" and r.random() < 0.5:
            out.append(f"{pad}{r.choice(['clip(' + self.expr('float', r.randint(1, 4), d) + ');', 'if (' + self.expr('bool', 1, d) + ') discard;'])}")
            return
        if self.uavs and self.sm >= 5:
            name, kind = r.choice(self.uavs)
            if kind == "rwbuffer":
                out.append(f"{pad}InterlockedAdd({name}[{self.expr('uint', 1, d)} % 64u], {self.expr('uint', 1, d)});")
            elif kind == "rwbab":
                op = r.choice(["InterlockedMax", "InterlockedOr", "InterlockedXor", "InterlockedMin"])
                out.append(f"{pad}{name}.{op}(({self.expr('uint', 1, d)}) & ~3u, {self.expr('uint', 1, d)});")
            else:
                out.append(f"{pad}{name}[uint2({self.expr('uint', 2, d)})] = {self.expr('float', 4, d)};")
            return
        if self.stage == "cs":
            out.append(f"{pad}gs[{self.expr('uint', 1, d)} % 64u] = {self.expr('uint', 1, d)};")
            out.append(f"{pad}GroupMemoryBarrierWithGroupSync();")
            self.vars.append((f"gs[{r.randrange(64)}]", "uint", 1))
            return

    def block(self, out, indent, d, count):
        """Statements in a scope: what they declare is not seen after it."""
        names, arrays = len(self.vars), len(self.arrays)
        for _ in range(count):
            if self.statements_left <= 0:
                break
            self.statement(out, indent, d)
        del self.vars[names:], self.arrays[arrays:]

    # ---- the program
    def declarations(self):
        r, out = self.r, []
        # a constant buffer of mixed members
        members = []
        for _ in range(r.randint(1, 6)):
            base = r.choice([b for b in self.bases if b not in ("min16float",)] if not self.legacy else ["float"])
            n = r.randint(1, 4)
            name = self.fresh("c")
            if r.random() < 0.2 and base == "float":
                rows = r.randint(2, 4)
                members.append(f"    {'row_major ' if r.random() < 0.3 else ''}float{rows}x{n} {name};")
                self.vars.append((f"{name}[{r.randrange(rows)}]", "float", n))
                self.readonly.add(self.vars[-1][0])
                continue
            if r.random() < 0.15 and not self.d3d9:
                length = r.randint(2, 4)
                members.append(f"    {self.ty(base, n)} {name}[{length}];")
                self.vars.append((f"{name}[{r.randrange(length)}]", base, n))
                self.readonly.add(self.vars[-1][0])
                continue
            members.append(f"    {self.ty(base, n)} {name};")
            self.vars.append((name, base, n))
            self.readonly.add(name)
        if self.d3d9:
            out += [m.strip() for m in members]
        else:
            out.append("cbuffer Constants : register(b0)\n{")
            out += members
            out.append("};")
        # textures
        for i in range(r.randint(0, 3)):
            kind = r.choice(["2d", "2d", "cube", "3d"] + ([] if self.legacy else ["2darray"]))
            if self.d3d9:
                name = f"s{i}"
                out.append(f"sampler{ {'2d': '2D', 'cube': 'CUBE', '3d': '3D'}[kind]} {name} : register(s{i});")
            else:
                name = f"t{i}"
                tex = {"2d": "Texture2D", "cube": "TextureCube", "3d": "Texture3D", "2darray": "Texture2DArray"}[kind]
                out.append(f"{tex}<float4> {name} : register(t{i});")
            self.textures.append((name, kind))
        if not self.d3d9:
            out.append("SamplerState s0 : register(s0);")
            if not self.legacy:
                out.append("SamplerComparisonState sc : register(s1);")
        if not self.legacy:
            for i in range(r.randint(0, 2)):
                kind = r.choice(["buffer"] + (["structured", "bab"] if self.sm >= 5 else []))
                name = f"b{i}"
                slot = 4 + i
                if kind == "buffer":
                    b, n = r.choice(["float", "uint", "int"]), r.choice([1, 2, 4])
                    out.append(f"Buffer<{self.ty(b, n)}> {name} : register(t{slot});")
                elif kind == "structured":
                    out.append(f"struct S{i} {{ float4 a; float4 b; }};")
                    out.append(f"StructuredBuffer<S{i}> {name} : register(t{slot});")
                    b, n = "float", 4
                else:
                    out.append(f"ByteAddressBuffer {name} : register(t{slot});")
                    b, n = "uint", r.choice([1, 2, 4])
                self.buffers.append((name, kind, b, n))
        if self.sm >= 5 and self.stage in ("ps", "cs"):
            for i in range(r.randint(0, 2)):
                kind = r.choice(["rwbuffer", "rwbab", "rwtex"])
                name = f"u{i + 1}"
                decl = {"rwbuffer": "RWBuffer<uint>", "rwbab": "RWByteAddressBuffer", "rwtex": "RWTexture2D<float4>"}[kind]
                out.append(f"{decl} {name} : register(u{i + 1});")
                self.uavs.append((name, kind))
        if self.stage == "cs":
            out.append("groupshared uint gs[64];")
        return out

    def program(self, statements):
        r = self.r
        self.statements_left = statements
        head = self.declarations()
        if self.stage == "cs":
            out = [f"RWBuffer<float4> u0 : register(u0);",
                   f"[numthreads({r.choice([1, 8, 64])}, {r.choice([1, 2])}, 1)]",
                   "void main(uint3 in_id : SV_DispatchThreadID, uint in_gi : SV_GroupIndex)", "{"]
            self.vars += [("in_id", "uint", 3), ("in_gi", "uint", 1)]
            result = "u0[in_id.x] = {};"
        elif self.stage == "ps":
            sv = "VPOS" if self.d3d9 else "SV_Position"
            if self.d3d9:
                params = "float4 in_a : TEXCOORD0, float4 in_b : TEXCOORD1" + (", float2 in_p : VPOS" if self.sm >= 3 else "")
                self.vars += [("in_a", "float", 4), ("in_b", "float", 4)] + ([("in_p", "float", 2)] if self.sm >= 3 else [])
                out = [f"float4 main({params}) : COLOR", "{"]
            else:
                ints = "" if self.legacy else ", nointerpolation uint4 in_u : TEXCOORD2, nointerpolation int2 in_i : TEXCOORD3"
                mode = r.choice(["", "linear ", "centroid ", "noperspective "]) if not self.legacy else ""
                out = [f"float4 main(float4 in_p : {sv}, {mode}float4 in_a : TEXCOORD0, float3 in_b : TEXCOORD1{ints}) : SV_Target", "{"]
                self.vars += [("in_p", "float", 4), ("in_a", "float", 4), ("in_b", "float", 3)]
                if not self.legacy:
                    self.vars += [("in_u", "uint", 4), ("in_i", "int", 2)]
            result = "return {};"
        else:
            if self.d3d9:
                out = ["float4 main(float4 in_a : POSITION, float4 in_b : TEXCOORD0) : POSITION", "{"]
                self.vars += [("in_a", "float", 4), ("in_b", "float", 4)]
            else:
                ints = "" if self.legacy else ", uint in_v : SV_VertexID, int4 in_i : BLENDINDICES"
                out = [f"float4 main(float4 in_a : POSITION, float3 in_b : NORMAL{ints}) : SV_Position", "{"]
                self.vars += [("in_a", "float", 4), ("in_b", "float", 3)]
                if not self.legacy:
                    self.vars += [("in_v", "uint", 1), ("in_i", "int", 4)]
            result = "return {};"
        depth = 2 if self.d3d9 and self.sm < 3 else 3
        body = []
        while self.statements_left > 0:
            self.statement(body, 1, depth)
        # every value the program made feeds the result, so the optimizer keeps it
        terms = [f"(float4)({self.cast_to_float4(name, base, n)})" for name, base, n in self.vars[-6:]]
        acc = " + ".join(terms) if terms else "0"
        out += body + [f"    {result.format(acc)}", "}"]
        return "\n".join(head + out) + "\n"

    def cast_to_float4(self, name, base, n):
        v = name if base != "bool" else f"(float{'' if n == 1 else n})({name})"
        if n == 1:
            return f"(float){v}"
        if n == 4:
            return f"(float4){v}"
        return f"float4((float{n}){v}, {', '.join(['0'] * (4 - n))})"


def generate(rng, profile=None):
    target, stage, family = profile or rng.choice(PROFILES)
    g = Gen(rng, target, stage, family)
    statements = rng.randint(2, 6) if family == "d3d9" and target in ("ps_2_0", "vs_1_1") else rng.randint(3, 14)
    src = g.program(statements)
    flags = 0
    for name, bit in COMPILE_FLAGS.items():
        if rng.random() < {"o0": 0.1, "o2": 0.1, "o3": 0.2, "skip_optimization": 0.1, "debug": 0.1}.get(name, 0.07):
            flags |= bit
    if family not in ("51",):
        flags &= ~COMPILE_FLAGS["all_bound"]
    if family == "d3d9" and target == "ps_2_0":
        flags &= ~COMPILE_FLAGS["skip_optimization"]
    return target, src, flags
