//! The comment block before the program: the compiler, the buffer definitions, the resource bindings and the
//! signatures, as the `RDEF` and signature parts state them.
use std::fmt::Write;

use crate::decode::{Declared, Decoded, ProgramType};
use crate::reflection::{Rdef, RdefBinding, RdefType, RdefVariable, SignatureElement};

/// The column the `// Offset:` of a buffer member starts at.
const OFFSET_COLUMN: usize = 40;

/// `D3D_SHADER_VARIABLE_TYPE` as HLSL names it.
fn scalar_name(scalar: u16) -> String {
    match scalar {
        0 => "void",
        1 => "bool",
        2 => "int",
        3 => "float",
        4 => "string",
        5 => "texture",
        6 => "Texture1D",
        7 => "Texture2D",
        8 => "Texture3D",
        9 => "TextureCube",
        10 => "SamplerState",
        19 => "uint",
        20 => "uint8",
        25 => "Buffer",
        26 => "cbuffer",
        27 => "tbuffer",
        28 => "Texture1DArray",
        29 => "Texture2DArray",
        32 => "Texture2DMS",
        33 => "Texture2DMSArray",
        34 => "TextureCubeArray",
        39 => "double",
        40 => "RWTexture1D",
        41 => "RWTexture1DArray",
        42 => "RWTexture2D",
        43 => "RWTexture2DArray",
        44 => "RWTexture3D",
        45 => "RWBuffer",
        46 => "ByteAddressBuffer",
        47 => "RWByteAddressBuffer",
        48 => "StructuredBuffer",
        49 => "RWStructuredBuffer",
        50 => "AppendStructuredBuffer",
        51 => "ConsumeStructuredBuffer",
        52 => "min8float",
        53 => "min10float",
        54 => "min16float",
        55 => "min12int",
        56 => "min16int",
        57 => "min16uint",
        other => return format!("type{other}"),
    }
    .to_owned()
}

/// The type's name as the buffer definitions write it before the variable's name: `float4`, `row_major float3x4`,
/// `interface ILight`. Built from the record's class and scalar type, as Microsoft's disassembler does (the stored
/// name of a `uint` is `dword`); a struct's and an interface's from their stored names.
fn type_name(ty: &RdefType) -> String {
    let scalar = scalar_name(ty.scalar);
    match ty.class {
        1 => format!("{scalar}{}", ty.columns),
        2 => format!("row_major {scalar}{}x{}", ty.rows, ty.columns),
        3 => format!("{scalar}{}x{}", ty.rows, ty.columns),
        // an interface class (6) or pointer (7)
        6 | 7 => format!("interface {}", ty.name.as_deref().unwrap_or("")),
        _ => scalar,
    }
}

/// `name[elements]`, or `name` for a type that is not an array (an element of a `ConstantBuffer<T>` array stores one
/// element, which the listing does not write either).
fn declarator(name: &str, ty: &RdefType) -> String {
    if ty.elements <= 1 {
        name.to_owned()
    } else {
        format!("{name}[{}]", ty.elements)
    }
}

/// A line of the buffer definitions padded to the offset column, then its offset (and its size, for a variable
/// of the buffer itself).
fn member_line(out: &mut String, text: &str, offset: u32, size: Option<(u32, bool)>) {
    let _ = write!(out, "{text:<OFFSET_COLUMN$}// Offset: {offset:>4}");
    if let Some((size, unused)) = size {
        let _ = write!(out, " Size: {size:>5}");
        if unused {
            out.push_str(" [unused]");
        }
    }
    out.push('\n');
}

/// A variable or struct member at `indent` spaces after the `//`: a struct opens its own block of members.
fn variable(out: &mut String, indent: usize, name: &str, ty: &RdefType, offset: u32, size: Option<(u32, bool)>) {
    let pad = " ".repeat(indent);
    if ty.class == 5 {
        let title = match &ty.name {
            Some(name) => format!("struct {name}"),
            None => "struct".to_owned(),
        };
        let inner = " ".repeat(indent.saturating_add(4));
        let _ = writeln!(out, "//{pad}{title}\n//{pad}{{\n//{inner}");
        for member in &ty.members {
            members(out, indent.saturating_add(4), &ty.members, member, offset);
        }
        out.push_str("//\n");
        member_line(
            out,
            &format!("//{pad}}} {};", declarator(name, ty)),
            offset,
            size,
        );
    } else {
        member_line(
            out,
            &format!("//{pad}{} {};", type_name(ty), declarator(name, ty)),
            offset,
            size,
        );
    }
}

