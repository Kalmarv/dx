//! A text listing of a Direct3D 9 program in the dialect of Microsoft's disassembler (`D3DDisassemble`): the
//! constant table as comments, the program's lines indented four spaces, and the instruction slots it uses.
use std::fmt::Write;

use crate::{
    Comparison, Constant, ConstantTable, Declared, Destination, Error, Instruction, Item, Literal, Modifier,
    Opcode, Program, Register, RegisterType, Relative, Result, Source, Stage, TextureType, Type, read,
};

/// What the listing writes, as the `D3D_DISASM_*` flags of Microsoft's disassembler choose it.
#[derive(Clone, Debug, PartialEq, Eq)]
#[non_exhaustive]
pub struct Options {
    /// The constant table's comments (cleared by `D3D_DISASM_INSTRUCTION_ONLY`, 0x40; the slot count is written
    /// either way).
    pub header: bool,
    /// The arithmetic slots before each instruction, `%4u: ` (texture slots not counted; `%4u  ` before an offset),
    /// and six spaces before a co-issued instruction and the other lines but the version
    /// (`D3D_DISASM_ENABLE_INSTRUCTION_NUMBERING`, 0x04).
    pub numbering: bool,
    /// Each line's byte offset from the version token, `0x%08X: `, before every line but the version
    /// (`D3D_DISASM_ENABLE_INSTRUCTION_OFFSET`, 0x20).
    pub offsets: bool,
    /// A `def`'s floats as their bits, `0x%08x` (`D3D_DISASM_PRINT_HEX_LITERALS`, 0x80); `defi` stays decimal.
    pub hex_literals: bool,
}

impl Default for Options {
    fn default() -> Self {
        Self {
            header: true,
            numbering: false,
            offsets: false,
            hex_literals: false,
        }
    }
}

impl Options {
    /// The options of a `D3D_DISASM_*` flags word. 0x02 and 0x10 change nothing. Refuses 0x01 (an HTML listing), 0x08
    /// (which Microsoft's disassembler refuses too) and bits it does not define, naming the bit.
    pub fn from_flags(flags: u32) -> Result<Self> {
        let refuse = |detail: String| Error { word: 0, detail };
        if flags & 0x01 != 0 {
            return Err(refuse(
                "flag 0x01, D3D_DISASM_ENABLE_COLOR_CODE (an HTML listing), is not written".into(),
            ));
        }
        if flags & 0x08 != 0 {
            return Err(refuse(
                "flag 0x08, D3D_DISASM_ENABLE_INSTRUCTION_CYCLE, which Microsoft's disassembler refuses too, is not \
                 written"
                    .into(),
            ));
        }
        let unknown = flags & !0xf6;
        if unknown != 0 {
            return Err(refuse(format!(
                "flag bit 0x{:x} is not a D3D_DISASM flag",
                1u32 << unknown.trailing_zeros()
            )));
        }
        Ok(Self {
            header: flags & 0x40 == 0,
            numbering: flags & 0x04 != 0,
            offsets: flags & 0x20 != 0,
            hex_literals: flags & 0x80 != 0,
        })
    }
}

const LANES: [char; 4] = ['x', 'y', 'z', 'w'];

/// The listing of a Direct3D 9 program (its version token to `END`, no container) as Microsoft's disassembler
/// writes it with no flags, its lines ending in `\n` (the disassembler's blob also ends in a zero byte, which is not
/// part of the text). Refuses what [`read`] refuses.
pub fn disassemble(bytes: &[u8]) -> Result<String> {
    disassemble_with(bytes, &Options::default())
}

