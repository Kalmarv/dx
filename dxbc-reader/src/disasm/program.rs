//! The program part of the listing: the version line, then every declaration and instruction in program order, one
//! a line, indented two spaces in each `if`, `loop` and `switch`.
use std::fmt::Write;

use super::number::{self, Style};
use crate::decode::{Declaration, Declared, Decoded, Index, Instruction, Operand, Register, Selection};
use crate::{GlobalFlags, InfoReturn};

const COMPONENTS: [char; 4] = ['x', 'y', 'z', 'w'];

/// The letter of lane `lane` (0 to 3).
fn lane(lane: u8) -> char {
    COMPONENTS.get(usize::from(lane)).copied().unwrap_or('?')
}

/// The name Microsoft's listing gives an instruction, where it is not the token format's (`ld_ms` is `ldms`).
fn mnemonic(opcode: u16) -> &'static str {
    match crate::opcode_name(opcode) {
        "ld_ms" => "ldms",
        "sample_pos" => "samplepos",
        "sample_info" => "sampleinfo",
        "interface_call" => "fcall",
        // the tiled-resource variants that also return a status
        "gather4_feedback" => "gather4_s",
        "gather4_c_feedback" => "gather4_c_s",
        "gather4_po_feedback" => "gather4_po_s",
        "gather4_po_c_feedback" => "gather4_po_c_s",
        "ld_feedback" => "ld_s",
        "ld_ms_feedback" => "ldms_s",
        "ld_uav_typed_feedback" => "ld_uav_typed_s",
        "ld_raw_feedback" => "ld_raw_s",
        "ld_structured_feedback" => "ld_structured_s",
        "sample_l_feedback" => "sample_l_s",
        "sample_c_lz_feedback" => "sample_c_lz_s",
        "sample_clamp_feedback" => "sample_cl_s",
        "sample_b_clamp_feedback" => "sample_b_cl_s",
        "sample_d_clamp_feedback" => "sample_d_cl_s",
        "sample_c_clamp_feedback" => "sample_c_cl_s",
        name => name,
    }
}

/// How the immediates of an instruction's operands are written.
fn style(opcode: u16) -> Style {
    match crate::opcode_name(opcode) {
        "add" | "div" | "dp2" | "dp3" | "dp4" | "eq" | "exp" | "frc" | "ge" | "lt" | "log" | "mad" | "max" | "min"
        | "mul" | "ne" | "round_ne" | "round_ni" | "round_pi" | "round_z" | "rsq" | "sqrt" | "sincos" | "rcp"
        | "deriv_rtx" | "deriv_rty" | "deriv_rtx_coarse" | "deriv_rtx_fine" | "deriv_rty_coarse"
        | "deriv_rty_fine" | "ftoi" | "ftou" | "ftod" | "f32tof16" | "sample" | "sample_c" | "sample_c_lz"
        | "sample_l" | "sample_d" | "sample_b" | "gather4" | "gather4_c" | "gather4_po" | "gather4_po_c" | "lod"
        | "dadd" | "dmax" | "dmin" | "dmul" | "deq" | "dge" | "dlt" | "dne" | "dmov" | "dmovc" | "dtof" | "ddiv"
        | "dfma" | "drcp" | "dtoi" | "dtou" => Style::Float,
        "iadd" | "ieq" | "ige" | "ilt" | "imad" | "imax" | "imin" | "imul" | "ine" | "ineg" | "ishl" | "ishr"
        | "itof" | "itod" | "ibfe" | "ld" | "ld_ms" | "ld_uav_typed" | "eval_snapped" | "atomic_and" | "atomic_or"
        | "atomic_xor" | "atomic_cmp_store" | "atomic_iadd" | "atomic_imax" | "atomic_imin" | "atomic_umax"
        | "atomic_umin" | "imm_atomic_iadd" | "imm_atomic_and" | "imm_atomic_or" | "imm_atomic_xor"
        | "imm_atomic_exch" | "imm_atomic_cmp_exch" | "imm_atomic_imax" | "imm_atomic_imin" | "imm_atomic_umax"
        | "imm_atomic_umin" | "udiv" | "ult" | "uge" | "umul" | "umad" | "umax" | "umin" | "ushr" | "utof"
        | "utod" | "and" | "or" | "xor" | "not" | "ubfe" | "bfi" | "bfrev" | "countbits" | "firstbit_hi"
        | "firstbit_lo" | "firstbit_shi" | "f16tof32" | "uaddc" | "usubb" | "msad" | "case" | "switch" => {
            Style::Integer
        }
        _ => Style::Typeless,
    }
}

