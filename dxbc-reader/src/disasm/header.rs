//! The comment block before the program: the compiler, the buffer definitions, the resource bindings and the
//! signatures, as the `RDEF` and signature parts state them.
use std::fmt::Write;

use crate::decode::{Declared, Decoded, ProgramType};
use crate::reflection::{Rdef, RdefBinding, RdefType, RdefVariable, SignatureElement};
use crate::{Interfaces, Statistics};

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
/// An unused interface pointer has no slot (`u32::MAX`): its offset and size are `N/A`.
fn member_line(out: &mut String, text: &str, offset: u32, size: Option<(u32, bool)>) {
    let none = offset == u32::MAX;
    let shown = |n: u32| if none { "N/A".to_owned() } else { n.to_string() };
    let _ = write!(out, "{text:<OFFSET_COLUMN$}// Offset: {:>4}", shown(offset));
    if let Some((size, unused)) = size {
        let _ = write!(out, " Size: {:>5}", shown(size));
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
        let _ = writeln!(out, "//{pad}{title}\n//{pad}{{");
        // a line of the inner indentation opens the members, where there are any
        let inner = indent.saturating_add(4);
        if !ty.members.is_empty() {
            let _ = writeln!(out, "//{}", " ".repeat(inner));
        }
        for (m, member) in ty.members.iter().enumerate() {
            let previous = m.checked_sub(1).and_then(|p| ty.members.get(p)).map(|p| &p.ty);
            if m != 0 && apart(&member.ty, previous) {
                let _ = writeln!(out, "//{}", " ".repeat(inner));
            }
            variable(
                out,
                inner,
                &member.name,
                &member.ty,
                offset.saturating_add(member.offset),
                None,
            );
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

/// Whether a variable or member after the first is set apart from the one before by a line of its own: a struct is,
/// and so is whatever follows a struct with no members.
fn apart(ty: &RdefType, previous: Option<&RdefType>) -> bool {
    ty.class == 5 || previous.is_some_and(|p| p.class == 5 && p.members.is_empty())
}

/// The variables of a buffer, each set apart from the one before as [`apart`] says.
fn buffer_variables(out: &mut String, variables: &[RdefVariable]) {
    for (i, v) in variables.iter().enumerate() {
        let previous = i.checked_sub(1).and_then(|p| variables.get(p)).map(|p| &p.ty);
        if i != 0 && apart(&v.ty, previous) {
            out.push_str("//   \n");
        }
        // D3D_SVF_USED
        let unused = v.flags & 2 == 0;
        variable(out, 3, &v.name, &v.ty, v.offset, Some((v.size, unused)));
        registers(out, v);
        // the default value's words, four a line
        if let Some(default) = &v.default {
            for (n, row) in default.as_chunks::<4>().0.chunks(4).enumerate() {
                out.push_str(if n == 0 { "//      =" } else { "//       " });
                for word in row {
                    let _ = write!(out, " 0x{:08x}", u32::from_le_bytes(*word));
                }
                out.push_str(" \n");
            }
        }
    }
}

/// The texture and sampler registers a class instance holds, on a line of their own at the offset column:
/// `// Textures:  t1-t2, Samplers: s0-s1`.
fn registers(out: &mut String, v: &RdefVariable) {
    let range = |prefix: &str, [start, count]: [u32; 2]| {
        if count > 1 {
            format!(
                "{prefix}{start}-{prefix}{}",
                start.saturating_add(count).saturating_sub(1)
            )
        } else {
            format!("{prefix}{start}")
        }
    };
    let mut parts = Vec::new();
    match v.textures[1] {
        0 => {}
        1 => parts.push(format!("{:<11}{}", "Texture:", range("t", v.textures))),
        _ => parts.push(format!("{:<11}{}", "Textures:", range("t", v.textures))),
    }
    match v.samplers[1] {
        0 => {}
        1 => parts.push(format!("Sampler: {}", range("s", v.samplers))),
        _ => parts.push(format!("Samplers: {}", range("s", v.samplers))),
    }
    if !parts.is_empty() {
        let _ = writeln!(out, "{:OFFSET_COLUMN$}// {}", "", parts.join(", "));
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
        // an output's lanes the program writes, the complement of its never-written mask (all four for an
        // `SV_ClipDistance` of three lanes that states none)
        let used = if output {
            !e.read_write_mask & 15
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
    /// The `IFCE` part of a program with class linkage.
    pub interfaces: Option<&'a Interfaces>,
    /// The container's digest is not the one [`dxcontainer::checksum`] computes: fxc stores another for a program that
    /// only runs with the debug layer (one with `printf`, `errorf` or `abort`), which Microsoft's disassembler notes.
    pub debug_layer: bool,
}

/// The comment block before the program.
pub(super) fn write(out: &mut String, h: &Header<'_>) {
    let program = h.program;
    let creator = h
        .rdef
        .map_or("Microsoft (R) D3D Shader Disassembler", |r| r.creator.as_str());
    let _ = write!(out, "//\n// Generated by {creator}\n//\n");
    if h.debug_layer {
        out.push_str("//\n// Note: SHADER WILL ONLY WORK WITH THE DEBUG SDK LAYER ENABLED.\n//\n");
    }
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
    if let Some(interfaces) = h.interfaces {
        classes(out, interfaces);
    }
}

/// The class linkage tables of an `IFCE` part: the class types, the instances and the interface slots.
fn classes(out: &mut String, ifce: &Interfaces) {
    if !ifce.types.is_empty() {
        out.push_str(
            "//\n// Available Class Types:\n//\n\
             // Name                             ID CB Stride Texture Sampler\n\
             // ------------------------------ ---- --------- ------- -------\n",
        );
        for (id, t) in ifce.types.iter().enumerate() {
            let _ = writeln!(
                out,
                "// {:<30} {id:>4} {:>9} {:>7} {:>7}",
                t.name, t.stride, t.textures, t.samplers
            );
        }
    }
    if !ifce.instances.is_empty() {
        out.push_str(
            "//\n// Available Class Instances:\n//\n\
             // Name                        Type CB CB Offset Texture Sampler\n\
             // --------------------------- ---- -- --------- ------- -------\n",
        );
        let register = |r: Option<u16>| r.map_or_else(|| "-".to_owned(), |r| r.to_string());
        for i in &ifce.instances {
            let name = if i.count > 1 {
                format!("{}[{}]", i.name, i.count)
            } else {
                i.name.clone()
            };
            let _ = writeln!(
                out,
                "// {name:<27} {:>4} {:>2} {:>9} {:>7} {:>7}",
                i.ty,
                register(i.buffer),
                register(i.offset),
                register(i.texture),
                register(i.sampler)
            );
        }
    }
    if ifce.slots.is_empty() {
        return;
    }
    let rule = "// +----------+---------+---------------------------------------\n";
    let _ = write!(
        out,
        "//\n// Interface slots, {} total:\n//\n//             Slots\n{rule}",
        ifce.slot_count
    );
    // Microsoft's disassembler writes eight entries a row and skips the ninth, and moves the first slot of the next
    // record on by this record's span for every row it writes, not once
    let mut slot: u32 = 0;
    for record in &ifce.slots {
        let mut start = 0;
        let mut first = true;
        while start < record.types.len() {
            let end = record.types.len().min(start.saturating_add(8));
            let label = if !first {
                String::new()
            } else if record.span > 1 {
                format!(
                    "{slot:>4}-{:<4}",
                    slot.saturating_add(record.span).saturating_sub(1)
                )
            } else {
                format!("{slot:>4}")
            };
            let mut types = String::new();
            let mut tables = String::new();
            for (t, f) in record.types.iter().zip(&record.tables).take(end).skip(start) {
                let _ = write!(types, "{t:<5}");
                let _ = write!(tables, "{f:<5}");
            }
            let _ = write!(
                out,
                "// | Type ID  |{label:<9}|{types}\n// | Table ID |         |{tables}\n"
            );
            slot = slot.saturating_add(record.span);
            first = false;
            start = start.saturating_add(9);
        }
        out.push_str(rule);
    }
}
