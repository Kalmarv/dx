//! The comment header dxc's disassembler prints before the module (`dxcdisassembler.cpp`): the feature flags, the
//! signature parts, the debug name and hash, the pipeline state validation runtime info, and from the program's
//! metadata its signatures, buffer layouts, resource bindings, view-id state and a library's subobjects.
use std::collections::{BTreeMap, BTreeSet};
use std::fmt::Write as _;

use super::layout::Layout;
use crate::module::{Module, Type, TypeId};
use crate::reflection::{self, Binding, FieldAnnotation};
use crate::{Result, error, psv, rdat};

/// `left_justify`: the text, padded with spaces to `width`.
fn left(s: &mut String, text: &str, width: usize) {
    s.push_str(text);
    s.extend(std::iter::repeat_n(' ', width.saturating_sub(text.len())));
}

/// `right_justify`: the text, after spaces to `width`.
fn right(s: &mut String, text: &str, width: usize) {
    s.extend(std::iter::repeat_n(' ', width.saturating_sub(text.len())));
    s.push_str(text);
}

/// The components of a 4-bit mask as letters, each in its place (`x z `).
fn mask_letters(mask: u8) -> String {
    ['x', 'y', 'z', 'w']
        .iter()
        .enumerate()
        .map(|(i, c)| if mask & (1 << i) != 0 { *c } else { ' ' })
        .collect()
}

// ---- the container's parts ---------------------------------------------------------------------------------------

/// `PrintFeatureInfo`: the `SFI0` part's flags, the required ones (bits 0 to 39) and then the optional ones (from bit
/// 40), each set bit by its name ([`dxcontainer::feature_name`]); a bit with no name is not written.
pub(super) fn feature_info(s: &mut String, part: &[u8]) -> Result<()> {
    let flags = part
        .get(..8)
        .and_then(|b| <[u8; 8]>::try_from(b).ok())
        .map(u64::from_le_bytes)
        .ok_or_else(|| error(0, "SFI0: the part is shorter than its flags"))?;
    if flags == 0 {
        return Ok(());
    }
    let names = |bits: std::ops::Range<u32>| {
        bits.filter(|&bit| flags >> bit & 1 != 0)
            .filter_map(|bit| dxcontainer::feature_name(dxcontainer::Bytecode::Dxil, bit))
    };
    s.push_str(";\n; Note: shader requires additional functionality:\n");
    for name in names(0..40) {
        let _ = writeln!(s, ";       {name}");
    }
    s.push_str(";\n");
    if flags >> 40 == 0 {
        return Ok(());
    }
    s.push_str("; Note: shader has optional feature flags set:\n");
    for name in names(40..64) {
        let _ = writeln!(s, ";       {name}");
    }
    s.push_str(";\n");
    Ok(())
}

/// `PrintSignature`: an `ISG1`, `OSG1` or `PSG1` part.
pub(super) fn part_signature(s: &mut String, name: &str, part: &[u8], input: bool) -> Result<()> {
    let _ = write!(
        s,
        ";\n; {name} signature:\n;\n; Name                 Index   Mask Register SysValue  Format   Used\n\
         ; -------------------- ----- ------ -------- -------- ------- ------\n"
    );
    let elements = reflection::signature(part)?;
    if elements.is_empty() {
        s.push_str("; no parameters\n");
        return Ok(());
    }
    let streams = elements.iter().any(|e| e.stream != 0);
    for e in &elements {
        s.push_str("; ");
        if streams {
            let _ = write!(s, "m{}:", e.stream);
            left(s, &e.name, 17);
        } else {
            left(s, &e.name, 20);
        }
        let _ = write!(s, " {:5}", e.index);
        let unplaced = e.register == u32::MAX;
        if unplaced {
            s.push_str("    N/A");
            let n = e.name.to_ascii_lowercase();
            s.push_str(match n.as_str() {
                "sv_depth" => "   oDepth",
                "sv_depthgreaterequal" => " oDepthGE",
                "sv_depthlessequal" => " oDepthLE",
                "sv_coverage" => "    oMask",
                "sv_stencilref" => "    oStencilRef",
                _ if e.system_value == 7 => "   primID",
                _ => "  special",
            });
        } else {
            let _ = write!(s, "   {} {:8}", mask_letters(e.mask), e.register);
        }
        right(s, e.system_value_name(), 9);
        right(s, e.format_name(), 8);
        // an input's components always read; an output's ones it may write (the stored mask is those it never does)
        let used = if input {
            e.read_write_mask
        } else {
            !e.read_write_mask
        };
        if unplaced {
            s.push_str(if used != 0 { "    YES" } else { "     NO" });
        } else {
            let _ = write!(s, "   {}", mask_letters(used));
        }
        s.push('\n');
    }
    s.push_str(";\n");
    Ok(())
}

