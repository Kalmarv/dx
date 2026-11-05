//! `cargo run -p d3d9-reader --example disassemble_d3d9 -- shader.bin...`: print each Direct3D 9 program (version
//! token to `END`, no container) as assembly, spelled close to Microsoft's disassembler, with the constant table's
//! allocations as comments.
use d3d9_reader::{
    Comparison, Declared, Destination, Instruction, Item, Literal, Modifier, Opcode, Program, Register,
    RegisterType, Relative, Source, Stage, TextureType, read,
};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let paths: Vec<String> = std::env::args().skip(1).collect();
    if paths.is_empty() {
        return Err("usage: disassemble_d3d9 <program.bin>...".into());
    }
    for path in paths {
        let program = read(&std::fs::read(&path)?)?;
        println!("// {path}");
        print!("{}", disassemble(&program));
    }
    Ok(())
}

const LANES: [char; 4] = ['x', 'y', 'z', 'w'];

fn register(r: Register, program: &Program) -> String {
    let n = r.number;
    let vertex3 = program.version.stage == Stage::Vertex && program.version.major == 3;
    match r.kind {
        RegisterType::Temp => format!("r{n}"),
        RegisterType::Input => format!("v{n}"),
        RegisterType::Const => format!("c{n}"),
        RegisterType::Const2 => format!("c{}", n + 2048),
        RegisterType::Const3 => format!("c{}", n + 4096),
        RegisterType::Const4 => format!("c{}", n + 6144),
        RegisterType::Address => "a0".into(),
        RegisterType::Texture => format!("t{n}"),
        RegisterType::RasterizerOut => ["oPos", "oFog", "oPts"][n as usize].into(),
        RegisterType::AttributeOut => format!("oD{n}"),
        RegisterType::Output if vertex3 => format!("o{n}"),
        RegisterType::Output => format!("oT{n}"),
        RegisterType::ConstInt => format!("i{n}"),
        RegisterType::ColorOut => format!("oC{n}"),
        RegisterType::DepthOut => "oDepth".into(),
        RegisterType::Sampler => format!("s{n}"),
        RegisterType::ConstBool => format!("b{n}"),
        RegisterType::Loop => "aL".into(),
        RegisterType::Misc => ["vPos", "vFace"][n as usize].into(),
        RegisterType::Label => format!("l{n}"),
        RegisterType::Predicate => format!("p{n}"),
    }
}

fn swizzle(s: [u8; 4]) -> String {
    match s {
        [0, 1, 2, 3] => String::new(),
        [a, b, c, d] if a == b && b == c && c == d => format!(".{}", LANES[a as usize]),
        _ => format!(".{}", s.iter().map(|&l| LANES[l as usize]).collect::<String>()),
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
        format!(
            ".{}",
            (0..4)
                .filter(|n| d.mask & (1 << n) != 0)
                .map(|n| LANES[n])
                .collect::<String>()
        )
    };
    format!(
        "{}{}{mask}",
        register(d.register, program),
        relative(d.relative, program)
    )
}

fn suffixes(d: Option<&Destination>) -> String {
    let Some(d) = d else { return String::new() };
    let shift = match d.shift {
        1 => "_x2",
        2 => "_x4",
        3 => "_x8",
        -1 => "_d2",
        -2 => "_d4",
        -3 => "_d8",
        _ => "",
    };
    let mut s = shift.to_owned();
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
    let comparison = i.comparison().map(|c| match c {
        Comparison::Greater => "_gt",
        Comparison::Equal => "_eq",
        Comparison::GreaterEqual => "_ge",
        Comparison::Less => "_lt",
        Comparison::NotEqual => "_ne",
        Comparison::LessEqual => "_le",
    });
    match i.opcode {
        Opcode::Tex if from14 => ["texld", "texldp", "texldb"][usize::from(i.control).min(2)].into(),
        Opcode::TexCoord if from14 => "texcrd".into(),
        Opcode::IfC => format!("if{}", comparison.unwrap_or_default()),
        Opcode::BreakC => format!("break{}", comparison.unwrap_or_default()),
        Opcode::SetP => format!("setp{}", comparison.unwrap_or_default()),
        other => other.name().into(),
    }
}

fn disassemble(program: &Program) -> String {
    let mut out = format!("{}\n", program.version);
    if let Some(table) = &program.constants {
        out.push_str(&format!("// {} for {}\n", table.creator, table.target));
        for c in &table.constants {
            let bank = ["b", "i", "c", "s"][usize::from(c.register_set).min(3)];
            out.push_str(&format!("//   {} {bank}{} ({})\n", c.name, c.register, c.count));
        }
    }
    for item in &program.items {
        let line = match item {
            Item::Comment(c) => format!("// comment of {} words", c.data.len()),
            Item::Declaration(d) => {
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
                        let names = [
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
                        let index = if index == 0 {
                            String::new()
                        } else {
                            index.to_string()
                        };
                        format!("_{}{index}", names[usize::from(usage)])
                    }
                };
                format!(
                    "dcl{what}{} {}",
                    suffixes(Some(&d.destination)),
                    destination(&d.destination, program)
                )
            }
            Item::Definition(d) => {
                let values = match d.literal {
                    Literal::Float(f) => f.map(|w| f32::from_bits(w).to_string()).join(", "),
                    Literal::Integer(i) => i.map(|n| n.to_string()).join(", "),
                    Literal::Bool(b) => (if b != 0 { "true" } else { "false" }).into(),
                };
                let op = ["def", "defi", "defb"][match d.literal {
                    Literal::Float(_) => 0,
                    Literal::Integer(_) => 1,
                    Literal::Bool(_) => 2,
                }];
                format!("{op} {}, {values}", register(d.destination.register, program))
            }
            Item::Instruction(i) => {
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
                    "{}{predicate}{}{} {}",
                    if i.coissue { "+" } else { "" },
                    mnemonic(i, program),
                    suffixes(i.destination.as_ref()),
                    args.join(", ")
                )
            }
        };
        out.push_str(line.trim_end());
        out.push('\n');
    }
    out
}
