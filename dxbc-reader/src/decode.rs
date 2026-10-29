//! The token-level decoder of Shader Model 4 and 5 programs: any stage's version token, declarations as typed
//! records, and instructions as an opcode, its control bits, its extended tokens and its operands. It decides nothing
//! about which instructions a caller can use: they are all returned, and the caller refuses what it cannot handle. A token
//! it cannot read at all (an operand register type it has no name for, a truncated instruction) is an error naming the
//! word.

use crate::format::{OperandFormat, operand_format};
use crate::opcodes::NAMES;
use crate::{Result, error};

/// The low byte of `v`.
fn low8(v: u32) -> u8 {
    let [byte, ..] = v.to_le_bytes();
    byte
}

/// The low 16 bits of `v`.
fn low16(v: u32) -> u16 {
    let [a, b, ..] = v.to_le_bytes();
    u16::from_le_bytes([a, b])
}

/// The kind of register an operand names.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Register {
    /// A temporary register (`r<n>`).
    Temp,
    /// An input register (`v<n>`).
    Input,
    /// An output register (`o<n>`).
    Output,
    /// An indexable temporary (`x<n>[i]`).
    IndexableTemp,
    /// A constant buffer register (`cb<slot>[row]`).
    Constant,
    /// An immediate operand (`l(...)`), its values in [`Operand::immediate`].
    Immediate,
    /// A shader resource view (`t<n>`).
    Texture,
    /// A sampler (`s<n>`).
    Sampler,
    /// The null register (`null`), a destination that discards its result.
    Null,
    /// An unordered-access view (`u<n>`).
    Uav,
    /// The immediate constant buffer (`icb[n]`), its rows the program's own.
    ImmediateBuffer,
    /// `vPrim`, the primitive id input.
    PrimitiveId,
    /// `vCoverage`, the input coverage mask.
    InputCoverage,
    /// `oDepth`.
    OutputDepth,
    /// `oDepthGE`, a depth output that is at least the rasterized depth.
    OutputDepthGreaterEqual,
    /// `oDepthLE`, a depth output that is at most the rasterized depth.
    OutputDepthLessEqual,
    /// `oMask`, the coverage output.
    OutputCoverage,
    /// `rasterizer`: the render target as `sample_info` and `sample_pos` query it (its sample count, a sample's position).
    Rasterizer,
    /// `oStencilRef`, the stencil reference output.
    OutputStencilRef,
    /// `g<n>`, thread-group shared memory.
    GroupSharedMemory,
    /// `vThreadID`, `vThreadGroupID`, `vThreadIDInGroup` and `vThreadIDInGroupFlattened`, a compute program's ids.
    ThreadId,
    /// `vThreadGroupID`.
    ThreadGroupId,
    /// `vThreadIDInGroup`.
    ThreadIdInGroup,
    /// `vThreadIDInGroupFlattened`.
    ThreadIdInGroupFlattened,
    /// `vOutputControlPointID`, `vForkInstanceID`, `vJoinInstanceID`: a hull program's phase numbers.
    OutputControlPointId,
    /// `vForkInstanceID`, a hull program's fork phase instance.
    ForkInstanceId,
    /// `vJoinInstanceID`, a hull program's join phase instance.
    JoinInstanceId,
    /// `vicp[point][register]`: an input control point of a hull or domain program.
    InputControlPoint,
    /// `vocp[point][register]`: an output control point a hull program's patch-constant phases read.
    OutputControlPoint,
    /// `vpc[register]`: a patch constant a domain program reads (or a hull program's join phase).
    InputPatchConstant,
    /// `vDomain`: a domain program's location in its patch.
    InputDomainPoint,
    /// `m<n>`: a geometry program's output stream.
    Stream,
    /// `vGSInstanceID`.
    GsInstanceId,
}
impl Register {
    /// How many index dimensions an operand of this register has in Shader Model 5.0.
    fn dimensions(self) -> u32 {
        match self {
            Register::Immediate
            | Register::Null
            | Register::PrimitiveId
            | Register::InputCoverage
            | Register::OutputDepth
            | Register::OutputDepthGreaterEqual
            | Register::OutputDepthLessEqual
            | Register::OutputCoverage
            | Register::Rasterizer
            | Register::OutputStencilRef
            | Register::ThreadId
            | Register::ThreadGroupId
            | Register::ThreadIdInGroup
            | Register::ThreadIdInGroupFlattened
            | Register::OutputControlPointId
            | Register::ForkInstanceId
            | Register::JoinInstanceId
            | Register::InputDomainPoint
            | Register::GsInstanceId => 0,
            Register::Constant
            | Register::IndexableTemp
            | Register::InputControlPoint
            | Register::OutputControlPoint => 2,
            _ => 1,
        }
    }
    fn from_type(n: u32) -> Option<Self> {
        Some(match n {
            0 => Register::Temp,
            1 => Register::Input,
            2 => Register::Output,
            3 => Register::IndexableTemp,
            4 => Register::Immediate,
            6 => Register::Sampler,
            7 => Register::Texture,
            8 => Register::Constant,
            9 => Register::ImmediateBuffer,
            11 => Register::PrimitiveId,
            12 => Register::OutputDepth,
            13 => Register::Null,
            14 => Register::Rasterizer,
            15 => Register::OutputCoverage,
            16 => Register::Stream,
            22 => Register::OutputControlPointId,
            23 => Register::ForkInstanceId,
            24 => Register::JoinInstanceId,
            25 => Register::InputControlPoint,
            26 => Register::OutputControlPoint,
            27 => Register::InputPatchConstant,
            28 => Register::InputDomainPoint,
            37 => Register::GsInstanceId,
            30 => Register::Uav,
            31 => Register::GroupSharedMemory,
            32 => Register::ThreadId,
            33 => Register::ThreadGroupId,
            34 => Register::ThreadIdInGroup,
            36 => Register::ThreadIdInGroupFlattened,
            35 => Register::InputCoverage,
            38 => Register::OutputDepthGreaterEqual,
            39 => Register::OutputDepthLessEqual,
            41 => Register::OutputStencilRef,
            _ => return None,
        })
    }
}