/// Instructions whose `_z`/`_nz` test the listing names.
fn conditional(opcode: u16) -> bool {
    matches!(
        crate::opcode_name(opcode),
        "if" | "breakc" | "continuec" | "retc" | "discard" | "callc"
    )
}

/// The listing's name of a register kind and whether the operand's first index is written after it as its number.
fn register_name(register: Register, sm51: bool) -> (&'static str, bool) {
    let upper = |lower: &'static str, upper: &'static str| if sm51 { upper } else { lower };
    match register {
        Register::Temp => ("r", true),
        Register::Input => ("v", true),
        Register::Output => ("o", true),
        Register::IndexableTemp => ("x", true),
        Register::Constant => (upper("cb", "CB"), true),
        Register::Immediate | Register::Immediate64 => ("l", false),
        Register::Texture => (upper("t", "T"), true),
        Register::Sampler => (upper("s", "S"), true),
        Register::Null => ("null", false),
        Register::Uav => (upper("u", "U"), true),
        Register::ImmediateBuffer => ("icb", false),
        Register::PrimitiveId => ("vPrim", false),
        Register::InputCoverage => ("vCoverage", false),
        Register::OutputDepth => ("oDepth", false),
        Register::OutputDepthGreaterEqual => ("oDepthGE", false),
        Register::OutputDepthLessEqual => ("oDepthLE", false),
        Register::OutputCoverage => ("oMask", false),
        Register::Rasterizer => ("rasterizer", false),
        Register::OutputStencilRef => ("oStencilRef", false),
        Register::GroupSharedMemory => ("g", true),
        Register::ThreadId => ("vThreadID", false),
        Register::ThreadGroupId => ("vThreadGroupID", false),
        Register::ThreadIdInGroup => ("vThreadIDInGroup", false),
        Register::ThreadIdInGroupFlattened => ("vThreadIDInGroupFlattened", false),
        Register::OutputControlPointId => ("vOutputControlPointID", false),
        Register::ForkInstanceId => ("vForkInstanceID", false),
        Register::JoinInstanceId => ("vJoinInstanceID", false),
        Register::InputControlPoint => ("vicp", false),
        Register::OutputControlPoint => ("vocp", false),
        Register::InputPatchConstant => ("vpc", true),
        Register::InputDomainPoint => ("vDomain", false),
        Register::Stream => ("m", true),
        Register::GsInstanceId => ("vGSInstanceID", false),
        Register::Label => ("l", true),
        Register::FunctionBody => ("fb", true),
        Register::FunctionTable => ("ft", true),
        Register::Interface => ("fp", true),
        Register::FunctionInput => ("fi", true),
        Register::FunctionOutput => ("fo", true),
        Register::ThisPointer => ("this", false),
        Register::CycleCounter => ("vCycleCounter", false),
        Register::InnerCoverage => ("vInnerCoverage", false),
    }
}

/// Writes operands of one program.
struct Writer {
    sm51: bool,
}

impl Writer {
    fn operand(&self, out: &mut String, o: &Operand, style: Style) {
        self.annotated(out, o, style, o.precision);
    }