/// The `ILDN` part: its flags (u16), the name's length (u16) and the name with its terminating zero, padded to four
/// bytes; a part of another size is `corruption detected`.
pub(super) fn debug_name(s: &mut String, part: &[u8]) {
    let length = part
        .get(2..4)
        .and_then(|b| <[u8; 2]>::try_from(b).ok())
        .map(u16::from_le_bytes);
    let valid = length.is_some_and(|n| {
        let expected = usize::from(n).saturating_add(5).next_multiple_of(4);
        part.len() >= 8 && part.len() == expected
    });
    if !valid {
        s.push_str("; shader debug name present; corruption detected\n");
        return;
    }
    let name = part.get(4..).unwrap_or_default();
    let end = name.iter().position(|b| *b == 0).unwrap_or(name.len());
    let name = String::from_utf8_lossy(name.get(..end).unwrap_or_default());
    if !name.is_empty() {
        let _ = writeln!(s, "; shader debug name: {name}");
    }
}

/// The `HASH` part: its flags (bit 0: the hash includes the source) and the 16-byte digest.
pub(super) fn hash(s: &mut String, part: &[u8]) -> Result<()> {
    let digest = part
        .get(4..20)
        .ok_or_else(|| error(0, "HASH: the part is shorter than its digest"))?;
    s.push_str("; shader hash: ");
    for b in digest {
        let _ = write!(s, "{b:02x}");
    }
    if part.first().is_some_and(|f| f & 1 != 0) {
        s.push_str(" (includes source)");
    }
    s.push('\n');
    Ok(())
}

/// `PrintPipelineStateValidationRuntimeInfo`: the `PSV0` part's runtime info, for a program of `kind` (the program
/// header's shader kind, which the runtime info's own stage overrides).
pub(super) fn psv_runtime(s: &mut String, p: &psv::Psv, kind: u8) -> Result<()> {
    let r = &p.runtime;
    let [w0, w1, w2, w3] = r.stage_words;
    let byte = |w: u32, i: u32| w.wrapping_shr(i.wrapping_mul(8)) & 0xFF;
    let flag = |w: u32, i: u32| u32::from(byte(w, i) != 0);
    s.push_str(";\n; Pipeline Runtime Information: \n;\n;PSVRuntimeInfo:\n");
    let threads = |s: &mut String| {
        if let Some([x, y, z]) = r.num_threads {
            let _ = writeln!(s, "; NumThreads=({x},{y},{z})");
        }
        if let Some(n) = r.group_shared_bytes {
            let _ = writeln!(s, "; NumBytesGroupSharedMemory: {n}");
        }
    };
    match r.signature.map_or(kind, |g| g.stage) {
        3 => {
            let _ = writeln!(
                s,
                "; Hull Shader\n; InputControlPointCount={w0}\n; OutputControlPointCount={w1}"
            );
            let domain = match w2 {
                1 => "isoline",
                2 => "tri",
                3 => "quad",
                _ => "invalid",
            };
            let primitive = match w3 {
                1 => "point",
                2 => "line",
                3 => "triangle_cw",
                4 => "triangle_ccw",
                _ => "invalid",
            };
            let _ = writeln!(s, "; Domain={domain}\n; OutputPrimitive={primitive}");
        }
        4 => {
            let _ = writeln!(
                s,
                "; Domain Shader\n; InputControlPointCount={w0}\n; OutputPositionPresent={}",
                flag(w1, 0)
            );
        }
        2 => {
            let input = match w0 {
                1 => "point".to_owned(),
                2 => "line".to_owned(),
                3 => "triangle".to_owned(),
                6 => "lineadj".to_owned(),
                7 => "triangleadj".to_owned(),
                8..=39 => format!("patch{}", w0.wrapping_sub(7)),
                _ => "invalid".to_owned(),
            };
            let topology = match w1 {
                1 => "point",
                3 => "line",
                5 => "triangle",
                _ => "invalid",
            };
            let _ = writeln!(
                s,
                "; Geometry Shader\n; InputPrimitive={input}\n; OutputTopology={topology}\n\
                 ; OutputStreamMask={w2}\n; OutputPositionPresent={}",
                flag(w3, 0)
            );
        }
        1 => {
            let _ = writeln!(s, "; Vertex Shader\n; OutputPositionPresent={}", flag(w0, 0));
        }
        0 => {
            let _ = writeln!(
                s,
                "; Pixel Shader\n; DepthOutput={}\n; SampleFrequency={}",
                flag(w0, 0),
                flag(w0, 1)
            );
        }
        5 => {
            s.push_str("; Compute Shader\n");
            threads(s);
        }
        14 => {
            s.push_str("; Amplification Shader\n");
            threads(s);
        }
        13 => {
            s.push_str("; Mesh Shader\n");
            if let Some(g) = r.signature {
                let topology = match g.stage_data >> 8 {
                    0 => "undefined",
                    1 => "line",
                    2 => "triangle",
                    _ => "invalid",
                };
                let _ = writeln!(s, "; MeshOutputTopology={topology}");
            }
            threads(s);
        }
        _ => {}
    }
    if r.min_wave_lanes == r.max_wave_lanes {
        let _ = writeln!(s, "; WaveSize={}", r.min_wave_lanes);
    } else {
        let _ = writeln!(
            s,
            "; MinimumExpectedWaveLaneCount: {}\n; MaximumExpectedWaveLaneCount: {}",
            r.min_wave_lanes, r.max_wave_lanes
        );
    }
    if let Some(g) = r.signature {
        let [inputs, outputs, patch] = g.element_counts;
        let _ = writeln!(
            s,
            "; UsesViewID: {}\n; SigInputElements: {inputs}\n; SigOutputElements: {outputs}\n\
             ; SigPatchConstOrPrimElements: {patch}\n; SigInputVectors: {}",
            g.uses_view_id, g.input_vectors
        );
        for (i, v) in g.output_vectors.iter().enumerate() {
            let _ = writeln!(s, "; SigOutputVectors[{i}]: {v}");
        }
    }
    if let Some(name) = r.entry_name {
        let _ = writeln!(s, "; EntryFunctionName: {}", p.string(name)?);
    }
    s.push_str(";\n");
    Ok(())
}