/// The listing [`disassemble`] writes, with what `options` choose.
pub fn disassemble_with(bytes: &[u8], options: &Options) -> Result<String> {
    let program = read(bytes)?;
    let mut out = String::new();
    // a program without a constant table starts at its version (as inside a feature level 9 container's listing)
    if let Some(table) = program.constants.as_ref().filter(|_| options.header) {
        header(&mut out, table);
    }
    let _ = writeln!(out, "    {}", program.version);
    let mut depth: usize = 0;
    // the arithmetic slots before the next instruction, which the numbering writes (texture slots don't count)
    let mut slot: u32 = 0;
    for item in &program.items {
        // the number (`%4u: `, or `%4u  ` before an offset; a co-issued instruction has none), then the offset
        let mut prefix = String::new();
        if options.numbering {
            match item {
                Item::Instruction(i) if !i.coissue => {
                    let colon = if options.offsets { ' ' } else { ':' };
                    let _ = write!(prefix, "{slot:>4}{colon} ");
                    slot = slot.saturating_add(slots(i, &program).1);
                }
                _ => prefix.push_str("      "),
            }
        }
        if options.offsets {
            let _ = write!(prefix, "0x{:08X}: ", item.word().saturating_mul(4));
        }
        // a co-issued instruction's `+` takes the place of the indent's last two spaces
        let indent = match item {
            Item::Instruction(i) if i.coissue => "  + ",
            _ => "    ",
        };
        let line = match item {
            Item::Comment(_) => continue,
            Item::Declaration(d) => declaration(d, &program),
            Item::Definition(d) => definition(&d.literal, d.destination.register, &program, options),
            Item::Instruction(i) => {
                if matches!(
                    i.opcode,
                    Opcode::Else | Opcode::EndIf | Opcode::EndLoop | Opcode::EndRep
                ) {
                    depth = depth.saturating_sub(1);
                }
                let text = instruction(i, &program);
                let line = format!("{}{text}", "  ".repeat(depth));
                if matches!(
                    i.opcode,
                    Opcode::If | Opcode::IfC | Opcode::Else | Opcode::Loop | Opcode::Rep
                ) {
                    depth = depth.saturating_add(1);
                }
                line
            }
        };
        let _ = writeln!(out, "{prefix}{indent}{}", line.trim_end());
    }
    out.push('\n');
    footer(&mut out, &program);
    Ok(out)
}

/// `D3DXPARAMETER_TYPE` as HLSL names it.
fn type_kind(kind: u16) -> &'static str {
    match kind {
        0 => "void",
        1 => "bool",
        2 => "int",
        3 => "float",
        4 => "string",
        5 => "texture",
        6 => "texture1D",
        7 => "texture2D",
        8 => "texture3D",
        9 => "textureCUBE",
        10 => "sampler",
        11 => "sampler1D",
        12 => "sampler2D",
        13 => "sampler3D",
        14 => "samplerCUBE",
        _ => "unknown",
    }
}

/// A parameter's type as the Parameters list writes it before the name: `float4`, `row_major float4x4`,
/// `sampler2D`.
fn type_name(ty: &Type) -> String {
    let kind = type_kind(ty.kind);
    match ty.class {
        1 => format!("{kind}{}", ty.columns),
        2 => format!("row_major {kind}{}x{}", ty.rows, ty.columns),
        3 => format!("{kind}{}x{}", ty.rows, ty.columns),
        _ => kind.to_owned(),
    }
}

/// The register bank of a `D3DXREGISTER_SET`: `b`, `i`, `c`, `s`.
fn bank(set: u16) -> &'static str {
    match set {
        0 => "b",
        1 => "i",
        3 => "s",
        _ => "c",
    }
}

/// The constant table as comments: the compiler, every parameter in name order, and the registers in register
/// order, then a blank line. A table with no constants is the compiler line alone, with no blank line after it.
fn header(out: &mut String, table: &ConstantTable) {
    let _ = writeln!(out, "//\n// Generated by {}", table.creator);
    let mut constants: Vec<&Constant> = table.constants.iter().collect();
    if constants.is_empty() {
        return;
    }
    constants.sort_by(|a, b| a.name.as_bytes().cmp(b.name.as_bytes()));
    out.push_str("//\n// Parameters:\n//\n");
    for c in &constants {
        parameter(out, 3, &c.ty, &c.name);
    }
    out.push_str("//\n//\n// Registers:\n//\n");
    constants.sort_by_key(|c| (c.register_set, c.register));
    // the name column is never narrower than 12
    let width = constants.iter().map(|c| c.name.len()).max().unwrap_or(0).max(12);
    let _ = writeln!(out, "//   {:<width$} Reg   Size", "Name");
    let _ = writeln!(out, "//   {} ----- ----", "-".repeat(width));
    for c in &constants {
        let register = format!("{}{}", bank(c.register_set), c.register);
        let _ = writeln!(out, "//   {:<width$} {register:<5} {:>4}", c.name, c.count);
    }
    out.push_str("//\n\n");
}

