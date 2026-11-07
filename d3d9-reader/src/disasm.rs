//! A text listing of a Direct3D 9 program in the dialect of Microsoft's disassembler (`D3DDisassemble`): the
//! constant table as comments, the program's lines indented four spaces, and the instruction slots it uses.
use std::collections::BTreeMap;
use std::fmt::Write;

use crate::{
    Comparison, Constant, ConstantTable, DebugInfo, Declared, Destination, Error, Instruction, Item, Literal,
    Modifier, Opcode, Precision, Program, Register, RegisterType, Relative, Result, Source, SourceLine,
    Stage, TextureType, Type, read,
};

/// What the listing writes, as the `D3D_DISASM_*` flags of Microsoft's disassembler choose it.
#[derive(Clone, Debug, PartialEq, Eq)]
#[non_exhaustive]
pub struct Options {
    /// The constant table's comments (cleared by `D3D_DISASM_INSTRUCTION_ONLY`, 0x40; the slot count is written
    /// either way).
    pub header: bool,
    /// The values the constant table stores for its constants, after the registers, a row for each register
    /// (`D3D_DISASM_ENABLE_DEFAULT_VALUE_PRINTS`, 0x02); written with the header alone.
    pub default_values: bool,
    /// The arithmetic slots before each instruction, `%4u: ` (texture slots not counted; `%4u  ` before an offset),
    /// and six spaces before a co-issued instruction, a `nop` and the other lines but the version
    /// (`D3D_DISASM_ENABLE_INSTRUCTION_NUMBERING`, 0x04).
    pub numbering: bool,
    /// Each line's byte offset from the version token, `0x%08X: `, before every line but the version
    /// (`D3D_DISASM_ENABLE_INSTRUCTION_OFFSET`, 0x20).
    pub offsets: bool,
    /// A `def`'s floats as their bits, `0x%08x` (`D3D_DISASM_PRINT_HEX_LITERALS`, 0x80); `defi` stays decimal.
    pub hex_literals: bool,
    /// What a `/Zi` build's `DBUG` comment says: a `#line` before an instruction whose source line moved, and after a
    /// line the variables it writes (cleared by `D3D_DISASM_DISABLE_DEBUG_INFO`, 0x10).
    pub debug_info: bool,
}

impl Default for Options {
    fn default() -> Self {
        Self {
            header: true,
            default_values: false,
            numbering: false,
            offsets: false,
            hex_literals: false,
            debug_info: true,
        }
    }
}

impl Options {
    /// The options of a `D3D_DISASM_*` flags word. Refuses 0x01 (an HTML listing), 0x08
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
            default_values: flags & 0x02 != 0,
            numbering: flags & 0x04 != 0,
            offsets: flags & 0x20 != 0,
            hex_literals: flags & 0x80 != 0,
            debug_info: flags & 0x10 == 0,
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
        header(&mut out, table, options.default_values);
    }
    let _ = writeln!(out, "    {}", program.version);
    let debug = program.debug.as_ref().filter(|_| options.debug_info);
    let notes = debug.map(variables).unwrap_or_default();
    // the line record of each record, by its byte offset
    let records: BTreeMap<u32, usize> = debug
        .map(|d| d.lines.iter().enumerate().map(|(n, l)| (l.offset, n)).collect())
        .unwrap_or_default();
    // the file and line of the last record that had one
    let mut source: Option<(u16, u16)> = None;
    let mut depth: usize = 0;
    // the arithmetic slots before the next instruction, which the numbering writes (texture slots don't count)
    let mut slot: u32 = 0;
    // no instruction yet
    let mut first = true;
    for item in &program.items {
        if matches!(item, Item::Comment(_)) {
            continue;
        }
        let record = u32::try_from(item.word().saturating_mul(4))
            .ok()
            .and_then(|offset| records.get(&offset))
            .copied();
        // a `#line` where the file changes or the line moves by more than 2, after a blank line and before the prefix
        let line = record.and_then(|n| debug.and_then(|d| d.lines.get(n)));
        if let (
            Some(d),
            Some(SourceLine {
                line,
                file: Some(file),
                ..
            }),
        ) = (debug, line)
        {
            match source {
                Some((f, l)) if f == *file => {
                    if line.abs_diff(l) > 2 {
                        let _ = writeln!(out, "\n#line {line}");
                    }
                }
                _ => {
                    let path = d.files.get(usize::from(*file)).map_or("", String::as_str);
                    let _ = writeln!(out, "\n#line {line} \"{path}\"");
                }
            }
            source = Some((*file, *line));
        }
        // the number (`%4u: `, or `%4u  ` before an offset; a co-issued instruction, a `nop` and a `label` have none,
        // though a co-issued first instruction's slot is counted), then the offset
        let mut prefix = String::new();
        if options.numbering {
            match item {
                Item::Instruction(i) if !i.coissue && !matches!(i.opcode, Opcode::Nop | Opcode::Label) => {
                    let colon = if options.offsets { ' ' } else { ':' };
                    let _ = write!(prefix, "{slot:>4}{colon} ");
                    slot = slot.saturating_add(slots(i, false, &program).1);
                }
                Item::Instruction(i) => {
                    slot = slot.saturating_add(slots(i, first, &program).1);
                    prefix.push_str("      ");
                }
                _ => prefix.push_str("      "),
            }
        }
        if matches!(item, Item::Instruction(_)) {
            first = false;
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
            // a declaration or definition inside flow control is indented as an instruction there is
            Item::Declaration(d) => format!("{}{}", "  ".repeat(depth), declaration(d, &program)),
            Item::Definition(d) => format!(
                "{}{}",
                "  ".repeat(depth),
                definition(&d.literal, &d.destination, &program, options)
            ),
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
        let _ = write!(out, "{prefix}{indent}{}", line.trim_end());
        if let Some(written) = record.and_then(|n| notes.get(n)).filter(|w| !w.is_empty()) {
            let _ = write!(out, "  // {}", written.join(", "));
        }
        out.push('\n');
    }
    out.push('\n');
    footer(&mut out, &program);
    Ok(out)
}