// ---- the program's metadata ------------------------------------------------------------------------------------

/// `InterpolationMode::GetName`.
fn interpolation_name(mode: u8) -> &'static str {
    match mode {
        0 => "",
        1 => "nointerpolation",
        2 => "linear",
        3 => "centroid",
        4 => "noperspective",
        5 => "noperspective centroid",
        6 => "sample",
        7 => "noperspective sample",
        _ => "invalid",
    }
}

/// `PrintDxilSignature`: a signature of the entry point's metadata, where it has elements.
fn dxil_signature(
    s: &mut String,
    name: &str,
    elements: &[reflection::Element],
    tags: &[reflection::ElementTags],
) {
    if elements.is_empty() {
        return;
    }
    let _ = write!(
        s,
        ";\n; {name} signature:\n;\n; Name                 Index             InterpMode DynIdx\n\
         ; -------------------- ----- ---------------------- ------\n"
    );
    for (i, e) in elements.iter().enumerate() {
        s.push_str("; ");
        left(s, &e.name, 20);
        let _ = write!(s, " {:5} ", e.index);
        right(s, interpolation_name(e.interpolation), 22);
        s.push_str("   ");
        let mask = tags.get(i).and_then(|t| t.dynamic_index_mask).unwrap_or(0);
        let compact: String = ['x', 'y', 'z', 'w']
            .iter()
            .enumerate()
            .filter(|(b, _)| mask & (1 << b) != 0)
            .map(|(_, c)| *c)
            .collect();
        right(s, &compact, 4);
        s.push('\n');
    }
}

/// The signatures of a program that is not a library: its inputs and outputs, and a hull or domain program's patch
/// constants or a mesh program's primitive outputs.
pub(super) fn dxil_signatures(s: &mut String, m: &Module, kind: &str) -> Result<()> {
    let (inputs, outputs) = reflection::elements(m)?;
    let patch = reflection::patch_elements(m)?;
    let [input_tags, output_tags, patch_tags] = reflection::element_tags(m)?;
    dxil_signature(s, "Input", &inputs, &input_tags);
    if kind == "ms" {
        dxil_signature(s, "Vertex Output", &outputs, &output_tags);
        dxil_signature(s, "Primitive Output", &patch, &patch_tags);
    } else {
        dxil_signature(s, "Output", &outputs, &output_tags);
        dxil_signature(s, "Patch Constant", &patch, &patch_tags);
    }
    Ok(())
}

