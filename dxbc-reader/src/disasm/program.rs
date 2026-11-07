//! The program part of the listing: the version line, then every declaration and instruction in program order, one
//! a line, indented two spaces in each `if`, `loop` and `switch`.
use std::fmt::Write;

use super::Options;
use super::number::{self, Style};
use crate::decode::{Declaration, Declared, Decoded, Index, Instruction, Operand, Register, Selection};
use crate::spdb::Annotations;
use crate::{GlobalFlags, InfoReturn, OperandClass, OperandFormat};

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
        // the opcodes the format reserves: the first is `jmp`, the others have no name
        "reserved0" if opcode == 107 => "jmp",
        "reserved0" => "",
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
        "add"
        | "div"
        | "dp2"
        | "dp3"
        | "dp4"
        | "eq"
        | "exp"
        | "frc"
        | "ge"
        | "lt"
        | "log"
        | "mad"
        | "max"
        | "min"
        | "mul"
        | "ne"
        | "round_ne"
        | "round_ni"
        | "round_pi"
        | "round_z"
        | "rsq"
        | "sqrt"
        | "sincos"
        | "rcp"
        | "deriv_rtx"
        | "deriv_rty"
        | "deriv_rtx_coarse"
        | "deriv_rtx_fine"
        | "deriv_rty_coarse"
        | "deriv_rty_fine"
        | "ftoi"
        | "ftou"
        | "ftod"
        | "f32tof16"
        | "sample"
        | "sample_c"
        | "sample_c_lz"
        | "sample_l"
        | "sample_d"
        | "sample_b"
        | "gather4"
        | "gather4_c"
        | "lod"
        | "dadd"
        | "dmax"
        | "dmin"
        | "dmul"
        | "deq"
        | "dge"
        | "dlt"
        | "dne"
        | "dmov"
        | "dmovc"
        | "dtof"
        | "ddiv"
        | "dfma"
        | "drcp"
        | "dtoi"
        | "dtou"
        | "sample_l_feedback"
        | "sample_c_lz_feedback"
        | "sample_clamp_feedback"
        | "sample_b_clamp_feedback"
        | "sample_d_clamp_feedback"
        | "sample_c_clamp_feedback"
        | "gather4_feedback"
        | "gather4_c_feedback" => Style::Float,
        // a gather with programmable offsets writes even its address and reference value as integers
        "gather4_po" | "gather4_po_c" | "gather4_po_feedback" | "gather4_po_c_feedback" => Style::Integer,
        "iadd"
        | "ieq"
        | "ige"
        | "ilt"
        | "imad"
        | "imax"
        | "imin"
        | "imul"
        | "ine"
        | "ineg"
        | "ishl"
        | "ishr"
        | "itof"
        | "itod"
        | "ibfe"
        | "ld"
        | "ld_ms"
        | "ld_uav_typed"
        | "ld_feedback"
        | "ld_ms_feedback"
        | "ld_uav_typed_feedback"
        | "ld_raw"
        | "ld_structured"
        | "ld_raw_feedback"
        | "ld_structured_feedback"
        | "resinfo"
        | "sample_pos"
        | "eval_sample_index"
        | "eval_snapped"
        | "atomic_and"
        | "atomic_or"
        | "atomic_xor"
        | "atomic_cmp_store"
        | "atomic_iadd"
        | "atomic_imax"
        | "atomic_imin"
        | "atomic_umax"
        | "atomic_umin"
        | "imm_atomic_iadd"
        | "imm_atomic_and"
        | "imm_atomic_or"
        | "imm_atomic_xor"
        | "imm_atomic_exch"
        | "imm_atomic_cmp_exch"
        | "imm_atomic_imax"
        | "imm_atomic_imin"
        | "imm_atomic_umax"
        | "imm_atomic_umin"
        | "udiv"
        | "ult"
        | "uge"
        | "umul"
        | "umad"
        | "umax"
        | "umin"
        | "ushr"
        | "utof"
        | "utod"
        | "and"
        | "or"
        | "xor"
        | "not"
        | "ubfe"
        | "bfi"
        | "bfrev"
        | "countbits"
        | "firstbit_hi"
        | "firstbit_lo"
        | "firstbit_shi"
        | "f16tof32"
        | "uaddc"
        | "usubb"
        | "msad"
        | "case"
        | "switch"
        // the conditionals test their value's bits
        | "if"
        | "breakc"
        | "continuec"
        | "retc"
        | "discard"
        | "callc" => Style::Integer,
        "mov" | "movc" | "swapc" | "store_raw" | "store_structured" | "store_uav_typed" => Style::Data,
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
        Register::ImmediateBuffer => ("icb", true),
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
        Register::Label => ("label", true),
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
    /// Every 32-bit value as eight hex digits (`D3D_DISASM_PRINT_HEX_LITERALS`).
    hex: bool,
}

