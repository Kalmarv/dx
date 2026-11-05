//! The comment block before the program: the compiler, the buffer definitions, the resource bindings and the
//! signatures, as the `RDEF` and signature parts state them.
use std::fmt::Write;

use crate::Statistics;
use crate::decode::{Declared, Decoded, ProgramType};
use crate::reflection::{Rdef, RdefBinding, RdefType, RdefVariable, SignatureElement};

/// The column the `// Offset:` of a buffer member starts at.
const OFFSET_COLUMN: usize = 40;

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
fn variable(
    out: &mut String,
    indent: usize,
    name: &str,
    ty: &RdefType,
    offset: u32,
    size: Option<(u32, bool)>,
) {
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
        member_line(out, &format!("//{pad}}} {};", declarator(name, ty)), offset, size);
    } else {
        member_line(
            out,
            &format!("//{pad}{} {};", ty.type_name(), declarator(name, ty)),
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

/// The id column of a Shader Model 5.1 binding: the name its declaration and instructions use (`T0`, `CB1`).
fn binding_id(b: &RdefBinding) -> String {
    let prefix = b.register_prefix().to_ascii_uppercase();
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
        out.push_str(
            "// Name                                 Type  Format         Dim      HLSL Bind  Count\n",
        );
        out.push_str(
            "// ------------------------------ ---------- ------- ----------- -------------- ------\n",
        );
    }
    for b in &rdef.bindings {
        let bind = if b.space != 0 {
            format!("{}{},space{}", b.register_prefix(), b.register, b.space)
        } else {
            format!("{}{}", b.register_prefix(), b.register)
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
            b.type_name(),
            b.format_name(),
            b.dimension_name()
        );
        if sm51 {
            let _ = write!(out, "{:>7} ", binding_id(b));
        }
        let _ = writeln!(out, "{bind:>14} {count:>6} ");
    }
    out.push_str("//\n//\n");
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
        let sv = e.system_value_name(output, kind);
        let format = e.format_name();
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
            let register = special_register(e.system_value_for(output, kind));
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

/// The tessellation tables, from the `STAT` part (a container without one has none): the domain and control points
/// of a hull or domain program, and a hull program's output primitive and partitioning.
fn tessellation(out: &mut String, kind: ProgramType, stat: &Statistics) {
    let field = |value: Option<u32>| value.unwrap_or(0);
    let domain = match field(stat.tessellator_domain()) {
        0 => return,
        1 => "Isoline",
        2 => "Triangle",
        3 => "Quadrilateral",
        _ => "Undefined",
    };
    out.push_str("// Tessellation Domain   # of control points\n");
    out.push_str("// -------------------- --------------------\n");
    let _ = writeln!(out, "// {domain:<20} {:>20}\n//", field(stat.control_points()));
    if kind != ProgramType::Hull {
        return;
    }
    let primitive = match field(stat.tessellator_output_primitive()) {
        1 => "Point",
        2 => "Line",
        3 => "Clockwise Triangles",
        4 => "Counter-Clockwise Triangles",
        _ => "Undefined",
    };
    let partitioning = match field(stat.tessellator_partitioning()) {
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
    /// The `STAT` part, which the tessellation tables and the sample-frequency note come from.
    pub stat: Option<&'a Statistics>,
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
    if let Some(stat) = h.stat {
        tessellation(out, kind, stat);
        if stat.sample_frequency().is_some_and(|f| f != 0) {
            out.push_str("// Pixel Shader runs at sample frequency\n//\n");
        }
    }
}