/// One line of the Parameters list, `type name[elements];`, at `indent` spaces after the `//`. A struct is a block, with
/// its members `indent + 4` in and a blank comment line before and after it (one between two structs):
///
/// ```text
/// //
/// //   struct
/// //   {
/// //       float4 colour;
/// //
/// //   } lights[3];
/// //
/// ```
fn parameter(out: &mut String, indent: usize, ty: &Type, name: &str) {
    let pad = " ".repeat(indent);
    let array = if ty.elements > 1 {
        format!("[{}]", ty.elements)
    } else {
        String::new()
    };
    if ty.class == 5 {
        let blank = format!("//{pad}\n");
        if !out.ends_with(&blank) {
            out.push_str(&blank);
        }
        let _ = write!(out, "//{pad}struct\n//{pad}{{\n");
        for member in &ty.members {
            parameter(out, indent.saturating_add(4), &member.ty, &member.name);
        }
        let _ = write!(out, "//\n//{pad}}} {name}{array};\n//{pad}\n");
    } else {
        let _ = writeln!(out, "//{pad}{} {name}{array};", type_name(ty));
    }
}

fn register(r: Register, program: &Program) -> String {
    let n = r.number;
    let vertex3 = program.version.stage == Stage::Vertex && program.version.major == 3;
    let indexed = |names: &[&str]| -> String {
        usize::try_from(n)
            .ok()
            .and_then(|i| names.get(i))
            .map_or_else(|| format!("?{n}"), |s| (*s).to_owned())
    };
    match r.kind {
        RegisterType::Temp => format!("r{n}"),
        RegisterType::Input => format!("v{n}"),
        RegisterType::Const => format!("c{n}"),
        RegisterType::Const2 => format!("c{}", n.saturating_add(2048)),
        RegisterType::Const3 => format!("c{}", n.saturating_add(4096)),
        RegisterType::Const4 => format!("c{}", n.saturating_add(6144)),
        RegisterType::Address if program.version.stage == Stage::Pixel => format!("t{n}"),
        RegisterType::Address => "a0".into(),
        RegisterType::RasterizerOut => indexed(&["oPos", "oFog", "oPts"]),
        RegisterType::AttributeOut => format!("oD{n}"),
        RegisterType::Output if vertex3 => format!("o{n}"),
        RegisterType::Output => format!("oT{n}"),
        RegisterType::ConstInt => format!("i{n}"),
        RegisterType::ColorOut => format!("oC{n}"),
        RegisterType::DepthOut => "oDepth".into(),
        RegisterType::Sampler => format!("s{n}"),
        RegisterType::ConstBool => format!("b{n}"),
        RegisterType::Loop => "aL".into(),
        RegisterType::Misc => indexed(&["vPos", "vFace"]),
        RegisterType::Label => format!("l{n}"),
        RegisterType::Predicate => format!("p{n}"),
        RegisterType::Texture => format!("t{n}"),
    }
}

fn lane(l: u8) -> char {
    LANES.get(usize::from(l)).copied().unwrap_or('?')
}

/// A source swizzle: none for `.xyzw`, one letter for a replicate, all four otherwise.
fn swizzle(s: [u8; 4]) -> String {
    match s {
        [0, 1, 2, 3] => String::new(),
        [a, b, c, d] if a == b && b == c && c == d => format!(".{}", lane(a)),
        _ => format!(".{}", s.iter().map(|&l| lane(l)).collect::<String>()),
    }
}

fn relative(r: Option<Relative>, program: &Program) -> String {
    r.map_or(String::new(), |r| {
        format!("[{}{}]", register(r.register, program), swizzle(r.swizzle))
    })
}

fn source(s: &Source, program: &Program) -> String {
    let name = format!(
        "{}{}",
        register(s.register, program),
        relative(s.relative, program)
    );
    let body = match s.modifier {
        Modifier::None | Modifier::Negate | Modifier::Not => name,
        Modifier::Bias | Modifier::BiasNegate => format!("{name}_bias"),
        Modifier::Sign | Modifier::SignNegate => format!("{name}_bx2"),
        Modifier::Complement => format!("1-{name}"),
        Modifier::X2 | Modifier::X2Negate => format!("{name}_x2"),
        Modifier::DivideZ => format!("{name}_dz"),
        Modifier::DivideW => format!("{name}_dw"),
        Modifier::Abs | Modifier::AbsNegate => format!("{name}_abs"),
    };
    let sign = match s.modifier {
        Modifier::Negate
        | Modifier::BiasNegate
        | Modifier::SignNegate
        | Modifier::X2Negate
        | Modifier::AbsNegate => "-",
        Modifier::Not => "!",
        _ => "",
    };
    let swizzled = if s.register.kind == RegisterType::Sampler {
        String::new()
    } else {
        swizzle(s.swizzle)
    };
    format!("{sign}{body}{swizzled}")
}