/// `CompType::GetHLSLName`.
fn component_hlsl_name(c: u32, min_precision: bool) -> &'static str {
    match (c, min_precision) {
        (1, _) => "bool",
        (2, false) => "int16_t",
        (2, true) => "min16i",
        (3, false) => "uint16_t",
        (3, true) => "min16ui",
        (4, _) => "int",
        (5, _) => "uint",
        (6, _) => "int64_t",
        (7, _) => "uint64_t",
        (8, false) => "half",
        (8, true) => "min16float",
        (9, _) => "float",
        (10, _) => "double",
        (11, false) => "snorm_half",
        (11, true) => "snorm_min16f",
        (12, false) => "unorm_half",
        (12, true) => "unorm_min16f",
        (13, _) => "snorm_float",
        (14, _) => "unorm_float",
        (15, _) => "snorm_double",
        (16, _) => "unorm_double",
        (17, _) => "int8_t_packed",
        (18, _) => "uint8_t_packed",
        _ => "unknown",
    }
}

/// `PrintResourceBindings`.
fn resource_bindings(s: &mut String, bindings: &[Binding]) {
    s.push_str(
        ";\n; Resource Bindings:\n;\n\
         ; Name                                 Type  Format         Dim      ID      HLSL Bind  Count\n\
         ; ------------------------------ ---------- ------- ----------- ------- -------------- ------\n",
    );
    for b in bindings {
        s.push_str("; ");
        left(s, &b.name, 31);
        right(s, b.class_name(), 10);
        right(s, b.format_name(), 8);
        right(s, &b.dimension_name(), 12);
        right(s, &b.id_name(), 8);
        right(s, &b.bind_name(), 15);
        if b.range.count == u32::MAX {
            right(s, "unbounded", 6);
        } else {
            right(s, &b.range.count.to_string(), 6);
        }
        s.push('\n');
    }
    s.push_str(";\n");
}

/// The type system and data layout the buffer layouts are printed with.
struct Types<'m> {
    m: &'m Module,
    layout: Layout,
    min_precision: bool,
}