/// The components of a register an operand selects.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Selection {
    /// A write mask: bit 0 is x, bit 3 is w.
    Mask(u8),
    /// A four-component swizzle: for each result lane the source lane (0 x to 3 w) it reads.
    Swizzle([u8; 4]),
    /// One source lane (0 x to 3 w).
    Scalar(u8),
    /// No selection: the operand has no components (a sampler, a resource).
    None,
}

/// An instruction's or declaration's operand.
#[derive(Clone, Debug)]
pub struct Operand {
    /// The kind of register it names.
    pub register: Register,
    /// Which components it selects.
    pub selection: Selection,
    /// Its index dimensions, outermost first: none for an immediate, one for `r3`, two for `cb2[5]`.
    pub indices: Vec<Index>,
    /// The values of an immediate operand (one lane repeated, or four); zero for other registers.
    pub immediate: [u32; 4],
    /// 0 none, 1 negate, 2 absolute, 3 negated absolute (float sources); 4 two's-complement negate (an integer
    /// instruction's negate; the encoding has no such value, so a caller that knows the instruction reads integers sets it).
    pub modifier: u8,
    /// The minimum-precision annotation of the operand's extended token (0 none; 1 float16, 2 float2_8, 4 sint16,
    /// 5 uint16).
    pub precision: u8,
    /// The operand's extended token marks it as a non-uniform resource index.
    pub non_uniform: bool,
}

/// One index dimension of an operand: a constant, a relative register, or both added.
#[derive(Clone, Debug)]
pub struct Index {
    /// The constant part of the index.
    pub base: u32,
    /// The register whose component is added to `base`, where the index is relative.
    pub relative: Option<Box<Operand>>,
}