fn destination(d: &Destination, program: &Program) -> String {
    let mask = if d.mask == 15 {
        String::new()
    } else {
        let lanes: String = (0..4u8).filter(|n| d.mask & (1 << n) != 0).map(lane).collect();
        format!(".{lanes}")
    };
    format!(
        "{}{}{mask}",
        register(d.register, program),
        relative(d.relative, program)
    )
}

/// The result modifiers after a mnemonic: the pixel 1.x shift, `_sat`, `_pp`, `_centroid`.
fn suffixes(d: Option<&Destination>) -> String {
    let Some(d) = d else { return String::new() };
    let mut s = match d.shift {
        1 => "_x2",
        2 => "_x4",
        3 => "_x8",
        -1 => "_d2",
        -2 => "_d4",
        -3 => "_d8",
        _ => "",
    }
    .to_owned();
    if d.saturate {
        s.push_str("_sat");
    }
    if d.partial_precision {
        s.push_str("_pp");
    }
    if d.centroid {
        s.push_str("_centroid");
    }
    s
}

fn mnemonic(i: &Instruction, program: &Program) -> String {
    let v = program.version;
    let from14 = v.stage == Stage::Pixel && (v.major > 1 || v.minor == 4);
    let comparison = i.comparison().map_or("", |c| match c {
        Comparison::Greater => "_gt",
        Comparison::Equal => "_eq",
        Comparison::GreaterEqual => "_ge",
        Comparison::Less => "_lt",
        Comparison::NotEqual => "_ne",
        Comparison::LessEqual => "_le",
    });
    match i.opcode {
        Opcode::Tex if from14 => match i.control {
            0 => "texld",
            1 => "texldp",
            _ => "texldb",
        }
        .to_owned(),
        Opcode::TexCoord if from14 => "texcrd".into(),
        Opcode::IfC => format!("if{comparison}"),
        Opcode::BreakC => format!("break{comparison}"),
        Opcode::SetP => format!("setp{comparison}"),
        other => other.name().into(),
    }
}

fn instruction(i: &Instruction, program: &Program) -> String {
    let mut args = Vec::new();
    if let Some(d) = &i.destination {
        args.push(destination(d, program));
    }
    args.extend(i.sources.iter().map(|s| source(s, program)));
    let predicate = i
        .predicate
        .as_ref()
        .map_or(String::new(), |p| format!("({}) ", source(p, program)));
    format!(
        "{predicate}{}{} {}",
        mnemonic(i, program),
        suffixes(i.destination.as_ref()),
        args.join(", ")
    )
}

/// The usage names of `dcl_<usage><index>`.
const USAGES: [&str; 14] = [
    "position",
    "blendweight",
    "blendindices",
    "normal",
    "psize",
    "texcoord",
    "tangent",
    "binormal",
    "tessfactor",
    "positiont",
    "color",
    "fog",
    "depth",
    "sample",
];

fn declaration(d: &crate::Declaration, program: &Program) -> String {
    let what = match d.declared {
        Declared::Sampler(TextureType::D2) => "_2d".to_owned(),
        Declared::Sampler(TextureType::Cube) => "_cube".to_owned(),
        Declared::Sampler(TextureType::Volume) => "_volume".to_owned(),
        Declared::Semantic { .. }
            if matches!(
                d.destination.register.kind,
                RegisterType::Texture | RegisterType::Misc
            ) || (program.version.stage == Stage::Pixel && program.version.major == 2) =>
        {
            String::new()
        }
        Declared::Semantic { usage, index } => {
            let index = if index == 0 {
                String::new()
            } else {
                index.to_string()
            };
            let usage = USAGES.get(usize::from(usage)).copied().unwrap_or("unknown");
            format!("_{usage}{index}")
        }
    };
    format!(
        "dcl{what}{} {}",
        suffixes(Some(&d.destination)),
        destination(&d.destination, program)
    )
}