impl Writer {
    /// One 32-bit value in `style`, or in hex.
    fn value(&self, bits: u32, style: Style) -> String {
        if self.hex {
            format!("0x{bits:08x}")
        } else {
            number::value(bits, style)
        }
    }

    fn operand(&self, out: &mut String, o: &Operand, style: Style) {
        self.annotated(out, o, style, None);
    }

    /// An operand and its precision, `{min16f}` (none for full precision). A source that takes the precision of the
    /// instruction's result, `reference`, says both where they differ, `{def32 as min16f}`. The precision is written
    /// inside an absolute value's bars.
    fn annotated(&self, out: &mut String, o: &Operand, style: Style, reference: Option<u8>) {
        match o.modifier {
            1 | 4 => out.push('-'),
            2 => out.push('|'),
            3 => out.push_str("-|"),
            _ => {}
        }
        self.body(out, o, style);
        match reference {
            Some(precision) if precision != o.precision => {
                let _ = write!(
                    out,
                    " {{{} as {}}}",
                    precision_name(o.precision),
                    precision_name(precision)
                );
            }
            _ if o.precision != 0 => {
                let _ = write!(out, " {{{}}}", precision_name(o.precision));
            }
            _ => {}
        }
        if matches!(o.modifier, 2 | 3) {
            out.push('|');
        }
        if o.non_uniform {
            out.push_str(" { nonuniform }");
        }
    }