    /// An operand of an instruction whose precision (its destination's) is `precision`: an operand of another
    /// precision says both, `{def32 as min16f}`.
    fn annotated(&self, out: &mut String, o: &Operand, style: Style, precision: u8) {
        match o.modifier {
            1 | 4 => out.push('-'),
            2 => out.push('|'),
            3 => out.push_str("-|"),
            _ => {}
        }
        self.body(out, o, style);
        if matches!(o.modifier, 2 | 3) {
            out.push('|');
        }
        if o.precision == precision {
            if o.precision != 0 {
                let _ = write!(out, " {{{}}}", precision_name(o.precision));
            }
        } else {
            let _ = write!(
                out,
                " {{{} as {}}}",
                precision_name(o.precision),
                precision_name(precision)
            );
        }
        if o.non_uniform {
            out.push_str(" { nonuniform }");
        }
    }

    fn body(&self, out: &mut String, o: &Operand, style: Style) {
        match o.register {
            Register::Immediate => {
                let separator = if style == Style::Typeless { "," } else { ", " };
                let count = if o.components == 1 { 1 } else { 4 };
                let values: Vec<String> =
                    o.immediate.iter().take(count).map(|&v| number::value(v, style)).collect();
                let _ = write!(out, "l({})", values.join(separator));
                return;
            }
            Register::Immediate64 => {
                let [a, b, c, d] = o.immediate;
                let values = if o.components == 1 {
                    number::double(a, b)
                } else {
                    format!("{}, {}", number::double(a, b), number::double(c, d))
                };
                let _ = write!(out, "d({values})");
                return;
            }
            _ => {}
        }
        let (name, numbered) = register_name(o.register, self.sm51);
        out.push_str(name);
        let mut indices = o.indices.as_slice();
        // a geometry, hull or domain program's inputs are `v[vertex][register]`
        let vertex_indexed = o.register == Register::Input && indices.len() == 2;
        if numbered
            && !vertex_indexed
            && let Some((first, rest)) = indices.split_first()
            && first.relative.is_none()
        {
            let _ = write!(out, "{}", first.base);
            indices = rest;
        }
        for index in indices {
            out.push('[');
            self.index(out, index);
            out.push(']');
        }
        self.selection(out, o);
    }

    fn index(&self, out: &mut String, index: &Index) {
        match &index.relative {
            None => {
                let _ = write!(out, "{}", index.base);
            }
            Some(relative) => {
                self.operand(out, relative, Style::Integer);
                let _ = write!(out, " + {}", index.base);
            }
        }
    }

    fn selection(&self, out: &mut String, o: &Operand) {
        if o.components != 4 {
            return;
        }
        match o.selection {
            Selection::Mask(0) | Selection::None => {}
            Selection::Mask(mask) => {
                out.push('.');
                for (bit, c) in COMPONENTS.iter().enumerate() {
                    if mask & (1 << bit) != 0 {
                        out.push(*c);
                    }
                }
            }
            Selection::Swizzle(lanes) => {
                out.push('.');
                out.extend(lanes.map(lane));
            }
            Selection::Scalar(l) => {
                out.push('.');
                out.push(lane(l));
            }
        }
    }

}

/// `D3D11_SB_OPERAND_MIN_PRECISION` as an operand's annotation names it.
fn precision_name(precision: u8) -> &'static str {
    match precision {
        1 => "min16f",
        2 => "min2_8f",
        4 => "min16i",
        5 => "min16u",
        _ => "def32",
    }
}