/// What each line record's instruction writes, by the record's place: `name<components>` for each location of each
/// variable, in the variable table's order. A variable of the entry point's parameters is its bare name, one of another
/// function or a constant buffer `scope::name`, and a local or a function's return value `::name`; the components are
/// those of the lanes that hold one, in lane order.
fn variables(debug: &DebugInfo) -> Vec<Vec<String>> {
    let mut notes = vec![Vec::new(); debug.lines.len()];
    for v in &debug.variables {
        let name = match &v.scope {
            Some(scope) if *scope == debug.entry => v.name.clone(),
            Some(scope) => format!("{scope}::{}", v.name),
            None => format!("::{}", v.name),
        };
        for l in &v.locations {
            let components: Vec<String> = l.components.iter().flatten().map(u16::to_string).collect();
            if let Some(n) = usize::try_from(l.instruction).ok().and_then(|n| notes.get_mut(n)) {
                n.push(format!("{name}<{}>", components.join(",")));
            }
        }
    }
    notes
}

/// A parameter's `D3DXPARAMETER_TYPE` as Microsoft's listing names it: the names of `D3D_SHADER_VARIABLE_TYPE`, which
/// extends it, with `UNKNOWN` for the buffer, UAV and structured-buffer types and any number past them.
fn type_kind(kind: u16) -> &'static str {
    match kind {
        0 => "void",
        1 => "bool",
        2 => "int",
        3 => "float",
        4 => "string",
        5 => "Texture",
        6 => "Texture1D",
        7 => "Texture2D",
        8 => "Texture3D",
        9 => "TextureCube",
        10 => "sampler",
        11 => "sampler1D",
        12 => "sampler2D",
        13 => "sampler3D",
        14 => "samplerCUBE",
        15 => "PixelShader",
        16 => "VertexShader",
        17 => "pixelfragment",
        18 => "vertexfragment",
        19 => "uint",
        20 => "byte",
        21 => "GeometryShader",
        22 => "RasterizerState",
        23 => "DepthStencilState",
        24 => "BlendState",
        25 => "Buffer",
        28 => "Texture1DArray",
        29 => "Texture2DArray",
        30 => "RenderTargetView",
        31 => "DepthStencilView",
        32 => "Texture2DMS",
        33 => "Texture2DMSArray",
        34 => "TextureCubeArray",
        35 => "HullShader",
        36 => "DomainShader",
        37 => "interface",
        38 => "ComputeShader",
        39 => "double",
        52 => "min8float",
        53 => "min10float",
        54 => "min16float",
        55 => "min12int",
        56 => "min16int",
        57 => "min16uint",
        _ => "UNKNOWN",
    }
}