/// A struct member; a struct member after the first is set apart by a line of its own.
fn members(
    out: &mut String,
    indent: usize,
    all: &[crate::reflection::RdefMember],
    member: &crate::reflection::RdefMember,
    base: u32,
) {
    let first = all.first().is_some_and(|m| std::ptr::eq(m, member));
    if member.ty.class == 5 && !first {
        let _ = writeln!(out, "//{}", " ".repeat(indent));
    }
    variable(
        out,
        indent,
        &member.name,
        &member.ty,
        base.saturating_add(member.offset),
        None,
    );
}

/// The variables of a buffer, a struct-typed one after the first set apart by a line of its own.
fn buffer_variables(out: &mut String, variables: &[RdefVariable]) {
    for (i, v) in variables.iter().enumerate() {
        if v.ty.class == 5 && i != 0 {
            out.push_str("//   \n");
        }
        // D3D_SVF_USED
        let unused = v.flags & 2 == 0;
        variable(out, 3, &v.name, &v.ty, v.offset, Some((v.size, unused)));
        if let Some(default) = &v.default {
            out.push_str("//      =");
            for word in default.as_chunks::<4>().0 {
                let _ = write!(out, " 0x{:08x}", u32::from_le_bytes(*word));
            }
            out.push_str(" \n");
        }
    }
}

/// The buffer definitions: each constant buffer, texture buffer and structured buffer element.
fn buffers(out: &mut String, rdef: &Rdef) {
    if rdef.buffers.is_empty() {
        return;
    }
    out.push_str("// Buffer Definitions: \n");
    for buffer in &rdef.buffers {
        let title = match buffer.kind {
            1 => format!("tbuffer {}", buffer.name),
            2 => format!("interfaces {}", buffer.name),
            3 => format!("Resource bind info for {}", buffer.name),
            _ => format!("cbuffer {}", buffer.name),
        };
        let _ = writeln!(out, "//\n// {title}\n// {{\n//");
        buffer_variables(out, &buffer.variables);
        out.push_str("//\n// }\n");
    }
    out.push_str("//\n//\n");
}

/// `D3D_SHADER_INPUT_TYPE` as the Type column names it.
fn binding_type(b: &RdefBinding) -> &'static str {
    match b.kind {
        0 => "cbuffer",
        1 => "tbuffer",
        3 if b.flags & 2 != 0 => "sampler_c",
        3 => "sampler",
        4 | 6 | 8..=11 | 13 => "UAV",
        _ => "texture",
    }
}

/// The Format column: the type of what the binding returns, `NA` where it returns none.
fn binding_format(b: &RdefBinding) -> String {
    match b.kind {
        0 | 1 | 3 => "NA".to_owned(),
        5 | 6 | 9..=11 => "struct".to_owned(),
        7 | 8 => "byte".to_owned(),
        _ => {
            let name = match b.returns {
                1 => "unorm",
                2 => "snorm",
                3 => "sint",
                4 => "uint",
                5 => "float",
                6 => "mixed",
                7 => "double",
                8 => "continued",
                _ => "NA",
            };
            // D3D_SIF_TEXTURE_COMPONENTS: the number of components less one
            let components = ((b.flags >> 2) & 3).saturating_add(1);
            if components > 1 {
                format!("{name}{components}")
            } else {
                name.to_owned()
            }
        }
    }
}

/// The Dim column: the resource's shape.
fn binding_dimension(b: &RdefBinding) -> String {
    match b.kind {
        0 | 1 | 3 => return "NA".to_owned(),
        5 | 7 => return "r/o".to_owned(),
        6 | 8 => return "r/w".to_owned(),
        9 => return "append".to_owned(),
        10 => return "consume".to_owned(),
        11 => return "r/w+cnt".to_owned(),
        _ => {}
    }
    let name = match b.dimension {
        1 => "buf",
        2 => "1d",
        3 => "1darray",
        4 => "2d",
        5 => "2darray",
        6 => "2dMS",
        7 => "2darrayMS",
        8 => "3d",
        9 => "cube",
        10 => "cubearray",
        11 => "buf",
        _ => "NA",
    };
    if matches!(b.dimension, 6 | 7) && b.samples != 0 && b.samples != u32::MAX {
        format!("{name}{}", b.samples)
    } else {
        name.to_owned()
    }
}