/// An instruction as stored.
#[derive(Clone, Debug)]
pub struct Instruction {
    /// The instruction's first word in the token stream.
    pub word: usize,
    /// The opcode token's low 11 bits (see [`opcode_name`]).
    pub opcode: u16,
    /// The opcode token's bits 11 to 23: saturate and the opcode-specific controls (the test of a conditional, a
    /// `resinfo` return type, the interpolation of a declaration).
    pub control: u32,
    /// The opcode's extended tokens as stored (sample offsets, resource dimension, return type).
    pub extensions: Vec<u32>,
    /// The saturate bit of the opcode token.
    pub saturate: bool,
    /// A conditional (`if`, `breakc`, `continuec`) taken when its operand is nonzero (`_nz`), else when zero (`_z`).
    pub nonzero: bool,
    /// The operands, destination first where the instruction has one.
    pub operands: Vec<Operand>,
}
impl Instruction {
    /// The opcode's name (`mov`, `add`, ...), or `unknown opcode`.
    pub fn name(&self) -> &'static str {
        opcode_name(self.opcode)
    }
    /// The sample offsets of the extended token of kind 1 (`_aoffimmi`), if the instruction has one.
    pub fn sample_offset(&self) -> Option<[i32; 3]> {
        self.extension(1).map(|e| {
            let field = |shift: u32| (((e >> shift) & 15) as i32) << 28 >> 28;
            [field(9), field(13), field(17)]
        })
    }
    /// The resource dimension and structured stride of the extended token of kind 2.
    pub fn resource_dimension(&self) -> Option<(u32, u32)> {
        self.extension(2).map(|e| ((e >> 6) & 31, (e >> 11) & 0xf_ffff))
    }
    /// The return-type token of the extended token of kind 3 (four nibbles).
    pub fn return_type(&self) -> Option<u32> {
        self.extension(3).map(|e| (e >> 6) & 0xffff)
    }
    fn extension(&self, kind: u32) -> Option<u32> {
        self.extensions.iter().copied().find(|e| e & 63 == kind)
    }
    /// The opcode's operand format (see [`operand_format`]); `decode` has checked the operand count against it.
    pub fn format(&self) -> Option<OperandFormat> {
        operand_format(self.opcode)
    }
    /// The destination operands and the source operands, split as the opcode's format says; `None` for an opcode
    /// with no format.
    pub fn destinations_and_sources(&self) -> Option<(&[Operand], &[Operand])> {
        self.operands.split_at_checked(self.format()?.destinations.len())
    }
}

/// The name of an opcode in Microsoft's tokenized program format, or `unknown opcode`.
pub fn opcode_name(opcode: u16) -> &'static str {
    NAMES
        .get(usize::from(opcode))
        .copied()
        .unwrap_or("unknown opcode")
}

/// The type of a program's four return lanes in a resource declaration, as D3D_RETURN_TYPE codes (1 unorm, 2 snorm,
/// 3 sint, 4 uint, 5 float, 6 mixed, 7 double, 8 continued, 9 unused), one nibble per lane.
pub type ReturnCodes = [u8; 4];

/// A declaration, typed. `word` is where it starts.
#[derive(Clone, Debug)]
pub struct Declaration {
    /// The word of the token stream the declaration starts at.
    pub word: usize,
    /// The opcode token's low 11 bits (see [`opcode_name`]).
    pub opcode: u16,
    /// The opcode token's bits 11 to 23 as stored.
    pub control: u32,
    /// The declaration, typed.
    pub kind: Declared,
}