/// What an instruction's extended tokens add to its mnemonic: the suffixes (`_aoffimmi`, `_indexable`) and, after any
/// `[precise]`, their groups (`(u,v,w)`, `(texture2d)(float,float,float,float)`).
fn extended(instruction: &Instruction) -> (String, String) {
    let mut offsets = None;
    let mut dimension = None;
    let mut returns = None;
    for &token in &instruction.extensions {
        match token & 63 {
            1 => {
                let field = |shift: u32| (((token >> shift) & 15) as i32) << 28 >> 28;
                offsets = Some(format!("({},{},{})", field(9), field(13), field(17)));
            }
            2 => {
                let mut text = resource_dimension((token >> 6) & 31).to_owned();
                let stride = (token >> 11) & 0xfff;
                if stride != 0 {
                    let _ = write!(text, ", stride={stride}");
                }
                dimension = Some(text);
            }
            3 => returns = Some(return_types((token >> 6) & 0xffff)),
            _ => {}
        }
    }
    let mut suffixes = String::new();
    let mut out = String::new();
    if offsets.is_some() {
        suffixes.push_str("_aoffimmi");
    }
    let indexable = dimension.is_some() || returns.is_some();
    if indexable {
        suffixes.push_str("_indexable");
    }
    if let Some(offsets) = offsets {
        out.push_str(&offsets);
    }
    if indexable {
        let _ = write!(
            out,
            "({}){}",
            dimension.unwrap_or_default(),
            returns.unwrap_or_default()
        );
    }
    (suffixes, out)
}

/// `D3D10_SB_RESOURCE_DIMENSION` as the listing names it.
fn resource_dimension(dimension: u32) -> &'static str {
    match dimension {
        1 => "buffer",
        2 => "texture1d",
        3 => "texture2d",
        4 => "texture2dms",
        5 => "texture3d",
        6 => "texturecube",
        7 => "texture1darray",
        8 => "texture2darray",
        9 => "texture2dmsarray",
        10 => "texturecubearray",
        11 => "raw_buffer",
        12 => "structured_buffer",
        _ => "unknown",
    }
}

/// A return type token's four lanes: `(float,float,float,float)`.
fn return_types(token: u32) -> String {
    let names: Vec<String> = [0, 4, 8, 12]
        .iter()
        .map(|shift| match (token >> shift) & 15 {
            1 => "unorm".to_owned(),
            2 => "snorm".to_owned(),
            3 => "sint".to_owned(),
            4 => "uint".to_owned(),
            5 => "float".to_owned(),
            6 => "mixed".to_owned(),
            7 => "double".to_owned(),
            8 => "continued".to_owned(),
            9 => "unused".to_owned(),
            other => other.to_string(),
        })
        .collect();
    format!("({})", names.join(","))
}

/// `D3D10_SB_NAME` as declarations name it.
fn system_value(name: u32) -> String {
    match name {
        0 => "undefined",
        1 => "position",
        2 => "clip_distance",
        3 => "cull_distance",
        4 => "rendertarget_array_index",
        5 => "viewport_array_index",
        6 => "vertex_id",
        7 => "primitive_id",
        8 => "instance_id",
        9 => "is_front_face",
        10 => "sampleIndex",
        11 => "finalQuadUeq0EdgeTessFactor",
        12 => "finalQuadVeq0EdgeTessFactor",
        13 => "finalQuadUeq1EdgeTessFactor",
        14 => "finalQuadVeq1EdgeTessFactor",
        15 => "finalQuadUInsideTessFactor",
        16 => "finalQuadVInsideTessFactor",
        17 => "finalTriUeq0EdgeTessFactor",
        18 => "finalTriVeq0EdgeTessFactor",
        19 => "finalTriWeq0EdgeTessFactor",
        20 => "finalTriInsideTessFactor",
        21 => "finalLineDetailTessFactor",
        22 => "finalLineDensityTessFactor",
        other => return format!("name{other}"),
    }
    .to_owned()
}

/// `D3D_INTERPOLATION_MODE` as `dcl_input_ps` names it, with its trailing space; nothing for undefined.
fn interpolation(mode: u32) -> &'static str {
    match mode {
        1 => "constant ",
        2 => "linear ",
        3 => "linear centroid ",
        4 => "linear noperspective ",
        5 => "linear noperspective centroid ",
        6 => "linear sample ",
        7 => "linear noperspective sample ",
        _ => "",
    }
}