/// The register file prefix of a binding.
fn binding_prefix(b: &RdefBinding) -> &'static str {
    match binding_type(b) {
        "cbuffer" => "cb",
        "sampler" | "sampler_c" => "s",
        "UAV" => "u",
        _ => "t",
    }
}

/// The id column of a Shader Model 5.1 binding: the name its declaration and instructions use (`T0`, `CB1`).
fn binding_id(b: &RdefBinding) -> String {
    let prefix = binding_prefix(b).to_ascii_uppercase();
    format!("{prefix}{}", b.id.unwrap_or(0))
}

/// The resource bindings table.
fn bindings(out: &mut String, rdef: &Rdef, sm51: bool) {
    if rdef.bindings.is_empty() {
        return;
    }
    out.push_str("// Resource Bindings:\n//\n");
    if sm51 {
        out.push_str("// Name                                 Type  Format         Dim      ID      HLSL Bind  Count\n");
        out.push_str("// ------------------------------ ---------- ------- ----------- ------- -------------- ------\n");
    } else {
        out.push_str("// Name                                 Type  Format         Dim      HLSL Bind  Count\n");
        out.push_str("// ------------------------------ ---------- ------- ----------- -------------- ------\n");
    }
    for b in &rdef.bindings {
        let bind = if b.space != 0 {
            format!("{}{},space{}", binding_prefix(b), b.register, b.space)
        } else {
            format!("{}{}", binding_prefix(b), b.register)
        };
        let count = if b.count == 0 {
            "unbounded".to_owned()
        } else {
            b.count.to_string()
        };
        let _ = write!(
            out,
            "// {:<30} {:>10} {:>7} {:>11} ",
            b.name,
            binding_type(b),
            binding_format(b),
            binding_dimension(b)
        );
        if sm51 {
            let _ = write!(out, "{:>7} ", binding_id(b));
        }
        let _ = writeln!(out, "{bind:>14} {count:>6} ");
    }
    out.push_str("//\n//\n");
}

/// The element's `D3D_NAME`: a pixel program's outputs store none, so theirs is the one their semantic names.
fn system_value(e: &SignatureElement, output: bool, kind: ProgramType) -> u32 {
    if e.system_value != 0 || !output || kind != ProgramType::Pixel {
        return e.system_value;
    }
    match e.name.to_ascii_lowercase().as_str() {
            "sv_target" => 64,
            "sv_depth" => 65,
            "sv_coverage" => 66,
            "sv_depthgreaterequal" => 67,
            "sv_depthlessequal" => 68,
        "sv_stencilref" => 69,
        "sv_innercoverage" => 70,
        _ => 0,
    }
}

/// `D3D_NAME` as the SysValue column names it.
fn system_value_name(e: &SignatureElement, output: bool, kind: ProgramType) -> String {
    match system_value(e, output, kind) {
        0 => "NONE",
        1 => "POS",
        2 => "CLIPDST",
        3 => "CULLDST",
        4 => "RTINDEX",
        5 => "VPINDEX",
        6 => "VERTID",
        7 => "PRIMID",
        8 => "INSTID",
        9 => "FFACE",
        10 => "SAMPLE",
        11 => "QUADEDGE",
        12 => "QUADINT",
        13 => "TRIEDGE",
        14 => "TRIINT",
        15 => "LINEDET",
        16 => "LINEDEN",
        64 => "TARGET",
        65 => "DEPTH",
        66 => "COVERAGE",
        67 => "DEPTHGE",
        68 => "DEPTHLE",
        69 => "STENCILREF",
        70 => "INNERCOV",
        other => return format!("SV{other}"),
    }
    .to_owned()
}