/// A declaration, typed where this reader knows its layout.
#[derive(Clone, Debug)]
pub enum Declared {
    /// `dcl_temps`.
    Temps(u32),
    /// `dcl_indexable_temp x<register>[size], components`.
    IndexableTemp {
        /// The register index (the `<n>` of `x<n>`).
        register: u32,
        /// The number of elements.
        size: u32,
        /// The number of components per element.
        components: u32,
    },
    /// `dcl_globalFlags`: the control bits as stored (bit 0 refactoring allowed, 1 double precision, 2 forced early
    /// depth-stencil, 3 raw and structured buffers, 4 skip optimization, 5 min precision, 6 double extensions, 7
    /// shader extensions).
    GlobalFlags(u32),
    /// `dcl_constantbuffer cb<slot>[rows]`; `dynamic` when it is dynamically indexed.
    ConstantBuffer {
        /// The buffer slot (the `<slot>` of `cb<slot>`).
        slot: u32,
        /// The number of 16-byte rows; 0 where the declaration states none.
        rows: u32,
        /// The buffer is dynamically indexed.
        dynamic: bool,
        /// The number of index dimensions the operand had (1 or 2).
        dimensions: usize,
    },
    /// `dcl_sampler s<slot>`, its mode: 0 default, 1 comparison, 2 mono.
    Sampler {
        /// The sampler slot.
        slot: u32,
        /// 0 default, 1 comparison, 2 mono.
        mode: u32,
    },
    /// `dcl_resource_<dimension> t<slot>`: the D3D resource dimension code, the sample count of a multisampled one,
    /// and the four return types.
    Resource {
        /// The resource slot.
        slot: u32,
        /// The D3D resource dimension code.
        dimension: u32,
        /// The sample count of a multisampled resource.
        samples: u32,
        /// The return type of each lane.
        returns: ReturnCodes,
        /// The return type token as stored.
        token: u32,
    },
    /// `dcl_resource_raw t<slot>`.
    ResourceRaw {
        /// The resource slot.
        slot: u32,
    },
    /// `dcl_resource_structured t<slot>, stride`.
    ResourceStructured {
        /// The resource slot.
        slot: u32,
        /// The element stride in bytes.
        stride: u32,
    },
    /// `dcl_uav_typed` and its control bits (dimension in bits 0 to 4, globally coherent bit 5).
    UavTyped {
        /// The UAV slot.
        slot: u32,
        /// The D3D resource dimension code.
        dimension: u32,
        /// The return type of each lane.
        returns: ReturnCodes,
        /// The return type token as stored.
        token: u32,
        /// The opcode token's control bits.
        control: u32,
    },
    /// `dcl_uav_raw u<slot>`.
    UavRaw {
        /// The UAV slot.
        slot: u32,
        /// The opcode token's control bits.
        control: u32,
    },
    /// `dcl_uav_structured u<slot>, stride`.
    UavStructured {
        /// The UAV slot.
        slot: u32,
        /// The element stride in bytes.
        stride: u32,
        /// The opcode token's control bits.
        control: u32,
    },
    /// `dcl_thread_group x, y, z`.
    ThreadGroup([u32; 3]),
    /// `dcl_tgsm_raw g<register>, bytes`.
    GroupSharedRaw {
        /// The shared memory register index.
        register: u32,
        /// Its size in bytes.
        bytes: u32,
    },
    /// `dcl_tgsm_structured g<register>, stride, count`.
    GroupSharedStructured {
        /// The shared memory register index.
        register: u32,
        /// The element stride in bytes.
        stride: u32,
        /// The number of elements.
        count: u32,
    },
    /// An input register or special input: `dcl_input`, `_sgv`, `_siv`, `_ps`, `_ps_sgv`, `_ps_siv`. `interpolation` is
    /// a pixel input's `D3D_INTERPOLATION_MODE`; `name` a system value's `D3D_NAME`.
    Input {
        /// The input register or special input the declaration names.
        operand: Operand,
        /// The interpolation mode of a pixel input.
        interpolation: Option<u32>,
        /// The system value (`D3D_NAME`) of a `_sgv` or `_siv` declaration.
        name: Option<u32>,
    },
    /// An output register or special output: `dcl_output`, `_sgv`, `_siv`.
    Output {
        /// The output register or special output the declaration names.
        operand: Operand,
        /// The system value (`D3D_NAME`) of a `_siv` or `_sgv` declaration.
        name: Option<u32>,
    },
    /// `dcl_immediateConstantBuffer`.
    ImmediateBuffer(Vec<[u32; 4]>),
    /// Custom data that is not an immediate constant buffer (a comment, debug information, ...) by its class.
    CustomData {
        /// The custom data class.
        class: u32,
    },
    /// A declaration this decoder does not type: stage-specific (geometry, tessellation, compute), interface tables.
    Other {
        /// The opcode.
        opcode: u16,
        /// The opcode token's control bits.
        control: u32,
        /// The declaration's words after its operands, as stored.
        words: Vec<u32>,
    },
}

/// The kind of program a version token names.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ProgramType {
    /// A pixel program (`ps`).
    Pixel,
    /// A vertex program (`vs`).
    Vertex,
    /// A geometry program (`gs`).
    Geometry,
    /// A hull program (`hs`).
    Hull,
    /// A domain program (`ds`).
    Domain,
    /// A compute program (`cs`).
    Compute,
}
impl ProgramType {
    /// The target's stage prefix (`ps`, `vs`, ...).
    pub fn name(self) -> &'static str {
        match self {
            ProgramType::Pixel => "ps",
            ProgramType::Vertex => "vs",
            ProgramType::Geometry => "gs",
            ProgramType::Hull => "hs",
            ProgramType::Domain => "ds",
            ProgramType::Compute => "cs",
        }
    }
}