fn definition(literal: &Literal, register_: Register, program: &Program, options: &Options) -> String {
    let (op, values) = match literal {
        Literal::Float(f) => (
            "def",
            f.iter()
                .map(|&w| {
                    if options.hex_literals {
                        format!("0x{w:08x}")
                    } else {
                        general(f32::from_bits(w))
                    }
                })
                .collect::<Vec<_>>()
                .join(", "),
        ),
        Literal::Integer(i) => (
            "defi",
            i.iter().map(ToString::to_string).collect::<Vec<_>>().join(", "),
        ),
        Literal::Bool(b) => ("defb", (if *b != 0 { "true" } else { "false" }).to_owned()),
    };
    format!("{op} {}, {values}", register(register_, program))
}

/// A float as C's `%.9g` writes it: nine significant digits, trailing zeros dropped, an exponent below 1e-4 and from
/// 1e9.
fn general(value: f32) -> String {
    let value = f64::from(value);
    if value == 0.0 {
        return if value.is_sign_negative() { "-0" } else { "0" }.to_owned();
    }
    if !value.is_finite() {
        return format!("{value}");
    }
    let scientific = format!("{value:.8e}");
    let (mantissa, exponent) = scientific.split_once('e').unwrap_or((&scientific, "0"));
    let exponent: i32 = exponent.parse().unwrap_or(0);
    let trim = |text: &str| -> String {
        if text.contains('.') {
            text.trim_end_matches('0').trim_end_matches('.').to_owned()
        } else {
            text.to_owned()
        }
    };
    if !(-4..9).contains(&exponent) {
        let sign = if exponent < 0 { '-' } else { '+' };
        return format!("{}e{sign}{:03}", trim(mantissa), exponent.unsigned_abs());
    }
    let decimals = usize::try_from(8i32.saturating_sub(exponent)).unwrap_or(0);
    trim(&format!("{value:.decimals$}"))
}

/// The texture and arithmetic instruction slots an instruction takes, as Microsoft's listings count them: checked
/// against every footer of a vs_3_0 and ps_3_0 corpus and against fixtures of one operation each, and of co-issue. `loop`, `endloop`,
/// `call`, `callnz`, `ret`, `break`, `breakp` and `setp` take what Microsoft's instruction reference states, unchecked.
fn slots(i: &Instruction, program: &Program) -> (u32, u32) {
    // a co-issued instruction runs in the slot of the one before it
    if i.coissue {
        return (0, 0);
    }
    let pixel = program.version.stage == Stage::Pixel;
    match i.opcode {
        Opcode::Tex => (1, 0),
        Opcode::TexLdl => (2, 0),
        Opcode::TexLdd => (1, 2),
        Opcode::SinCos => (0, 8),
        Opcode::M4x4 | Opcode::M3x4 => (0, 4),
        Opcode::Nrm | Opcode::Pow | Opcode::M4x3 | Opcode::M3x3 => (0, 3),
        Opcode::If
        | Opcode::IfC
        | Opcode::BreakC
        | Opcode::BreakP
        | Opcode::CallNz
        | Opcode::Rep
        | Opcode::Loop => (0, 3),
        Opcode::EndRep
        | Opcode::EndLoop
        | Opcode::Call
        | Opcode::M3x2
        | Opcode::Crs
        | Opcode::Dsx
        | Opcode::Dsy => (0, 2),
        Opcode::Dp2Add if pixel => (0, 2),
        Opcode::Label | Opcode::Phase => (0, 0),
        _ => (0, 1),
    }
}

/// `// approximately N instruction slots used`, split into texture and arithmetic slots when the program samples.
fn footer(out: &mut String, program: &Program) {
    let (texture, arithmetic) = program.instructions().fold((0u32, 0u32), |(t, a), i| {
        let (ti, ai) = slots(i, program);
        (t.saturating_add(ti), a.saturating_add(ai))
    });
    let total = texture.saturating_add(arithmetic);
    let slots = if total == 1 { "slot" } else { "slots" };
    let _ = write!(out, "// approximately {total} instruction {slots} used");
    if texture > 0 {
        let _ = write!(out, " ({texture} texture, {arithmetic} arithmetic)");
    }
    out.push('\n');
}