/// A component mask with each letter in its place: `xy  `, ` y w`.
fn mask(mask: u8) -> String {
    ['x', 'y', 'z', 'w']
        .iter()
        .enumerate()
        .map(|(bit, &c)| if mask & (1 << bit) != 0 { c } else { ' ' })
        .collect()
}

/// The Register column of an element the pipeline holds in no numbered register, as Microsoft's disassembler pads it
/// (`oStencilRef` overflows the column).
fn special_register(system_value: u32) -> &'static str {
    match system_value {
        7 => "   primID",
        65 => "   oDepth",
        66 => "    oMask",
        67 => " oDepthGE",
        68 => " oDepthLE",
        69 => "    oStencilRef",
        _ => "  special",
    }
}

/// The Format column: the component type, or the minimum precision where the element has one.
fn element_format(e: &SignatureElement) -> &'static str {
    match (e.min_precision, e.component_type) {
        (1, _) => "min16f",
        (2, _) => "min2_8f",
        (4, _) => "min16i",
        (5, _) => "min16u",
        (_, 1) => "uint",
        (_, 2) => "int",
        (_, 3) => "float",
        _ => "unknown",
    }
}

/// One signature table: `title` (`Input`, `Output`, `Patch Constant`) and its rows, each name after its stream
/// (`m0:`) where an element is on a stream other than 0; an empty one says so and has no closing line.
fn signature(out: &mut String, title: &str, elements: &Elements<'_>, output: bool, kind: ProgramType) {
    let Elements { elements, streams } = *elements;
    let _ = writeln!(out, "//\n// {title} signature:\n//");
    out.push_str("// Name                 Index   Mask Register SysValue  Format   Used\n");
    out.push_str("// -------------------- ----- ------ -------- -------- ------- ------\n");
    if elements.is_empty() {
        let _ = writeln!(out, "// no {title}");
        return;
    }
    for e in elements {
        let sv = system_value_name(e, output, kind);
        let format = element_format(e);
        let used = if output {
            e.mask & !e.read_write_mask
        } else {
            e.read_write_mask
        };
        if streams {
            let _ = write!(out, "// m{}:{:<17} {:>5} ", e.stream, e.name, e.index);
        } else {
            let _ = write!(out, "// {:<20} {:>5} ", e.name, e.index);
        }
        if e.register == u32::MAX {
            let register = special_register(system_value(e, output, kind));
            let used = if used != 0 { "    YES" } else { "     NO" };
            let _ = writeln!(out, "   N/A{register} {sv:>8} {format:>7}{used}");
        } else {
            let _ = writeln!(
                out,
                "  {} {:>8} {:>8} {:>7}   {}",
                mask(e.mask),
                e.register,
                sv,
                format,
                mask(used)
            );
        }
    }
    out.push_str("//\n");
}

/// The functionality notes in the order of Microsoft's table, which follows the `SFI0` bits but for bit 1 (raw and
/// structured buffers in `SFI0`, which the disassembler does not note), where it notes forced early depth-stencil.
const NOTES: [&str; 14] = [
    "Double-precision floating point",
    "Early depth-stencil",
    "UAVs at every shader stage",
    "64 UAV slots",
    "Minimum-precision data types",
    "Double-precision extensions for 11.1",
    "Shader extensions for 11.1",
    "Comparison filtering for feature level 9",
    "Tiled resources",
    "PS Output Stencil Ref",
    "PS Inner Coverage",
    "Typed UAV Load Additional Formats",
    "Raster Ordered UAVs",
    "SV_RenderTargetArrayIndex or SV_ViewportArrayIndex from any shader feeding rasterizer",
];

/// The `// Note: shader requires additional functionality:` block.
fn notes(out: &mut String, features: u64, program: &Decoded) {
    // dcl_globalFlags forceEarlyDepthStencil
    let early = program
        .declarations
        .iter()
        .any(|d| matches!(d.kind, Declared::GlobalFlags(flags) if flags & 4 != 0));
    let bits = (features & !2) | if early { 2 } else { 0 };
    let names: Vec<&str> = NOTES
        .iter()
        .enumerate()
        .filter(|&(bit, _)| bits >> bit & 1 != 0)
        .map(|(_, &name)| name)
        .collect();
    if names.is_empty() {
        return;
    }
    out.push_str("//\n// Note: shader requires additional functionality:\n");
    for name in names {
        let _ = writeln!(out, "//       {name}");
    }
    out.push_str("//\n");
}