/// A decoded token stream: its target, declarations and instructions, each in program order.
#[derive(Clone, Debug)]
pub struct Decoded {
    /// The program's stage.
    pub kind: ProgramType,
    /// The shader model's major version.
    pub major: u32,
    /// The shader model's minor version.
    pub minor: u32,
    /// The declarations, in program order.
    pub declarations: Vec<Declaration>,
    /// The instructions, in program order.
    pub instructions: Vec<Instruction>,
}
impl Decoded {
    /// The target's name (`ps_5_0`).
    pub fn target(&self) -> String {
        format!("{}_{}_{}", self.kind.name(), self.major, self.minor)
    }
}

struct Cursor<'a> {
    words: &'a [u32],
    at: usize,
    origin: usize,
    /// The program's type: the input registers of a geometry, hull or domain program are indexed by vertex.
    kind: ProgramType,
}
impl Cursor<'_> {
    /// The word the cursor is at, in the token stream.
    fn position(&self) -> usize {
        self.origin.saturating_add(self.at)
    }
    fn take(&mut self) -> Result<u32> {
        let value = *self
            .words
            .get(self.at)
            .ok_or_else(|| error(self.position(), "truncated instruction"))?;
        self.at = self.at.saturating_add(1);
        Ok(value)
    }
    fn rest(&mut self) -> Vec<u32> {
        let rest = self.words.get(self.at..).unwrap_or_default().to_vec();
        self.at = self.words.len();
        rest
    }
    fn operand(&mut self, depth: usize) -> Result<Operand> {
        let pos = self.position();
        if depth > 2 {
            return Err(error(pos, "nested relative operand exceeds bound"));
        }
        let t = self.take()?;
        let components = t & 3;
        let selection = match components {
            0 => Selection::None,
            1 => Selection::Scalar(0),
            2 => match (t >> 2) & 3 {
                0 => Selection::Mask(low8((t >> 4) & 15)),
                1 => Selection::Swizzle([4, 6, 8, 10].map(|shift| low8((t >> shift) & 3))),
                2 => Selection::Scalar(low8((t >> 4) & 3)),
                _ => return Err(error(pos, "reserved component selection")),
            },
            _ => return Err(error(pos, "unsupported N-component operand")),
        };
        let kind = (t >> 12) & 255;
        let register = Register::from_type(kind)
            .ok_or_else(|| error(pos, format!("unsupported operand register type {kind}")))?;
        let (mut modifier, mut precision, mut non_uniform) = (0, 0, false);
        if t >> 31 != 0 {
            let mut ext = self.take()?;
            loop {
                // only the modifier extension (kind 1) exists in Shader Model 4 and 5
                if ext & 63 != 1 {
                    return Err(error(pos, "unsupported extended operand (precision/modifier)"));
                }
                modifier = low8((ext >> 6) & 255);
                precision = low8((ext >> 14) & 7);
                non_uniform = ext & (1 << 17) != 0;
                if ext >> 31 == 0 {
                    break;
                }
                ext = self.take()?;
            }
            if modifier > 3 {
                return Err(error(pos, "unsupported extended operand (precision/modifier)"));
            }
        }
        let dimensions = (t >> 20) & 3;
        let expected = match (register, self.kind) {
            (Register::Input, ProgramType::Geometry | ProgramType::Hull | ProgramType::Domain) => 2,
            _ => register.dimensions(),
        };
        if dimensions != expected {
            return Err(error(pos, "unexpected operand index dimensions"));
        }
        let mut indices = Vec::new();
        // the representation of each index dimension, three bits each from bit 22
        for shift in [22, 25, 28].into_iter().take(dimensions as usize) {
            let representation = (t >> shift) & 7;
            if !matches!(representation, 0 | 2 | 3) {
                return Err(error(pos, "unsupported 64-bit/reserved index"));
            }
            let base = if representation != 2 { self.take()? } else { 0 };
            let relative = if representation != 0 {
                Some(Box::new(self.operand(depth.saturating_add(1))?))
            } else {
                None
            };
            indices.push(Index { base, relative });
        }
        let mut immediate = [0; 4];
        if register == Register::Immediate {
            match components {
                1 => immediate = [self.take()?; 4],
                2 => {
                    for x in &mut immediate {
                        *x = self.take()?;
                    }
                }
                _ => return Err(error(pos, "immediate requires one or four components")),
            }
        }
        Ok(Operand {
            register,
            selection,
            indices,
            immediate,
            modifier,
            precision,
            non_uniform,
        })
    }
}