/// The flags of `dcl_globalFlags`, joined with ` | `.
fn global_flags(control: u32) -> String {
    let flags = GlobalFlags::from_bits(control);
    let mut names = Vec::new();
    for (set, name) in [
        (flags.refactoring_allowed, "refactoringAllowed"),
        (flags.double_precision, "enableDoublePrecisionFloatOps"),
        (flags.force_early_depth_stencil, "forceEarlyDepthStencil"),
        (flags.raw_and_structured_buffers, "enableRawAndStructuredBuffers"),
        (flags.skip_optimization, "skipOptimization"),
        (flags.minimum_precision, "enableMinimumPrecision"),
        (flags.other & 1 != 0, "enable11_1DoubleExtensions"),
        (flags.other & 2 != 0, "enable11_1ShaderExtensions"),
    ] {
        if set {
            names.push(name);
        }
    }
    names.join(" | ")
}

/// The flags of an unordered-access view declaration: `_glc` (globally coherent), `_rov` (rasterizer ordered),
/// `_opc` (an order-preserving counter).
fn uav_flags(control: u32) -> String {
    let mut out = String::new();
    for (bit, name) in [(5, "_glc"), (6, "_rov"), (12, "_opc")] {
        if (control >> bit) & 1 != 0 {
            out.push_str(name);
        }
    }
    out
}