impl Types<'_> {
    fn struct_name(&self, t: TypeId) -> &str {
        match self.m.types.get(t) {
            Some(Type::Struct { name: Some(n), .. }) => n,
            _ => "",
        }
    }

    /// `HLMatrixType::isa`: an HLSL matrix the compiler has not lowered.
    fn is_matrix(&self, t: TypeId) -> bool {
        self.struct_name(t).starts_with("class.matrix.")
    }

    /// `PrintStructLayout`; `cbuffer` lays the fields out by their annotated offsets, otherwise by the data layout.
    #[allow(clippy::too_many_arguments)]
    fn struct_layout(
        &self,
        s: &mut String,
        t: TypeId,
        cbuffer: bool,
        variable: &str,
        offset: u64,
        indent: usize,
        offset_indent: usize,
        size: u64,
    ) -> Result<()> {
        let pad = " ".repeat(indent);
        let _ = write!(s, ";{pad}struct {}\n;{pad}{{\n;\n", self.struct_name(t));
        let field_pad = " ".repeat(indent.saturating_add(4));
        match reflection::struct_annotation(self.m, t)? {
            None if size == 0 => {
                let _ = writeln!(s, ";{field_pad}/* empty struct */");
            }
            None => {
                let _ = writeln!(s, ";{field_pad}[{size} x i8] (type annotation not present)");
            }
            Some(annotation) => {
                let Some(Type::Struct { elements, .. }) = self.m.types.get(t) else {
                    return Err(error(self.m.at, "the layout of a type that is not a struct"));
                };
                let offsets = if cbuffer {
                    Vec::new()
                } else {
                    self.layout.struct_layout(self.m, t)?.2
                };
                for (i, (e, f)) in elements.iter().zip(&annotation.fields).enumerate() {
                    let field_offset = if cbuffer {
                        offset.saturating_add(u64::from(f.offset))
                    } else {
                        offset.saturating_add(offsets.get(i).copied().unwrap_or(0))
                    };
                    self.field_layout(
                        s,
                        *e,
                        f,
                        cbuffer,
                        field_offset,
                        indent.saturating_add(4),
                        offset_indent.saturating_sub(4),
                        0,
                    )?;
                }
            }
        }
        let _ = write!(s, ";{pad}\n;{pad}}} ");
        left(s, &format!("{variable};"), offset_indent.saturating_sub(2));
        let _ = write!(s, "; Offset:{offset:5}");
        if size != 0 {
            let _ = write!(s, " Size: {size:5}");
        }
        s.push_str("\n;\n");
        Ok(())
    }

    /// `PrintFieldLayout`.
    #[allow(clippy::too_many_arguments)]
    fn field_layout(
        &self,
        s: &mut String,
        t: TypeId,
        f: &FieldAnnotation,
        cbuffer: bool,
        offset: u64,
        indent: usize,
        offset_indent: usize,
        size: u64,
    ) -> Result<()> {
        let types = &self.m.types;
        let is_struct = |t: TypeId| matches!(types.get(t), Some(Type::Struct { .. }));
        if is_struct(t) && f.matrix.is_none() {
            return self.struct_layout(s, t, cbuffer, &f.name, offset, indent, offset_indent, 0);
        }
        let mut element = t;
        let mut array_size = 0u64;
        let mut levels = 0u32;
        if !self.is_matrix(element) && matches!(types.get(element), Some(Type::Array(..))) {
            array_size = 1;
            while !self.is_matrix(element)
                && let Some(Type::Array(n, e)) = types.get(element)
            {
                array_size = array_size.saturating_mul(*n);
                element = *e;
                levels = levels.saturating_add(1);
            }
        }
        if let Some((rows, columns, orientation)) = f.matrix {
            match orientation {
                1 => array_size = array_size.checked_div(u64::from(rows)).unwrap_or(0),
                2 => array_size = array_size.checked_div(u64::from(columns)).unwrap_or(0),
                _ => {}
            }
            match types.get(element) {
                Some(Type::Vector(_, e)) => element = *e,
                // a high-level `class.matrix.*` struct, which dxc 1.5 and earlier leave in a library's buffer types:
                // dxc takes its element type, which only tells it apart from a struct field, as `is_matrix` does
                Some(Type::Struct { .. }) if self.is_matrix(element) => {}
                Some(Type::Struct { .. }) => {
                    return Err(error(
                        self.m.at,
                        format!(
                            "the buffer field {} has a matrix annotation and the struct type {}, which is not a matrix",
                            f.name,
                            self.struct_name(element)
                        ),
                    ));
                }
                _ => {}
            }
            if levels == 1 {
                array_size = 0;
            }
        }
        if !self.is_matrix(element) && is_struct(element) {
            let mut name = f.name.clone();
            if array_size != 0 {
                let _ = write!(name, "[{array_size}]");
            }
            name.push(';');
            return self.struct_layout(s, element, cbuffer, &name, offset, indent, offset_indent, 0);
        }
        let _ = write!(s, ";{}", " ".repeat(indent));
        left(s, &self.type_and_name(t, f, array_size), offset_indent);
        let _ = write!(s, "; Offset:{offset:5}");
        if size != 0 {
            let _ = write!(s, " Size: {size:5}");
        }
        s.push('\n');
        Ok(())
    }

    /// `PrintTypeAndName`.
    fn type_and_name(&self, t: TypeId, f: &FieldAnnotation, array_size: u64) -> String {
        let mut t = t;
        while let Some(Type::Array(_, e)) = self.m.types.get(t) {
            t = *e;
        }
        let component = component_hlsl_name(f.component.unwrap_or(0), self.min_precision);
        let mut out = String::new();
        if let Some((rows, columns, orientation)) = f.matrix {
            out.push_str(match orientation {
                1 => "row_major ",
                2 => "column_major ",
                _ => "",
            });
            let _ = write!(out, "{component}{rows}x{columns}");
        } else if let Some(Type::Vector(n, _)) = self.m.types.get(t) {
            let _ = write!(out, "{component}{n}");
        } else {
            out.push_str(component);
        }
        let _ = write!(out, " {}", f.name);
        if array_size != 0 {
            let _ = write!(out, "[{array_size}]");
        }
        out.push(';');
        out
    }

    /// The struct a resource's variable points to, through any arrays of it.
    fn resource_struct(&self, r: &Binding) -> Result<TypeId> {
        let mut t =
            r.ty.ok_or_else(|| error(self.m.at, format!("the resource {} has no type", r.name)))?;
        while let Some(Type::Array(_, e)) = self.m.types.get(t) {
            t = *e;
        }
        match self.m.types.get(t) {
            Some(Type::Struct { .. }) => Ok(t),
            _ => Err(error(
                self.m.at,
                format!("the resource {} is not of a struct type", r.name),
            )),
        }
    }

    /// `PrintCBufferDefinition` and `PrintTBufferDefinition`.
    fn constant_buffer(&self, s: &mut String, r: &Binding, keyword: &str) -> Result<()> {
        let t = self.resource_struct(r)?;
        let _ = write!(s, "; {keyword} {}\n; {{\n;\n", r.name);
        match reflection::struct_annotation(self.m, t)? {
            None if keyword == "tbuffer" => s.push_str(";   (type annotation not present)\n;\n"),
            None => {
                let _ = write!(
                    s,
                    ";   [{} x i8] (type annotation not present)\n;\n",
                    r.range.extra
                );
            }
            Some(a) => {
                let size = if keyword == "tbuffer" {
                    a.size
                } else {
                    r.range.extra
                };
                self.struct_layout(s, t, true, &r.name, 0, 3, 50, u64::from(size))?;
            }
        }
        s.push_str("; }\n;\n");
        Ok(())
    }

    /// `PrintStructBufferDefinition`.
    fn structured_buffer(&self, s: &mut String, r: &Binding) -> Result<()> {
        let _ = write!(s, "; Resource bind info for {}\n; {{\n;\n", r.name);
        let outer = self.resource_struct(r)?;
        let element = match self.m.types.get(outer) {
            Some(Type::Struct { elements, .. }) => elements.first().copied(),
            _ => None,
        }
        .ok_or_else(|| {
            error(
                self.m.at,
                format!("the structured buffer {} has no element", r.name),
            )
        })?;
        let element_is_struct = matches!(self.m.types.get(element), Some(Type::Struct { .. }));
        if !element_is_struct || self.is_matrix(element) {
            match reflection::struct_annotation(self.m, outer)? {
                None => {
                    let _ = writeln!(
                        s,
                        ";   [{} x i8] (type annotation not present)",
                        self.layout.alloc_size(self.m, outer)?
                    );
                }
                Some(a) => {
                    let mut field = a.fields.first().cloned().ok_or_else(|| {
                        error(self.m.at, "a structured buffer's annotation without its field")
                    })?;
                    field.name = "$Element".to_owned();
                    let size = self.layout.alloc_size(self.m, outer)?;
                    self.field_layout(s, element, &field, true, 0, 3, 50, size)?;
                }
            }
            s.push_str(";\n");
        } else {
            match reflection::struct_annotation(self.m, element)? {
                None => {
                    let _ = writeln!(
                        s,
                        ";   [{} x i8] (type annotation not present)",
                        self.layout.alloc_size(self.m, element)?
                    );
                }
                Some(_) => {
                    let size = self.layout.alloc_size(self.m, element)?;
                    self.struct_layout(s, element, false, "$Element", 0, 3, 50, size)?;
                }
            }
        }
        s.push_str("; }\n;\n");
        Ok(())
    }
}