    fn body(&self, out: &mut String, o: &Operand, style: Style) {
        match o.register {
            Register::Immediate => {
                let separator = if style == Style::Data { "," } else { ", " };
                let count = if o.components == 1 { 1 } else { 4 };
                let values: Vec<String> = o
                    .immediate
                    .iter()
                    .take(count)
                    .map(|&v| self.value(v, style))
                    .collect();
                let _ = write!(out, "l({})", values.join(separator));
                return;
            }
            // two doubles, or with hex literals their four words; a one-component one is a single word, a float
            Register::Immediate64 => {
                let [a, b, c, d] = o.immediate;
                let values = if o.components == 1 {
                    self.value(a, Style::Float)
                } else if self.hex {
                    [a, b, c, d].map(|w| self.value(w, Style::Float)).join(", ")
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
            let _ = write!(out, "{}", first.base.cast_signed());
            indices = rest;
        }
        for index in indices {
            out.push('[');
            self.index(out, index);
            out.push(']');
        }
        self.selection(out, o);
    }

    /// An index as Microsoft writes it: signed, as every operand index and register number (`r-2`, `cb0[r0.x + -1]`).
    fn index(&self, out: &mut String, index: &Index) {
        match &index.relative {
            None => {
                let _ = write!(out, "{}", index.base.cast_signed());
            }
            Some(relative) => {
                // the register of a relative index is written with one component: the one a four-component scalar
                // selection names, and x for any other selection or component count
                let lane = match (relative.components, &relative.selection) {
                    (4, Selection::Scalar(lane)) => *lane,
                    _ => 0,
                };
                let one = Operand {
                    components: 4,
                    selection: Selection::Scalar(lane),
                    ..relative.as_ref().clone()
                };
                self.operand(out, &one, Style::Integer);
                let _ = write!(out, " + {}", index.base.cast_signed());
            }
        }
    }

    fn selection(&self, out: &mut String, o: &Operand) {
        if o.components != 4 {
            return;
        }
        match o.selection {
            Selection::None => {}
            // an empty mask is written as its dot alone (`r0.`)
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
/// `[precise]`, their groups (`(u,v,w)`, `(texture2d)(float,float,float,float)`). Microsoft keeps the last token of
/// each kind and writes its group once for each token of the kind: the offsets first, then the dimension, then the
/// return types, whatever the tokens' order.
fn extended(instruction: &Instruction) -> (String, String) {
    // the number of tokens of each kind and the group of the last
    let mut offsets = (0_usize, String::new());
    let mut dimension = (0_usize, String::new());
    let mut returns = (0_usize, String::new());
    for &token in &instruction.extensions {
        let (kind, group) = match token & 63 {
            1 => {
                let field = |shift: u32| (((token >> shift) & 15) as i32) << 28 >> 28;
                (
                    &mut offsets,
                    format!("({},{},{})", field(9), field(13), field(17)),
                )
            }
            2 => {
                let mut text = format!("({}", resource_dimension((token >> 6) & 31));
                let stride = (token >> 11) & 0xfff;
                if stride != 0 {
                    let _ = write!(text, ", stride={stride}");
                }
                text.push(')');
                (&mut dimension, text)
            }
            3 => (&mut returns, return_types((token >> 6) & 0xffff)),
            _ => continue,
        };
        *kind = (kind.0.saturating_add(1), group);
    }
    let mut suffixes = String::new();
    if offsets.0 > 0 {
        suffixes.push_str("_aoffimmi");
    }
    if dimension.0 > 0 || returns.0 > 0 {
        suffixes.push_str("_indexable");
    }
    let groups = [offsets, dimension, returns]
        .iter()
        .map(|(count, group)| group.repeat(*count))
        .collect();
    (suffixes, groups)
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
        _ => "<unknown dimension>",
    }
}

/// A return type token's four lanes: `(float,float,float,float)`.
fn return_types(token: u32) -> String {
    let names: Vec<&str> = [0, 4, 8, 12]
        .iter()
        .map(|shift| match (token >> shift) & 15 {
            1 => "unorm",
            2 => "snorm",
            3 => "sint",
            4 => "uint",
            5 => "float",
            6 => "mixed",
            7 => "double",
            8 => "<continued>",
            9 => "<unused>",
            _ => "<unknown resource return type>",
        })
        .collect();
    format!("({})", names.join(","))
}

/// `D3D10_SB_NAME` as declarations name it; nothing for one Microsoft's disassembler has no name for.
fn system_value(name: u32) -> &'static str {
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
        _ => "",
    }
}

/// `D3D_INTERPOLATION_MODE` as `dcl_input_ps` names it, with its trailing space.
fn interpolation(mode: u32) -> &'static str {
    match mode {
        0 => "undefined ",
        1 => "constant ",
        2 => "linear ",
        3 => "linear centroid ",
        4 => "linear noperspective ",
        5 => "linear noperspective centroid ",
        6 => "linear sample ",
        7 => "linear noperspective sample ",
        _ => "??? ",
    }
}

/// ` [precise]`, or ` [precise(xz)]` for some components, for a mask of control bits 8 to 11 (x to w); nothing for 0.
fn precise(out: &mut String, mask: u32) {
    if mask == 0 {
        return;
    }
    out.push_str(" [precise");
    if mask != 15 {
        out.push('(');
        for (bit, c) in COMPONENTS.iter().enumerate() {
            if mask & (1 << bit) != 0 {
                out.push(*c);
            }
        }
        out.push(')');
    }
    out.push(']');
}

/// The flags of `dcl_globalFlags`, joined with ` | `, in Microsoft's order, which writes bit 3 before bit 2. Bits 9 to
/// 12 have no name: with no named bit set the listing writes `none`.
fn global_flags(control: u32) -> String {
    let flags = GlobalFlags::from_bits(control);
    let mut names = Vec::new();
    for (set, name) in [
        (flags.refactoring_allowed, "refactoringAllowed"),
        (flags.double_precision, "enableDoublePrecisionFloatOps"),
        (flags.raw_and_structured_buffers, "enableRawAndStructuredBuffers"),
        (flags.force_early_depth_stencil, "forceEarlyDepthStencil"),
        (flags.skip_optimization, "skipOptimization"),
        (flags.minimum_precision, "enableMinimumPrecision"),
        (flags.other & 1 != 0, "enable11_1DoubleExtensions"),
        (flags.other & 2 != 0, "enable11_1ShaderExtensions"),
        (flags.other & 4 != 0, "allResourcesBound"),
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
        // a constant buffer's numbers are written signed, a resource's, sampler's or view's unsigned
        let space = |out: &mut String, d: &Declared| {
            if self.sm51
                && let Some(range) = d.registers()
            {
                if matches!(d, Declared::ConstantBuffer { .. }) {
                    let _ = write!(out, ", space={}", range.space.cast_signed());
                } else {
                    let _ = write!(out, ", space={}", range.space);
                }
            }
        };
        match &d.kind {
            // with no flags, Microsoft writes the word `none` against the name
            Declared::GlobalFlags(bits) => match global_flags(*bits) {
                flags if flags.is_empty() => out.push_str("dcl_globalFlagsnone"),
                flags => {
                    let _ = write!(out, "dcl_globalFlags {flags}");
                }
            },
            Declared::Temps(n) => {
                let _ = write!(out, "dcl_temps {}", n.cast_signed());
            }
            Declared::IndexableTemp {
                register,
                size,
                components,
            } => {
                // the component count as Microsoft writes it, between one and four
                let _ = write!(
                    out,
                    "dcl_indexableTemp x{}[{}], {}",
                    register.cast_signed(),
                    size.cast_signed(),
                    (*components).clamp(1, 4)
                );
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
                        let _ = write!(out, "CB{}[{}]", slot.cast_signed(), rows.cast_signed());
                    }
                    Some(r) => {
                        let upper = if r.upper == u32::MAX {
                            "*".to_owned()
                        } else {
                            r.upper.cast_signed().to_string()
                        };
                        let _ = write!(
                            out,
                            "CB{}[{}:{upper}][{}]",
                            slot.cast_signed(),
                            r.lower.cast_signed(),
                            rows.cast_signed()
                        );
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
                // a mode Microsoft's listing has no name for is left out, comma and all
                out.push_str(match mode {
                    0 => ", mode_default",
                    1 => ", mode_comparison",
                    2 => ", mode_mono",
                    _ => "",
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
            Declared::UavStructured { stride, control, .. } => {
                let _ = write!(out, "dcl_uav_structured{} ", uav_flags(*control));
                self.declared_binding(out, d);
                let _ = write!(out, ", {stride}");
                space(out, &d.kind);
            }
            Declared::ThreadGroup([x, y, z]) => {
                let _ = write!(out, "dcl_thread_group {x}, {y}, {z}");
            }
            Declared::GroupSharedRaw {
                register,
                bytes,
                operand,
            } => {
                let _ = write!(out, "dcl_tgsm_raw g{}", register.cast_signed());
                self.selection(out, operand);
                let _ = write!(out, ", {bytes}");
            }
            Declared::GroupSharedStructured {
                register,
                stride,
                count,
                operand,
            } => {
                let _ = write!(out, "dcl_tgsm_structured g{}", register.cast_signed());
                self.selection(out, operand);
                let _ = write!(out, ", {stride}, {count}");
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
                let _ = write!(out, " {}", count.cast_signed());
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
                    let values: Vec<String> = row.iter().map(|&v| self.value(v, Style::Typeless)).collect();
                    let _ = write!(out, "{{ {}}}", values.join(", "));
                }
                out.push_str(" }");
            }
            Declared::FunctionBody(id) => {
                let _ = write!(out, "dcl_function_body fb{id}");
            }
            Declared::FunctionTable { id, bodies } => {
                let bodies: Vec<String> = bodies.iter().map(|b| format!("fb{b}")).collect();
                let _ = write!(out, "dcl_function_table ft{id} = {{{}}}", bodies.join(", "));
            }
            Declared::Interface {
                id,
                dynamic,
                sites,
                length,
                tables,
            } => {
                let tables: Vec<String> = tables.iter().map(|t| format!("ft{t}")).collect();
                let dynamic = if *dynamic { "_dynamicindexed" } else { "" };
                // Microsoft's listing writes only the id's low 16 bits
                let _ = write!(
                    out,
                    "dcl_interface{dynamic} fp{}[{length}][{sites}] = {{{}}}",
                    id & 0xffff,
                    tables.join(", ")
                );
            }
            Declared::ShaderMessage {
                id,
                format,
                text,
                operands,
                ..
            } => {
                let name = match (id, format) {
                    (0x0020_0102, 1) => "printf",
                    (0x0020_0103, 1) => "errorf",
                    _ => "<unknown>",
                };
                let _ = write!(out, "{name} \"{}\"", message_text(text));
                for o in operands {
                    out.push_str(", ");
                    self.operand(out, o, Style::Data);
                }
            }
            Declared::CustomData { class: 4 } => out.push_str("undecipherable custom data"),
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
            // a register number, so signed, as an operand's
            let slot = d.kind.registers().map_or(0, |r| r.lower.cast_signed());
            let prefix = match d.kind {
                Declared::Sampler { .. } => "s",
                Declared::UavTyped { .. } | Declared::UavRaw { .. } | Declared::UavStructured { .. } => "u",
                _ => "t",
            };
            let _ = write!(out, "{prefix}{slot}");
            // and the operand's component selection, which Shader Model 5.1 leaves out
            if let Some(operand) = d.kind.operand() {
                self.selection(out, operand);
            }
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

    /// The declarations this reader keeps as words: the stage declarations and hull phases.
    fn other(&self, out: &mut String, opcode: u16, control: u32, words: &[u32]) {
        let first = words.first().copied().unwrap_or(0);
        // Microsoft's listing writes `unknown` for a value it has no name for
        let named = |names: &[&'static str], value: u32, unknown: &'static str| -> &'static str {
            names
                .get(value as usize)
                .copied()
                .filter(|n| !n.is_empty())
                .unwrap_or(unknown)
        };
        match opcode {
            92 => {
                // the topologies a geometry program may write; the others are `???`
                let topologies = ["undefined", "pointlist", "", "linestrip", "", "trianglestrip"];
                let _ = write!(
                    out,
                    "dcl_outputtopology {} ",
                    named(&topologies, control & 63, "???")
                );
            }
            93 => {
                let primitives = [
                    "undefined",
                    "point",
                    "line",
                    "triangle",
                    "",
                    "",
                    "lineadj",
                    "triangleadj",
                ];
                let value = control & 63;
                let name = if (8..=39).contains(&value) {
                    format!("patch{}", value.saturating_sub(7))
                } else {
                    named(&primitives, value, "???").to_owned()
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
            // a phase is written as an instruction is, with its saturate and precise bits
            114..=116 => {
                out.push_str(crate::opcode_name(opcode));
                if control & 4 != 0 {
                    out.push_str("_sat");
                }
                precise(out, (control >> 8) & 15);
                out.push(' ');
            }
            147 => {
                let _ = write!(out, "dcl_input_control_point_count {}", control & 63);
            }
            148 => {
                let _ = write!(out, "dcl_output_control_point_count {}", control & 63);
            }
            149 => {
                let domains = ["", "domain_isoline", "domain_tri", "domain_quad"];
                let _ = write!(
                    out,
                    "dcl_tessellator_domain {}",
                    named(&domains, control & 3, "???")
                );
            }
            150 => {
                let modes = [
                    "",
                    "partitioning_integer",
                    "partitioning_pow2",
                    "partitioning_fractional_odd",
                    "partitioning_fractional_even",
                ];
                let _ = write!(
                    out,
                    "dcl_tessellator_partitioning {}",
                    named(&modes, control & 7, "???")
                );
            }
            151 => {
                let primitives = [
                    "",
                    "output_point",
                    "output_line",
                    "output_triangle_cw",
                    "output_triangle_ccw",
                ];
                // one Microsoft's listing has no name for is left out, space and all
                out.push_str("dcl_tessellator_output_primitive");
                let name = named(&primitives, control & 7, "");
                if !name.is_empty() {
                    let _ = write!(out, " {name}");
                }
            }
            152 => {
                let _ = write!(
                    out,
                    "dcl_hs_max_tessfactor l({})",
                    // a float even with hex literals
                    number::float(first)
                );
            }
            153 => {
                let _ = write!(out, "dcl_hs_fork_phase_instance_count {}", first.cast_signed());
            }
            154 => {
                let _ = write!(out, "dcl_hs_join_phase_instance_count {}", first.cast_signed());
            }
            _ => {
                let _ = write!(out, "{}", crate::opcode_name(opcode));
            }
        }
    }

    fn instruction(&self, out: &mut String, i: &Instruction) {
        // Microsoft's order: the extended suffixes, saturate, precise, the test, the sync flags, then the extended
        // groups, whatever bits the opcode gives a meaning (`sync_sat_ugroup`: bit 13 is both)
        out.push_str(mnemonic(i.opcode));
        let (suffixes, groups) = extended(i);
        out.push_str(&suffixes);
        if i.saturate {
            out.push_str("_sat");
        }
        precise(out, u32::from(i.precise_mask()));
        if conditional(i.opcode) {
            out.push_str(if i.nonzero { "_nz" } else { "_z" });
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
        // the precision of the result, the first destination's, which the sources of its type take
        let precision = i.operands.first().map_or(0, |o| o.precision);
        let format = i.format();
        let destinations = format.map_or(0, |f| f.destinations.len());
        for (n, o) in i.operands.iter().enumerate() {
            if n != 0 {
                out.push_str(", ");
            }
            let source = n.checked_sub(destinations);
            let takes = format
                .zip(source)
                .is_some_and(|(f, s)| takes_result_precision(i.opcode, f, s));
            self.annotated(out, o, style, takes.then_some(precision));
        }
        // the call site after the interface pointer's indices, `fcall fp0[1][2]`
        if let Some(function) = i.function {
            let _ = write!(out, "[{function}]");
        }
    }
}

/// Whether source `source` of an instruction is read at the precision of its result, so that the listing writes a
/// source of another precision as `{def32 as min16f}`: a source of the first destination's type (a conversion's
/// source is not), except a comparison's (its result is a mask, not a value of the sources' type), a shift's amount
/// and any source of an instruction with a resource operand (a sample's or a load's address, a `lod`'s, an atomic's
/// value). Checked against Microsoft's listings of fixtures that mix the precisions in each.
fn takes_result_precision(opcode: u16, format: OperandFormat, source: usize) -> bool {
    let (Some(result), Some(class)) = (format.destinations.first(), format.sources.get(source)) else {
        return false;
    };
    let name = crate::opcode_name(opcode);
    let comparison = matches!(name, "ieq" | "ine" | "ige" | "ilt" | "uge" | "ult");
    let shift_amount = matches!(name, "ishl" | "ishr" | "ushr") && source == 1;
    let resource = format
        .destinations
        .iter()
        .chain(format.sources)
        .any(|&c| c == OperandClass::Resource);
    result == class && *class != OperandClass::Varies && !resource && !comparison && !shift_amount
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

/// Whether a declaration's line is numbered like an instruction's: the phase markers of a hull program but its
/// `hs_decls`, and shader messages, those Microsoft finds undecipherable too.
fn numbered(d: &Declaration) -> bool {
    // hs_control_point_phase, hs_fork_phase, hs_join_phase
    matches!(d.opcode, 114..=116)
        || matches!(
            d.kind,
            Declared::ShaderMessage { .. } | Declared::CustomData { class: 4 }
        )
}

/// A shader message's characters as the listing quotes them: `\b`, `\t`, `\n`, `\r` and `\\` escaped, the other
/// characters from a space to 0x7f as they are (a quote too), a dot for the rest.
fn message_text(text: &[u8]) -> String {
    let mut out = String::new();
    for &b in text {
        match b {
            8 => out.push_str("\\b"),
            9 => out.push_str("\\t"),
            10 => out.push_str("\\n"),
            13 => out.push_str("\\r"),
            b'\\' => out.push_str("\\\\"),
            0x20..=0x7f => out.push(char::from(b)),
            _ => out.push('.'),
        }
    }
    out
}

/// A line of the program: the version, a declaration or an instruction.
enum Row<'a> {
    Version,
    Declaration(&'a Declaration),
    Instruction(&'a Instruction),
}

impl Row<'_> {
    /// The word of the token stream the row starts at.
    fn word(&self) -> usize {
        match self {
            Row::Version => 0,
            Row::Declaration(d) => d.word,
            Row::Instruction(i) => i.word,
        }
    }
}

/// The program's lines after the header: the version line, the declarations and instructions in program order, and
/// with `annotations` the `SPDB` part's lines and locations among them.
pub(super) fn write(
    out: &mut String,
    program: &Decoded,
    options: &Options,
    annotations: Option<&Annotations>,
) {
    let writer = Writer {
        sm51: (program.major, program.minor) >= (5, 1),
        hex: options.hex_literals,
    };
    let mut number: u32 = 0;
    // the prefix of a line at `word` of the token stream, numbered or not: the number (`%4u: `, or `%4u  ` before an
    // offset), then the offset
    let mut prefix = |out: &mut String, word: usize, numbered: bool| {
        if options.numbering {
            if numbered {
                let colon = if options.offsets { ' ' } else { ':' };
                let _ = write!(out, "{number:>4}{colon} ");
                number = number.saturating_add(1);
            } else {
                out.push_str("      ");
            }
        }
        if options.offsets {
            let _ = write!(out, "0x{:08X}: ", word.saturating_mul(4));
        }
    };
    // the rows in program order: declarations and instructions interleave by their words
    let mut rows = vec![Row::Version];
    let mut declarations = program.declarations.iter().peekable();
    let mut instructions = program.instructions.iter().peekable();
    loop {
        let next_declaration = declarations.peek().map(|d| d.word);
        let next_instruction = instructions.peek().map(|i| i.word);
        match (next_declaration, next_instruction) {
            (Some(d), i) if i.is_none_or(|i| d < i) => rows.extend(declarations.next().map(Row::Declaration)),
            (_, Some(_)) => rows.extend(instructions.next().map(Row::Instruction)),
            _ => break,
        }
    }
    let offset = |row: &Row<'_>| u32::try_from(row.word().saturating_mul(4)).unwrap_or(u32::MAX);
    // the file and line of the last `#line`
    let mut source: Option<(&str, u32)> = None;
    let mut depth: i32 = 0;
    for (n, row) in rows.iter().enumerate() {
        let at = offset(row);
        let mut text = String::new();
        let numbered = match row {
            Row::Version => {
                text.push_str(&program.target());
                false
            }
            Row::Declaration(d) => {
                // a shader message stands among the instructions, indented as they are
                if matches!(d.kind, Declared::ShaderMessage { .. }) {
                    text.push_str(&" ".repeat(usize::try_from(depth).unwrap_or(0).saturating_mul(2)));
                }
                writer.declaration(&mut text, d);
                numbered(d)
            }
            Row::Instruction(i) => {
                let (before, after) = indentation(i.opcode);
                depth = depth.saturating_add(before).max(0);
                text.push_str(&" ".repeat(usize::try_from(depth).unwrap_or(0).saturating_mul(2)));
                writer.instruction(&mut text, i);
                depth = depth.saturating_add(after);
                true
            }
        };
        let bare = text.trim_start();
        if let Some(a) = annotations {
            if a.first == Some(at) && !a.initial.is_empty() {
                out.push_str("//\n// Initial variable locations:\n");
                let last = a.initial.len().saturating_sub(1);
                for (g, group) in a.initial.iter().enumerate() {
                    let _ = writeln!(out, "//   {group}{}", if g < last { "; " } else { "" });
                }
                if let Some(error) = a.initial_error {
                    let _ = writeln!(out, "// <internal error> {error}\n");
                }
                out.push_str("//\n");
            }
            // a `#line` where the line or the file changes: the path with the first, a new file and a function
            // body's label (whatever its control bits add to its text); an empty line before each but the first after
            // the initial locations
            let body = matches!(row, Row::Instruction(i) if crate::opcode_name(i.opcode) == "label"
                && i.operands.first().is_some_and(|o| o.register == Register::FunctionBody));
            if let Some((path, line)) = a.sources.get(&at)
                && source != Some((path.as_str(), *line))
            {
                match source {
                    None if a.initial.is_empty() => {
                        let _ = writeln!(out, "\n#line {line} \"{path}\"");
                    }
                    None => {
                        let _ = writeln!(out, "#line {line} \"{path}\"");
                    }
                    Some((file, _)) if file != path || body => {
                        let _ = writeln!(out, "\n#line {line} \"{path}\"");
                    }
                    Some(_) => {
                        let _ = writeln!(out, "\n#line {line}");
                    }
                }
                source = Some((path.as_str(), *line));
            }
        }
        prefix(out, row.word(), numbered);
        out.push_str(&text);
        // after an instruction, the locations that start at the next row (`else` says they are the prior ones, `call`
        // the ones after the call), up to one Microsoft's disassembler could not name, which ends the comment with its
        // internal error
        if let Some(a) = annotations
            && a.first.is_none_or(|first| at >= first)
            && !bare.starts_with("dcl_")
            && let Some(next) = rows.get(n.saturating_add(1))
            && let starting = a.after(at, offset(next))
            && !starting.is_empty()
        {
            // by the opcode, whatever its control bits add to the text (`else_sat`)
            let label = match row {
                Row::Instruction(i) => match crate::opcode_name(i.opcode) {
                    "else" => "Prior locations: ",
                    "call" => "Post-call locations: ",
                    _ => "",
                },
                _ => "",
            };
            let end = starting
                .iter()
                .position(|l| l.error.is_some())
                .map_or(starting.len(), |e| e.saturating_add(1));
            let written: Vec<&str> = starting.iter().take(end).map(|l| l.text.as_str()).collect();
            let _ = write!(out, "  // {label}{}", written.join("; "));
            if let Some(error) = starting.get(end.saturating_sub(1)).and_then(|l| l.error) {
                let _ = writeln!(out, "\n// <internal error> {error}");
            }
        }
        out.push('\n');
    }
}