impl Writer {
    fn declaration(&self, out: &mut String, d: &Declaration) {
        let space = |out: &mut String, d: &Declared| {
            if self.sm51
                && let Some(range) = d.registers()
            {
                let _ = write!(out, ", space={}", range.space);
            }
        };
        match &d.kind {
            Declared::GlobalFlags(bits) => {
                let _ = write!(out, "dcl_globalFlags {}", global_flags(*bits));
            }
            Declared::Temps(n) => {
                let _ = write!(out, "dcl_temps {n}");
            }
            Declared::IndexableTemp {
                register,
                size,
                components,
            } => {
                let _ = write!(out, "dcl_indexableTemp x{register}[{size}], {components}");
            }
            Declared::ConstantBuffer {
                slot,
                rows,
                dynamic,
                range,
                ..
            } => {
                out.push_str("dcl_constantbuffer ");
                match range {
                    None => {
                        let _ = write!(out, "CB{slot}[{rows}]");
                    }
                    Some(r) => {
                        let upper = if r.upper == u32::MAX {
                            "*".to_owned()
                        } else {
                            r.upper.to_string()
                        };
                        let _ = write!(out, "CB{slot}[{}:{upper}][{rows}]", r.lower);
                    }
                }
                out.push_str(if *dynamic {
                    ", dynamicIndexed"
                } else {
                    ", immediateIndexed"
                });
                space(out, &d.kind);
            }
            Declared::Sampler { mode, .. } => {
                out.push_str("dcl_sampler ");
                self.declared_binding(out, d);
                out.push_str(match mode {
                    1 => ", mode_comparison",
                    2 => ", mode_mono",
                    _ => ", mode_default",
                });
                space(out, &d.kind);
            }
            Declared::Resource {
                dimension,
                samples,
                token,
                ..
            } => {
                let _ = write!(out, "dcl_resource_{}", resource_dimension(*dimension));
                if matches!(dimension, 4 | 9) {
                    let _ = write!(out, "({samples})");
                }
                let _ = write!(out, " {} ", return_types(*token));
                self.declared_binding(out, d);
                space(out, &d.kind);
            }
            Declared::ResourceRaw { .. } => {
                out.push_str("dcl_resource_raw ");
                self.declared_binding(out, d);
                space(out, &d.kind);
            }
            Declared::ResourceStructured { stride, .. } => {
                out.push_str("dcl_resource_structured ");
                self.declared_binding(out, d);
                let _ = write!(out, ", {stride}");
                space(out, &d.kind);
            }
            Declared::UavTyped {
                dimension,
                token,
                control,
                ..
            } => {
                let _ = write!(
                    out,
                    "dcl_uav_typed_{}{} {} ",
                    resource_dimension(*dimension),
                    uav_flags(*control),
                    return_types(*token)
                );
                self.declared_binding(out, d);
                space(out, &d.kind);
            }
            Declared::UavRaw { control, .. } => {
                let _ = write!(out, "dcl_uav_raw{} ", uav_flags(*control));
                self.declared_binding(out, d);
                space(out, &d.kind);
            }
            Declared::UavStructured {
                stride, control, ..
            } => {
                let _ = write!(out, "dcl_uav_structured{} ", uav_flags(*control));
                self.declared_binding(out, d);
                let _ = write!(out, ", {stride}");
                space(out, &d.kind);
            }
            Declared::ThreadGroup([x, y, z]) => {
                let _ = write!(out, "dcl_thread_group {x}, {y}, {z}");
            }
            Declared::GroupSharedRaw { register, bytes } => {
                let _ = write!(out, "dcl_tgsm_raw g{register}, {bytes}");
            }
            Declared::GroupSharedStructured {
                register,
                stride,
                count,
            } => {
                let _ = write!(out, "dcl_tgsm_structured g{register}, {stride}, {count}");
            }
            Declared::Input {
                operand,
                interpolation: mode,
                name,
            } => {
                out.push_str(crate::opcode_name(d.opcode).trim_end_matches(char::is_whitespace));
                out.push(' ');
                if let Some(mode) = mode {
                    out.push_str(interpolation(*mode));
                }
                self.operand(out, operand, Style::Typeless);
                if let Some(name) = name {
                    let _ = write!(out, ", {}", system_value(*name));
                }
            }
            Declared::Output { operand, name } => {
                out.push_str(crate::opcode_name(d.opcode));
                out.push(' ');
                self.operand(out, operand, Style::Typeless);
                if let Some(name) = name {
                    let _ = write!(out, ", {}", system_value(*name));
                }
            }
            Declared::IndexRange { operand, count } => {
                out.push_str("dcl_indexrange ");
                self.operand(out, operand, Style::Typeless);
                let _ = write!(out, " {count}");
            }
            Declared::Stream(operand) => {
                out.push_str("dcl_stream ");
                self.operand(out, operand, Style::Typeless);
            }
            Declared::ImmediateBuffer(rows) => {
                const OPEN: &str = "dcl_immediateConstantBuffer { ";
                out.push_str(OPEN);
                let indent = " ".repeat(OPEN.len());
                for (i, row) in rows.iter().enumerate() {
                    if i != 0 {
                        let _ = write!(out, ",\n{indent}");
                    }
                    let values: Vec<String> = row
                        .iter()
                        .map(|&v| number::value(v, Style::Typeless))
                        .collect();
                    let _ = write!(out, "{{ {}}}", values.join(", "));
                }
                out.push_str(" }");
            }
            Declared::CustomData { class } => {
                let _ = write!(out, "customdata {class}");
            }
            Declared::Other {
                opcode,
                control,
                words,
            } => self.other(out, *opcode, *control, words),
        }
    }

    /// The binding operand of a resource, sampler or view declaration.
    fn declared_binding(&self, out: &mut String, d: &Declaration) {
        let (Some(range), true) = (d.kind.registers(), self.sm51) else {
            let slot = d.kind.registers().map_or(0, |r| r.lower);
            let prefix = match d.kind {
                Declared::Sampler { .. } => "s",
                Declared::UavTyped { .. } | Declared::UavRaw { .. } | Declared::UavStructured { .. } => "u",
                _ => "t",
            };
            let _ = write!(out, "{prefix}{slot}");
            return;
        };
        let (prefix, id) = match &d.kind {
            Declared::Sampler { slot, .. } => ("S", slot),
            Declared::UavTyped { slot, .. }
            | Declared::UavRaw { slot, .. }
            | Declared::UavStructured { slot, .. } => ("U", slot),
            Declared::Resource { slot, .. }
            | Declared::ResourceRaw { slot, .. }
            | Declared::ResourceStructured { slot, .. } => ("T", slot),
            _ => ("?", &0),
        };
        let upper = if range.upper == u32::MAX {
            "*".to_owned()
        } else {
            range.upper.to_string()
        };
        let _ = write!(out, "{prefix}{id}[{}:{upper}]", range.lower);
    }