/// `PrintBufferDefinitions`, `PrintResourceBindings` and `PrintViewIdState` of the reflection module.
pub(super) fn reflection_sections(s: &mut String, m: &Module) -> Result<()> {
    let flags = reflection::module_shader_flags(m)?.unwrap_or(0);
    let types = Types {
        m,
        layout: Layout::new(m.datalayout.as_deref().unwrap_or(""), m.at)?,
        // without native low precision (shader flag 23) the 16-bit types are the minimum-precision ones
        min_precision: flags & (1 << 23) == 0,
    };
    let resources = reflection::bindings(m)?;
    s.push_str(";\n; Buffer Definitions:\n;\n");
    for r in resources.iter().filter(|r| r.range.class == 2) {
        types.constant_buffer(s, r, "cbuffer")?;
    }
    for class in [0, 1] {
        for r in resources.iter().filter(|r| r.range.class == class) {
            match r.range.extra {
                12 => types.structured_buffer(s, r)?,
                15 if class == 0 => types.constant_buffer(s, r, "tbuffer")?,
                _ => {}
            }
        }
    }
    resource_bindings(s, &resources);
    view_id_state(s, m, flags)
}

/// `PrintViewIdState`: what `dx.viewIdState` serialises.
fn view_id_state(s: &mut String, m: &Module, flags: u64) -> Result<()> {
    let Some(data) = reflection::view_id_state(m)? else {
        return Ok(());
    };
    let kind = reflection::shader_model(m)?
        .map(|(k, _, _)| k)
        .unwrap_or_default();
    let (gs, hs, ds, ms) = (kind == "gs", kind == "hs", kind == "ds", kind == "ms");
    // the view id is in use where shader flag 21 says so: only then are the dependencies on it stored
    let uses_view_id = flags & (1 << 21) != 0;
    let fail = || error(m.at, "dx.viewIdState is shorter than its counts");
    let mut words = data.iter().copied();
    let mut next = || words.next().ok_or_else(fail);
    let inputs = next()?;
    let streams = if gs { 4 } else { 1 };
    let mut outputs = [0u32; 4];
    let mut on_view_id: [BTreeSet<u32>; 4] = Default::default();
    let mut contributing: [BTreeMap<u32, BTreeSet<u32>>; 4] = Default::default();
    let read_dependent = |next: &mut dyn FnMut() -> Result<u32>, count: u32| -> Result<BTreeSet<u32>> {
        let mut set = BTreeSet::new();
        for w in 0..count.div_ceil(32) {
            let bits = next()?;
            let first = w.saturating_mul(32);
            for b in 0..32.min(count.saturating_sub(first)) {
                if bits & 1u32.wrapping_shl(b) != 0 {
                    set.insert(first.saturating_add(b));
                }
            }
        }
        Ok(set)
    };
    let read_contributing = |next: &mut dyn FnMut() -> Result<u32>,
                             inputs: u32,
                             outputs: u32|
     -> Result<BTreeMap<u32, BTreeSet<u32>>> {
        let mut map: BTreeMap<u32, BTreeSet<u32>> = BTreeMap::new();
        let words_per_input = outputs.div_ceil(32);
        for input in 0..inputs {
            let row: Vec<u32> = (0..words_per_input).map(|_| next()).collect::<Result<_>>()?;
            for output in 0..outputs {
                let word = row
                    .get(usize::try_from(output / 32).unwrap_or(usize::MAX))
                    .copied()
                    .unwrap_or(0);
                if word & 1u32.wrapping_shl(output % 32) != 0 {
                    map.entry(output).or_default().insert(input);
                }
            }
        }
        Ok(map)
    };
    for ((count, on_view_id), contributing) in outputs
        .iter_mut()
        .zip(on_view_id.iter_mut())
        .zip(contributing.iter_mut())
        .take(streams)
    {
        *count = next()?;
        if uses_view_id {
            *on_view_id = read_dependent(&mut next, *count)?;
        }
        *contributing = read_contributing(&mut next, inputs, *count)?;
    }
    let mut patch = 0;
    let mut patch_on_view_id = BTreeSet::new();
    let mut patch_contributing = BTreeMap::new();
    let mut patch_inputs_contributing = BTreeMap::new();
    if hs || ds || ms {
        patch = next()?;
        if hs || ms {
            if uses_view_id {
                patch_on_view_id = read_dependent(&mut next, patch)?;
            }
            patch_contributing = read_contributing(&mut next, inputs, patch)?;
        } else {
            patch_inputs_contributing = read_contributing(&mut next, patch, outputs[0])?;
        }
    }
    let _ = write!(s, ";\n; ViewId state:\n;\n; Number of inputs: {inputs}");
    if gs {
        let _ = write!(
            s,
            ", outputs per stream: {{ {}, {}, {}, {} }}",
            outputs[0], outputs[1], outputs[2], outputs[3]
        );
    } else {
        let _ = write!(s, ", outputs: {}", outputs[0]);
    }
    if hs || ds {
        let _ = write!(s, ", patchconst: {patch}");
    } else if ms {
        let _ = write!(s, ", primitive outputs: {patch}");
    }
    s.push('\n');
    let dependent = |s: &mut String, name: &str, set: &BTreeSet<u32>| {
        let list: Vec<String> = set.iter().map(u32::to_string).collect();
        let _ = writeln!(s, "; {name} dependent on ViewId: {{ {} }}", list.join(", "));
    };
    let contributing_to =
        |s: &mut String, inputs: &str, outputs: &str, map: &BTreeMap<u32, BTreeSet<u32>>| {
            let _ = writeln!(s, "; {inputs} contributing to computation of {outputs}:");
            for (output, set) in map {
                let list: Vec<String> = set.iter().map(u32::to_string).collect();
                let _ = writeln!(
                    s,
                    ";   output {output} depends on inputs: {{ {} }}",
                    list.join(", ")
                );
            }
        };
    if gs {
        for (i, (count, set)) in outputs.iter().zip(&on_view_id).enumerate() {
            if *count > 0 {
                dependent(s, &format!("Outputs for Stream {i}"), set);
            }
        }
    } else {
        dependent(s, "Outputs", &on_view_id[0]);
    }
    if hs {
        dependent(s, "PCOutputs", &patch_on_view_id);
    } else if ms {
        dependent(s, "Primitive Outputs", &patch_on_view_id);
    }
    if gs {
        for (i, (count, map)) in outputs.iter().zip(&contributing).enumerate() {
            if *count > 0 {
                contributing_to(s, "Inputs", &format!("Outputs for Stream {i}"), map);
            }
        }
    } else {
        contributing_to(s, "Inputs", "Outputs", &contributing[0]);
    }
    if hs {
        contributing_to(s, "Inputs", "PCOutputs", &patch_contributing);
    } else if ms {
        contributing_to(s, "Inputs", "Primitive Outputs", &patch_contributing);
    } else if ds {
        contributing_to(s, "PCInputs", "Outputs", &patch_inputs_contributing);
    }
    s.push_str(";\n");
    Ok(())
}