/// A parameter's type as the Parameters list writes it before the name: `float4`, `row_major float4x4`,
/// `sampler2D`; nothing for a class past struct.
fn type_name(ty: &Type) -> String {
    let kind = type_kind(ty.kind);
    match ty.class {
        0 | 4 => kind.to_owned(),
        1 => format!("{kind}{}", ty.columns),
        2 => format!("row_major {kind}{}x{}", ty.rows, ty.columns),
        3 => format!("{kind}{}x{}", ty.rows, ty.columns),
        _ => String::new(),
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

/// The constant table as comments: the compiler, every parameter in the table's order, the registers in register
/// order and, where `defaults` asks for them, the values stored for them, then a blank line. A table with no
/// constants is the compiler line alone, with no blank line after it.
fn header(out: &mut String, table: &ConstantTable, defaults: bool) {
    let _ = writeln!(out, "//\n// Generated by {}", table.creator);
    let mut constants: Vec<&Constant> = table.constants.iter().collect();
    if constants.is_empty() {
        return;
    }
    // the parameters in the table's order (fxc writes it sorted by name); a uniform with a range in two register sets
    // is one parameter
    out.push_str("//\n// Parameters:\n//\n");
    let mut parameters = constants.clone();
    parameters.dedup_by(|a, b| a.name == b.name);
    let parameters: Vec<(&Type, &str)> = parameters.iter().map(|c| (&c.ty, c.name.as_str())).collect();
    list(out, 3, &parameters);
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
    out.push_str("//\n");
    if defaults && constants.iter().any(|c| c.default.is_some()) {
        default_values(out, &constants);
    }
    out.push('\n');
}

/// The Default values: for each constant that has them, in register order, its name and a row for each of its
/// registers: a bool as `true` (any word but 0) or `false`, an int4 as four signed integers, and a float4 as four
/// floats as C's `%g` writes them. The table's reader has refused a value that is not within the table, which
/// Microsoft's disassembler lists by reading what follows the table, or ends the listing's comments at with
/// `<invalid default value offset>`.
fn default_values(out: &mut String, constants: &[&Constant]) {
    out.push_str("//\n// Default values:\n//\n");
    for c in constants {
        let Some(default) = &c.default else { continue };
        let _ = writeln!(out, "//   {}", c.name);
        let words: Vec<u32> = default
            .as_chunks::<4>()
            .0
            .iter()
            .map(|w| u32::from_le_bytes(*w))
            .collect();
        // the reader took a word a register for a bool and four for the others
        let values: Vec<String> = match c.register_set {
            0 => words
                .iter()
                .map(|&w| (if w != 0 { "true" } else { "false" }).to_owned())
                .collect(),
            set => words
                .chunks(4)
                .map(|row| {
                    let row: Vec<String> = if set == 1 {
                        row.iter().map(|w| w.cast_signed().to_string()).collect()
                    } else {
                        row.iter().map(|&w| general(f32::from_bits(w), 6)).collect()
                    };
                    format!("{{ {} }}", row.join(", "))
                })
                .collect(),
        };
        for (register, value) in (u32::from(c.register)..).zip(values) {
            let register = format!("{}{register}", bank(c.register_set));
            let _ = writeln!(out, "//     {register:<5}= {value};");
        }
        out.push_str("//\n");
    }
}

/// The Parameters list or a struct's members, `type name[elements];` at `indent` spaces after the `//`, with a blank
/// comment line (`//` and the indent's spaces) between a struct and the item before or after it (one between two
/// structs) but not before the first item or after the last. A struct is a block with its members `indent + 4` in:
///
/// ```text
/// //   struct
/// //   {
/// //       float4 colour;
/// //
/// //   } lights[3];
/// ```
fn list(out: &mut String, indent: usize, items: &[(&Type, &str)]) {
    let pad = " ".repeat(indent);
    let mut previous: Option<&Type> = None;
    for &(ty, name) in items {
        if previous.is_some_and(|p| p.class == 5 || ty.class == 5) {
            let _ = writeln!(out, "//{pad}");
        }
        previous = Some(ty);
        let array = if ty.elements > 1 {
            format!("[{}]", ty.elements)
        } else {
            String::new()
        };
        if ty.class == 5 {
            let _ = write!(out, "//{pad}struct\n//{pad}{{\n");
            let members: Vec<(&Type, &str)> = ty.members.iter().map(|m| (&m.ty, m.name.as_str())).collect();
            list(out, indent.saturating_add(4), &members);
            let _ = writeln!(out, "//\n//{pad}}} {name}{array};");
        } else {
            let _ = writeln!(out, "//{pad}{} {name}{array};", type_name(ty));
        }
    }
}

fn register(r: Register, program: &Program) -> String {
    let n = r.number;
    // type 6 is `oTN` before 3.0 and `oN` in 3.0, in either stage
    let sm3 = program.version.major == 3;
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
        RegisterType::Output if sm3 => format!("o{n}"),
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
    format!("{sign}{body}{}{}", swizzle(s.swizzle), precision(s.precision))
}

/// An operand's minimum precision as the listing writes it after the operand.
fn precision(p: Precision) -> &'static str {
    match p {
        Precision::Min16 => " {min16f}",
        Precision::Min2_8 => " {min2_8f}",
        Precision::Default | Precision::Unnamed => "",
    }
}

fn destination(d: &Destination, program: &Program) -> String {
    let mask = if d.mask == 15 {
        String::new()
    } else {
        let lanes: String = (0..4u8).filter(|n| d.mask & (1 << n) != 0).map(lane).collect();
        format!(".{lanes}")
    };
    format!(
        "{}{}{mask}{}",
        register(d.register, program),
        relative(d.relative, program),
        precision(d.precision)
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
    // `texld` and `texcrd` from pixel 1.4 and from 2.0 in both stages
    let from14 = v.major > 1 || (v.stage == Stage::Pixel && v.minor == 4);
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
    if i.opcode == Opcode::BreakP {
        return breakp(i, program);
    }
    let mut args = Vec::new();
    if let Some(d) = &i.destination {
        args.push(destination(d, program));
    }
    args.extend(i.sources.iter().map(|s| source(s, program)));
    // a predicate token's precision bits mean nothing, and the listing leaves them out
    let predicate = i.predicate.as_ref().map_or(String::new(), |p| {
        let p = Source {
            precision: Precision::Default,
            ..*p
        };
        format!("({}) ", source(&p, program))
    });
    format!(
        "{predicate}{}{} {}",
        mnemonic(i, program),
        suffixes(i.destination.as_ref()),
        args.join(", ")
    )
}

/// `breakp` as Microsoft's disassembler writes it: `break`, then its predicate source read as though its token were a
/// destination's. The source's swizzle bits (16 to 23) are a write mask (16 to 19) and the result modifiers `_sat`,
/// `_pp` and `_centroid` (20 to 22), and its modifier bits (24 to 27) a result shift, so `breakp p0.x` is listed
/// `break p0.`, `breakp p0.y` `break_sat_centroid p0.xz` and `breakp !p0.x` `break_d8 p0.` (`D3DAssemble`d programs
/// in `tests/assembled`).
fn breakp(i: &Instruction, program: &Program) -> String {
    let Some(p) = i.sources.first() else {
        return "break".to_owned();
    };
    let bits = p.swizzle.iter().enumerate().fold(0u8, |bits, (lane, from)| {
        let at = u32::try_from(lane).map_or(8, |l| l.saturating_mul(2));
        bits | (from & 3).checked_shl(at).unwrap_or(0)
    });
    // the modifier's four bits as a signed shift: `!` (13) is -3, `_d8`
    let shift = i8::try_from(p.modifier.code()).map_or(0, |m| if m >= 8 { m.wrapping_sub(16) } else { m });
    let read = Destination {
        word: p.word,
        register: p.register,
        mask: bits & 15,
        saturate: bits & 16 != 0,
        partial_precision: bits & 32 != 0,
        centroid: bits & 64 != 0,
        shift,
        relative: None,
        precision: p.precision,
    };
    format!("break{} {}", suffixes(Some(&read)), destination(&read, program))
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
        // a pixel program's input of usage 0 (position) and index 0 has no usage, whatever its register
        Declared::Semantic { usage: 0, index: 0 } if program.version.stage == Stage::Pixel => String::new(),
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

/// A `def`, `defi` or `defb`, whose destination Microsoft writes as any other: its result modifiers after the mnemonic
/// and a mask that is not all four lanes.
fn definition(literal: &Literal, register_: &Destination, program: &Program, options: &Options) -> String {
    let (op, values) = match literal {
        Literal::Float(f) => (
            "def",
            f.iter()
                .map(|&w| {
                    if options.hex_literals {
                        format!("0x{w:08x}")
                    } else {
                        general(f32::from_bits(w), 9)
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
    format!(
        "{op}{} {}, {values}",
        suffixes(Some(register_)),
        destination(register_, program)
    )
}

/// A float as C's `%.{digits}g` writes it: `digits` significant digits (from 1), trailing zeros dropped, an exponent
/// below 1e-4 and from 1e`digits`; an infinity or NaN as MSVC spells it (`1.#INF`, `1.#QNAN`, and `-1.#IND` for the
/// default NaN, 0xffc00000). The float is widened to a double first, which quiets a signaling NaN.
fn general(value: f32, digits: usize) -> String {
    let bits = value.to_bits();
    let value = f64::from(value);
    if value == 0.0 {
        return if value.is_sign_negative() { "-0" } else { "0" }.to_owned();
    }
    if !value.is_finite() {
        let sign = if value.is_sign_negative() { "-" } else { "" };
        let name = if value.is_infinite() {
            "INF"
        } else if bits == 0xffc0_0000 {
            "IND"
        } else {
            "QNAN"
        };
        return format!("{sign}1.#{name}");
    }
    let scientific = format!("{value:.precision$e}", precision = digits.saturating_sub(1));
    let (mantissa, exponent) = scientific.split_once('e').unwrap_or((&scientific, "0"));
    let exponent: i32 = exponent.parse().unwrap_or(0);
    let trim = |text: &str| -> String {
        if text.contains('.') {
            text.trim_end_matches('0').trim_end_matches('.').to_owned()
        } else {
            text.to_owned()
        }
    };
    let digits = i32::try_from(digits).unwrap_or(i32::MAX);
    if !(-4..digits).contains(&exponent) {
        let sign = if exponent < 0 { '-' } else { '+' };
        return format!("{}e{sign}{:03}", trim(mantissa), exponent.unsigned_abs());
    }
    let decimals = usize::try_from(digits.saturating_sub(1).saturating_sub(exponent)).unwrap_or(0);
    trim(&format!("{value:.decimals$}"))
}

/// The texture and arithmetic instruction slots an instruction takes, as Microsoft's listings count them: checked
/// against every footer of a vs_3_0 and ps_3_0 corpus, against `D3DAssemble`d programs of every operation alone in each
/// version (`tests/assembled`), and of co-issue and predication. `loop`, `endloop`, `call`, `callnz` and `ret` take
/// what Microsoft's instruction reference states, unchecked.
fn slots(i: &Instruction, first: bool, program: &Program) -> (u32, u32) {
    // a co-issued instruction runs in the slot of the one before it (the program's first takes its own), and a `nop`
    // takes none
    if (i.coissue && !first) || i.opcode == Opcode::Nop {
        return (0, 0);
    }
    let v = program.version;
    let pixel1 = v.stage == Stage::Pixel && v.major == 1;
    let vertex1 = v.stage == Stage::Vertex && v.major == 1;
    let (texture, arithmetic): (u32, u32) = match i.opcode {
        Opcode::Tex => (1, 0),
        // pixel 1.x's texture addressing operations, `texcrd` of 1.4 among them, in whatever version; `texkill`,
        // `texdepth` and `bem` are arithmetic
        Opcode::TexCoord
        | Opcode::TexBem
        | Opcode::TexBemL
        | Opcode::TexReg2Ar
        | Opcode::TexReg2Gb
        | Opcode::TexReg2Rgb
        | Opcode::TexM3x2Pad
        | Opcode::TexM3x2Tex
        | Opcode::TexM3x2Depth
        | Opcode::TexM3x3Pad
        | Opcode::TexM3x3Tex
        | Opcode::TexM3x3Spec
        | Opcode::TexM3x3VSpec
        | Opcode::TexM3x3
        | Opcode::TexDp3
        | Opcode::TexDp3Tex => (1, 0),
        Opcode::TexLdl => (2, 0),
        Opcode::TexLdd => (1, 2),
        // vertex 1.1's full-precision `exp` and `log` and its `frc` are macros
        Opcode::Exp | Opcode::Log if vertex1 => (0, 10),
        Opcode::Frc if vertex1 => (0, 3),
        Opcode::SinCos => (0, 8),
        Opcode::M4x4 | Opcode::M3x4 => (0, 4),
        Opcode::Nrm | Opcode::Pow | Opcode::M4x3 | Opcode::M3x3 | Opcode::Sgn => (0, 3),
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
        | Opcode::Dsy
        | Opcode::Dp2Add
        | Opcode::Bem => (0, 2),
        Opcode::Label | Opcode::Phase => (0, 0),
        _ => (0, 1),
    };
    // a pixel 1.x instruction takes one arithmetic slot at most, even one of a later version's macros
    if pixel1 {
        return (texture, arithmetic.min(1));
    }
    // a predicated instruction takes one arithmetic slot more, a predicated sample too
    let predicate = u32::from(i.predicate.is_some());
    (texture, arithmetic.saturating_add(predicate))
}

/// `// approximately N instruction slots used`, split into texture and arithmetic slots when the program samples.
fn footer(out: &mut String, program: &Program) {
    let (texture, arithmetic) = program
        .instructions()
        .enumerate()
        .fold((0u32, 0u32), |(t, a), (n, i)| {
            let (ti, ai) = slots(i, n == 0, program);
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