    /// The declarations this reader keeps as words: the stage declarations, hull phases and class linkage.
    fn other(&self, out: &mut String, opcode: u16, control: u32, words: &[u32]) {
        let first = words.first().copied().unwrap_or(0);
        let named = |names: &[&str], value: u32| -> String {
            names
                .get(value as usize)
                .filter(|n| !n.is_empty())
                .map_or_else(|| value.to_string(), |n| (*n).to_owned())
        };
        match opcode {
            92 => {
                let topologies = [
                    "",
                    "pointlist",
                    "linelist",
                    "linestrip",
                    "trianglelist",
                    "trianglestrip",
                    "",
                    "",
                    "",
                    "",
                    "linelistadj",
                    "linestripadj",
                    "trianglelistadj",
                    "trianglestripadj",
                ];
                let _ = write!(out, "dcl_outputtopology {} ", named(&topologies, control & 63));
            }
            93 => {
                let primitives = ["", "point", "line", "triangle", "", "", "lineadj", "triangleadj"];
                let value = control & 63;
                let name = if (8..=39).contains(&value) {
                    format!("{}_control_point_patch", value.saturating_sub(7))
                } else {
                    named(&primitives, value)
                };
                let _ = write!(out, "dcl_inputprimitive {name} ");
            }
            94 => {
                let _ = write!(out, "dcl_maxout {first}");
            }
            206 => {
                let _ = write!(out, "dcl_gsinstances {first}");
            }
            113 => out.push_str("hs_decls "),
            114 => out.push_str("hs_control_point_phase "),
            115 => out.push_str("hs_fork_phase "),
            116 => out.push_str("hs_join_phase "),
            147 => {
                let _ = write!(out, "dcl_input_control_point_count {}", control & 63);
            }
            148 => {
                let _ = write!(out, "dcl_output_control_point_count {}", control & 63);
            }
            149 => {
                let domains = ["", "domain_isoline", "domain_tri", "domain_quad"];
                let _ = write!(out, "dcl_tessellator_domain {}", named(&domains, control & 7));
            }
            150 => {
                let modes = [
                    "",
                    "partitioning_integer",
                    "partitioning_pow2",
                    "partitioning_fractional_odd",
                    "partitioning_fractional_even",
                ];
                let _ = write!(out, "dcl_tessellator_partitioning {}", named(&modes, control & 7));
            }
            151 => {
                let primitives = [
                    "",
                    "output_point",
                    "output_line",
                    "output_triangle_cw",
                    "output_triangle_ccw",
                ];
                let _ = write!(
                    out,
                    "dcl_tessellator_output_primitive {}",
                    named(&primitives, control & 7)
                );
            }
            152 => {
                let _ = write!(out, "dcl_hs_max_tessfactor l({})", number::float(first));
            }
            153 => {
                let _ = write!(out, "dcl_hs_fork_phase_instance_count {first}");
            }
            154 => {
                let _ = write!(out, "dcl_hs_join_phase_instance_count {first}");
            }
            144 => {
                let _ = write!(out, "dcl_function_body fb{first}");
            }
            145 => {
                let bodies: Vec<String> = words
                    .get(2..)
                    .unwrap_or_default()
                    .iter()
                    .map(|b| format!("fb{b}"))
                    .collect();
                let _ = write!(out, "dcl_function_table ft{first} = {{{}}}", bodies.join(", "));
            }
            146 => {
                // the interface's id, its expected table length, its array length and type count, then its tables
                let length = words.get(2).copied().unwrap_or(0);
                let tables: Vec<String> = words
                    .get(3..)
                    .unwrap_or_default()
                    .iter()
                    .map(|t| format!("ft{t}"))
                    .collect();
                let dynamic = if control & 1 != 0 { "_dynamicindexed" } else { "" };
                let _ = write!(
                    out,
                    "dcl_interface{dynamic} fp{first}[{}][{}] = {{{}}}",
                    length >> 16,
                    length & 0xffff,
                    tables.join(", ")
                );
            }
            _ => {
                let _ = write!(out, "{}", crate::opcode_name(opcode));
            }
        }
    }