/// `PrintFlags`: each set bit's name, lowest first, joined by ` | `; `0` for none.
fn flags_text(flags: u32, name: fn(u32) -> &'static str) -> String {
    if flags == 0 {
        return "0".to_owned();
    }
    (0..32)
        .map(|b| 1u32 << b)
        .filter(|bit| flags & bit != 0)
        .map(name)
        .collect::<Vec<_>>()
        .join(" | ")
}

/// `PrintSubobjects`: a library's subobjects from its `RDAT` part.
pub(super) fn subobjects(s: &mut String, subobjects: &[rdat::Subobject]) {
    if subobjects.is_empty() {
        return;
    }
    s.push_str(";\n; Subobjects:\n;\n");
    for o in subobjects {
        use rdat::Subobject as S;
        let (kind, name, body) = match o {
            S::StateObjectConfig { name, flags } => (
                "StateObjectConfig",
                name,
                flags_text(*flags, |f| match f {
                    1 => "STATE_OBJECT_FLAG_ALLOW_LOCAL_DEPENDENCIES_ON_EXTERNAL_DEFINITIONS",
                    2 => "STATE_OBJECT_FLAG_ALLOW_EXTERNAL_DEPENDENCIES_ON_LOCAL_DEFINITIONS",
                    4 => "STATE_OBJECT_FLAG_ALLOW_STATE_OBJECT_ADDITIONS",
                    _ => "<invalid StateObjectFlag>",
                }),
            ),
            S::GlobalRootSignature { name, signature } => (
                "GlobalRootSignature",
                name,
                format!("<{} bytes>", signature.len()),
            ),
            S::LocalRootSignature { name, signature } => {
                ("LocalRootSignature", name, format!("<{} bytes>", signature.len()))
            }
            S::ExportsAssociation {
                name,
                subobject,
                exports,
            } => {
                let list: Vec<String> = exports.iter().map(|e| format!("\"{e}\"")).collect();
                (
                    "SubobjectToExportsAssociation",
                    name,
                    format!("\"{subobject}\", {{ {} }} ", list.join(", ")),
                )
            }
            S::ShaderConfig {
                name,
                max_payload_bytes,
                max_attribute_bytes,
            } => (
                "RaytracingShaderConfig",
                name,
                format!(
                    "MaxPayloadSizeInBytes = {max_payload_bytes}, MaxAttributeSizeInBytes = {max_attribute_bytes}"
                ),
            ),
            S::PipelineConfig {
                name,
                max_recursion_depth,
            } => (
                "RaytracingPipelineConfig",
                name,
                format!("MaxTraceRecursionDepth = {max_recursion_depth}"),
            ),
            S::HitGroup {
                name,
                kind,
                any_hit,
                closest_hit,
                intersection,
            } => (
                "HitGroup",
                name,
                format!(
                    "HitGroupType = {}, Anyhit = \"{}\", Closesthit = \"{}\", Intersection = \"{}\"",
                    match kind {
                        0 => "Triangle",
                        1 => "ProceduralPrimitive",
                        _ => "<invalid HitGroupType>",
                    },
                    any_hit.as_deref().unwrap_or(""),
                    closest_hit.as_deref().unwrap_or(""),
                    intersection.as_deref().unwrap_or("")
                ),
            ),
            S::PipelineConfig1 {
                name,
                max_recursion_depth,
                flags,
            } => (
                "RaytracingPipelineConfig1",
                name,
                format!(
                    "MaxTraceRecursionDepth = {max_recursion_depth}, Flags = {}",
                    flags_text(*flags, |f| match f {
                        0x100 => "RAYTRACING_PIPELINE_FLAG_SKIP_TRIANGLES",
                        0x200 => "RAYTRACING_PIPELINE_FLAG_SKIP_PROCEDURAL_PRIMITIVES",
                        0x400 => "RAYTRACING_PIPELINE_FLAG_ALLOW_OPACITY_MICROMAPS",
                        _ => "<invalid RaytracingPipelineFlags>",
                    })
                ),
            ),
        };
        let _ = writeln!(s, ";  {kind} {name} = {{ {body} }};");
    }
    s.push_str(";\n");
}