fn return_codes(token: u32) -> ReturnCodes {
    [0, 4, 8, 12].map(|shift| low8((token >> shift) & 15))
}

/// The opcodes that are declarations (and the phase markers of hull programs, which carry none): 88-106 and
/// 143-162 of Direct3D 10 and 11, the hull phases 113-116 and `dcl_gs_instance_count` (206).
fn is_declaration(opcode: u16) -> bool {
    matches!(opcode, 88..=106 | 113..=116 | 143..=162 | 206)
}

/// Decode a complete token stream: version token, length, then declarations and instructions to its end.
pub fn decode(words: &[u32]) -> Result<Decoded> {
    let (Some(&version), Some(&length)) = (words.first(), words.get(1)) else {
        return Err(error(0, "token stream shorter than its header"));
    };
    if usize::try_from(length).ok() != Some(words.len()) {
        return Err(error(
            1,
            format!(
                "the declared length is {length} words, the stream has {}",
                words.len()
            ),
        ));
    }
    let kind = match version >> 16 {
        0 => ProgramType::Pixel,
        1 => ProgramType::Vertex,
        2 => ProgramType::Geometry,
        3 => ProgramType::Hull,
        4 => ProgramType::Domain,
        5 => ProgramType::Compute,
        other => {
            return Err(error(
                0,
                format!("program type {other} is not a Shader Model 4 or 5 stage"),
            ));
        }
    };
    let mut result = Decoded {
        kind,
        major: (version >> 4) & 15,
        minor: version & 15,
        declarations: Vec::new(),
        instructions: Vec::new(),
    };
    let mut at = 2;
    while let Some(&t) = words.get(at) {
        let opcode = low16(t & 0x7ff);
        // customdata: its class in the opcode token's upper bits, its length (these two words included) the next word
        if opcode == 53 {
            let len = words
                .get(at.saturating_add(1))
                .and_then(|&n| usize::try_from(n).ok())
                .unwrap_or(0);
            let end = at.checked_add(len).filter(|&end| len >= 2 && end <= words.len());
            let (Some(end), Some(body)) = (end, words.get(at.saturating_add(2)..at.saturating_add(len)))
            else {
                return Err(error(
                    at,
                    format!(
                        "customdata of {len} words (at least 2) does not fit the stream's {} words",
                        words.len()
                    ),
                ));
            };
            let class = t >> 11;
            let kind = if class == 3 {
                let (rows, rest) = body.as_chunks::<4>();
                if !rest.is_empty() {
                    return Err(error(
                        at,
                        format!(
                            "an immediate constant buffer of {} words, expected whole rows of 4",
                            body.len()
                        ),
                    ));
                }
                Declared::ImmediateBuffer(rows.to_vec())
            } else {
                Declared::CustomData { class }
            };
            result.declarations.push(Declaration {
                word: at,
                opcode,
                control: class,
                kind,
            });
            at = end;
            continue;
        }
        let len = usize::try_from((t >> 24) & 127).unwrap_or(0);
        if len == 0 {
            return Err(error(at, "instruction length 0 (at least 1)"));
        }
        let end = at.checked_add(len).filter(|&end| end <= words.len());
        let (Some(end), Some(body)) = (end, words.get(at.saturating_add(1)..at.saturating_add(len))) else {
            return Err(error(
                at,
                format!(
                    "instruction length {len} (at least 1) does not fit the stream's {} words",
                    words.len()
                ),
            ));
        };
        let mut c = Cursor {
            words: body,
            at: 0,
            origin: at.saturating_add(1),
            kind,
        };
        let mut extensions = Vec::new();
        let mut extended = t >> 31 != 0;
        while extended {
            let ext = c.take()?;
            extensions.push(ext);
            extended = ext >> 31 != 0;
        }
        let control = (t >> 11) & 0x1fff;
        if is_declaration(opcode) {
            let kind = declaration(opcode, control, &mut c)?;
            if c.at != c.words.len() {
                return Err(error(
                    at,
                    format!(
                        "{} words after the operands of {}",
                        c.words.len().saturating_sub(c.at),
                        opcode_name(opcode)
                    ),
                ));
            }
            result.declarations.push(Declaration {
                word: at,
                opcode,
                control,
                kind,
            });
        } else {
            let mut operands = Vec::new();
            while c.at < c.words.len() {
                operands.push(c.operand(0)?);
            }
            if let Some(format) = operand_format(opcode)
                && operands.len() != format.operands()
            {
                return Err(error(
                    at,
                    format!(
                        "{} has {} operands, its format is {} destinations and {} sources",
                        opcode_name(opcode),
                        operands.len(),
                        format.destinations.len(),
                        format.sources.len()
                    ),
                ));
            }
            result.instructions.push(Instruction {
                word: at,
                opcode,
                control,
                extensions,
                saturate: t & 0x2000 != 0,
                nonzero: t & 0x4_0000 != 0,
                operands,
            });
        }
        at = end;
    }
    Ok(result)
}