    fn instruction(&self, out: &mut String, i: &Instruction) {
        out.push_str(mnemonic(i.opcode));
        if conditional(i.opcode) {
            out.push_str(if i.nonzero { "_nz" } else { "_z" });
        }
        if i.saturate {
            out.push_str("_sat");
        }
        if let Some(flags) = i.sync_flags() {
            for (set, name) in [
                (flags.uav_global, "_uglobal"),
                (flags.uav_group, "_ugroup"),
                (flags.group_shared_memory, "_g"),
                (flags.threads_in_group, "_t"),
            ] {
                if set {
                    out.push_str(name);
                }
            }
        }
        let (suffixes, groups) = extended(i);
        out.push_str(&suffixes);
        let precise = i.precise_mask();
        if precise != 0 && !matches!(crate::opcode_name(i.opcode), "resinfo" | "sample_info" | "sync") {
            out.push_str(" [precise");
            if precise != 15 {
                out.push('(');
                for (bit, c) in COMPONENTS.iter().enumerate() {
                    if precise & (1 << bit) != 0 {
                        out.push(*c);
                    }
                }
                out.push(')');
            }
            out.push(']');
        }
        out.push_str(&groups);
        match i.info_return() {
            Some(InfoReturn::Uint) => out.push_str("_uint"),
            Some(InfoReturn::ReciprocalFloat) => out.push_str("_rcpFloat"),
            _ => {}
        }
        // every instruction is followed by a space but sync, which has no operands either way
        if i.sync_flags().is_none() {
            out.push(' ');
        }
        let style = style(i.opcode);
        let precision = i.operands.first().map_or(0, |o| o.precision);
        for (n, o) in i.operands.iter().enumerate() {
            if n != 0 {
                out.push_str(", ");
            }
            self.annotated(out, o, style, precision);
        }
        if let Some(function) = i.function {
            let _ = write!(out, ", {function}");
        }
    }
}

/// How an instruction moves the indentation: before it is written and after.
fn indentation(opcode: u16) -> (i32, i32) {
    match crate::opcode_name(opcode) {
        "if" | "loop" | "switch" => (0, 1),
        "else" => (-1, 1),
        "endif" | "endloop" | "endswitch" => (-1, 0),
        _ => (0, 0),
    }
}

/// The program's lines after the header: the version line, the declarations and instructions in program order.
pub(super) fn write(out: &mut String, program: &Decoded) {
    let writer = Writer {
        sm51: (program.major, program.minor) >= (5, 1),
    };
    let _ = writeln!(out, "{}", program.target());
    let mut declarations = program.declarations.iter().peekable();
    let mut instructions = program.instructions.iter().peekable();
    let mut depth: i32 = 0;
    loop {
        let next_declaration = declarations.peek().map(|d| d.word);
        let next_instruction = instructions.peek().map(|i| i.word);
        let mut line = String::new();
        match (next_declaration, next_instruction) {
            (Some(d), i) if i.is_none_or(|i| d < i) => {
                if let Some(d) = declarations.next() {
                    writer.declaration(&mut line, d);
                }
            }
            (_, Some(_)) => {
                if let Some(i) = instructions.next() {
                    let (before, after) = indentation(i.opcode);
                    depth = depth.saturating_add(before).max(0);
                    writer.instruction(&mut line, i);
                    let indent = " ".repeat(usize::try_from(depth).unwrap_or(0).saturating_mul(2));
                    line.insert_str(0, &indent);
                    depth = depth.saturating_add(after);
                }
            }
            (None, None) => break,
            _ => break,
        }
        out.push_str(&line);
        out.push('\n');
    }
}