/// The control bits of the first declaration with `opcode`.
fn declared(program: &Decoded, opcode: u16) -> Option<u32> {
    program
        .declarations
        .iter()
        .find(|d| d.opcode == opcode)
        .map(|d| d.control)
}

/// The tessellation tables of a hull program (domain, output control points, output primitive and partitioning) and
/// of a domain program (domain and input control points).
fn tessellation(out: &mut String, program: &Decoded) {
    let points = match program.kind {
        // dcl_output_control_point_count
        ProgramType::Hull => declared(program, 148),
        // dcl_input_control_point_count
        ProgramType::Domain => declared(program, 147),
        _ => return,
    };
    // dcl_tessellator_domain
    let Some(domain) = declared(program, 149) else {
        return;
    };
    let domain = match domain & 7 {
        1 => "Isoline",
        2 => "Triangle",
        3 => "Quadrilateral",
        _ => "Undefined",
    };
    out.push_str("// Tessellation Domain   # of control points\n");
    out.push_str("// -------------------- --------------------\n");
    let _ = writeln!(out, "// {domain:<20} {:>20}\n//", points.unwrap_or(0) & 63);
    if program.kind != ProgramType::Hull {
        return;
    }
    // dcl_tessellator_output_primitive, dcl_tessellator_partitioning
    let primitive = match declared(program, 151).unwrap_or(0) & 7 {
        1 => "Point",
        2 => "Line",
        3 => "Clockwise Triangles",
        4 => "Counter-Clockwise Triangles",
        _ => "Undefined",
    };
    let partitioning = match declared(program, 150).unwrap_or(0) & 7 {
        1 => "Integer",
        2 => "Integer Power of 2",
        3 => "Odd Fractional",
        4 => "Even Fractional",
        _ => "Undefined",
    };
    out.push_str("// Tessellation Output Primitive  Partitioning Type \n");
    out.push_str("// ------------------------------ ------------------\n");
    let _ = writeln!(out, "// {primitive:<30} {partitioning:<18}\n//");
}

/// Whether a pixel program runs once per sample: an input interpolated per sample, or the sample index.
fn per_sample(program: &Decoded) -> bool {
    program.kind == ProgramType::Pixel
        && program.declarations.iter().any(|d| {
            matches!(d.kind, Declared::Input { interpolation: Some(6 | 7), .. } | Declared::Input { name: Some(10), .. })
        })
}

/// A signature part's elements, and whether the rows name their streams (where an element is on a stream other
/// than 0).
#[derive(Clone, Copy)]
pub(super) struct Elements<'a> {
    pub elements: &'a [SignatureElement],
    pub streams: bool,
}

/// What the header is written from.
pub(super) struct Header<'a> {
    pub program: &'a Decoded,
    pub rdef: Option<&'a Rdef>,
    /// The `SFI0` bits, 0 where there is no such part.
    pub features: u64,
    pub inputs: Option<Elements<'a>>,
    pub outputs: Option<Elements<'a>>,
    pub patch: Option<Elements<'a>>,
}

/// The comment block before the program.
pub(super) fn write(out: &mut String, h: &Header<'_>) {
    let program = h.program;
    let creator = h
        .rdef
        .map_or("Microsoft (R) D3D Shader Disassembler", |r| r.creator.as_str());
    let _ = write!(out, "//\n// Generated by {creator}\n//\n");
    notes(out, h.features, program);
    if let Some(rdef) = h.rdef {
        out.push_str("//\n");
        buffers(out, rdef);
        bindings(out, rdef, (program.major, program.minor) >= (5, 1));
    }
    let kind = program.kind;
    if let Some(patch) = &h.patch {
        signature(out, "Patch Constant", patch, kind == ProgramType::Hull, kind);
    }
    if let Some(inputs) = &h.inputs {
        signature(out, "Input", inputs, false, kind);
    }
    if let Some(outputs) = &h.outputs {
        signature(out, "Output", outputs, true, kind);
    }
    tessellation(out, program);
    if per_sample(program) {
        out.push_str("// Pixel Shader runs at sample frequency\n//\n");
    }
}