fn declaration(opcode: u16, control: u32, c: &mut Cursor<'_>) -> Result<Declared> {
    let pos = c.origin.saturating_sub(1);
    let slot = |o: &Operand| -> Result<u32> {
        o.indices
            .first()
            .map(|i| i.base)
            .ok_or_else(|| error(pos, "missing declaration index"))
    };
    Ok(match opcode {
        104 => Declared::Temps(c.take()?),
        105 => Declared::IndexableTemp {
            register: c.take()?,
            size: c.take()?,
            components: c.take()?,
        },
        106 => Declared::GlobalFlags(control),
        88 => {
            let o = c.operand(0)?;
            let token = c.take()?;
            Declared::Resource {
                slot: slot(&o)?,
                dimension: control & 31,
                samples: (control >> 5) & 127,
                returns: return_codes(token),
                token,
            }
        }
        89 => {
            let o = c.operand(0)?;
            Declared::ConstantBuffer {
                slot: slot(&o)?,
                rows: o.indices.get(1).map_or(0, |i| i.base),
                dynamic: control & 1 != 0,
                dimensions: o.indices.len(),
            }
        }
        90 => {
            let o = c.operand(0)?;
            Declared::Sampler {
                slot: slot(&o)?,
                mode: control & 15,
            }
        }
        95..=100 => {
            let operand = c.operand(0)?;
            let pixel = matches!(opcode, 98..=100);
            let interpolation = pixel.then_some(control & 15);
            let name = matches!(opcode, 96 | 97 | 99 | 100)
                .then(|| c.take())
                .transpose()?;
            Declared::Input {
                operand,
                interpolation,
                name,
            }
        }
        101..=103 => {
            let operand = c.operand(0)?;
            let name = (opcode != 101).then(|| c.take()).transpose()?;
            Declared::Output { operand, name }
        }
        156 => {
            let o = c.operand(0)?;
            let token = c.take()?;
            Declared::UavTyped {
                slot: slot(&o)?,
                dimension: control & 31,
                returns: return_codes(token),
                token,
                control,
            }
        }
        157 => {
            let o = c.operand(0)?;
            Declared::UavRaw {
                slot: slot(&o)?,
                control,
            }
        }
        158 => {
            let o = c.operand(0)?;
            Declared::UavStructured {
                slot: slot(&o)?,
                stride: c.take()?,
                control,
            }
        }
        155 => Declared::ThreadGroup([c.take()?, c.take()?, c.take()?]),
        159 => {
            let o = c.operand(0)?;
            Declared::GroupSharedRaw {
                register: slot(&o)?,
                bytes: c.take()?,
            }
        }
        160 => {
            let o = c.operand(0)?;
            Declared::GroupSharedStructured {
                register: slot(&o)?,
                stride: c.take()?,
                count: c.take()?,
            }
        }
        161 => {
            let o = c.operand(0)?;
            Declared::ResourceRaw { slot: slot(&o)? }
        }
        162 => {
            let o = c.operand(0)?;
            Declared::ResourceStructured {
                slot: slot(&o)?,
                stride: c.take()?,
            }
        }
        _ => Declared::Other {
            opcode,
            control,
            words: c.rest(),
        },
    })
}
