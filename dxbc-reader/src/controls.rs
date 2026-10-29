//! Typed views of the control bits of an opcode token: the bits 11 to 23 that [`Instruction::control`] and
//! [`Declaration::control`] keep as stored, read as the fields the token format gives them for the opcodes that use them.
//! Only the bits some program of the games read carries are named: the `precise` mask of an arithmetic instruction, the
//! flags of a `sync`, the return type of `resinfo` and `sample_info`, the flags of `dcl_globalFlags`, and the values the
//! geometry and tessellation declarations hold in their control bits or in the word after the token.
use crate::decode::{Declaration, Declared, Instruction};

/// The low byte of `v`.
fn low8(v: u32) -> u8 {
    let [byte, ..] = v.to_le_bytes();
    byte
}

/// What a `sync` instruction waits for (control bits 0 to 3; the listing of Microsoft's disassembler adds a suffix for
/// each: `_t`, `_g`, `_ugroup`, `_uglobal`).
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct SyncFlags {
    /// Bit 0: every thread of the group reaches the instruction first (`_t`).
    pub threads_in_group: bool,
    /// Bit 1: group shared memory accesses are complete (`_g`).
    pub group_shared_memory: bool,
    /// Bit 2: unordered-access view accesses are complete within the group (`_ugroup`).
    pub uav_group: bool,
    /// Bit 3: unordered-access view accesses are complete across all groups (`_uglobal`).
    pub uav_global: bool,
}

/// The type a `resinfo` or `sample_info` instruction returns (the `_uint` and `_rcpfloat` suffixes of Microsoft's
/// listing; none suffix is a float).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum InfoReturn {
    /// A float.
    Float,
    /// The reciprocal of a float (`resinfo_rcpfloat`; the games' programs do not use it).
    ReciprocalFloat,
    /// An unsigned integer (`_uint`).
    Uint,
}

/// The flags of a `dcl_globalFlags` declaration (its control bits). The names are the ones Microsoft's disassembler
/// prints; the games' programs set bits 0 to 5.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct GlobalFlags {
    /// Bit 0, `refactoringAllowed`.
    pub refactoring_allowed: bool,
    /// Bit 1, `enableDoublePrecisionFloatOps`.
    pub double_precision: bool,
    /// Bit 2, `forceEarlyDepthStencil`.
    pub force_early_depth_stencil: bool,
    /// Bit 3, `enableRawAndStructuredBuffers`.
    pub raw_and_structured_buffers: bool,
    /// Bit 4, `skipOptimization`.
    pub skip_optimization: bool,
    /// Bit 5, `enableMinimumPrecision`.
    pub minimum_precision: bool,
    /// The bits above bit 5, as stored (shifted down by six).
    pub other: u32,
}

impl GlobalFlags {
    /// The flags of the control bits `control` of a `dcl_globalFlags` declaration.
    pub fn from_bits(control: u32) -> Self {
        let bit = |n: u32| (control >> n) & 1 != 0;
        GlobalFlags {
            refactoring_allowed: bit(0),
            double_precision: bit(1),
            force_early_depth_stencil: bit(2),
            raw_and_structured_buffers: bit(3),
            skip_optimization: bit(4),
            minimum_precision: bit(5),
            other: control >> 6,
        }
    }
}

const RESINFO: u16 = 61;
const SAMPLE_INFO: u16 = 111;
const SYNC: u16 = 190;
const GS_OUTPUT_TOPOLOGY: u16 = 92;
const GS_INPUT_PRIMITIVE: u16 = 93;
const GS_MAX_OUTPUT_VERTICES: u16 = 94;
const INPUT_CONTROL_POINTS: u16 = 147;
const OUTPUT_CONTROL_POINTS: u16 = 148;
const TESS_DOMAIN: u16 = 149;
const TESS_PARTITIONING: u16 = 150;
const TESS_OUTPUT_PRIMITIVE: u16 = 151;
const HS_MAX_TESS_FACTOR: u16 = 152;
const HS_FORK_INSTANCES: u16 = 153;
const HS_JOIN_INSTANCES: u16 = 154;

impl Instruction {
    /// The components the instruction is marked `precise` for (control bits 8 to 11, the token's bits 19 to 22): bit 0 x
    /// to bit 3 w, zero where it is not marked. The compiler marks every instruction of a `precise` expression.
    pub fn precise_mask(&self) -> u8 {
        low8((self.control >> 8) & 15)
    }

    /// What a `sync` instruction waits for; `None` for any other instruction.
    pub fn sync_flags(&self) -> Option<SyncFlags> {
        (self.opcode == SYNC).then(|| {
            let bit = |n: u32| (self.control >> n) & 1 != 0;
            SyncFlags {
                threads_in_group: bit(0),
                group_shared_memory: bit(1),
                uav_group: bit(2),
                uav_global: bit(3),
            }
        })
    }

    /// The type a `resinfo` or `sample_info` returns; `None` for any other instruction, and for a return type the
    /// token format does not define.
    pub fn info_return(&self) -> Option<InfoReturn> {
        match (self.opcode, self.control & 3) {
            (RESINFO | SAMPLE_INFO, 0) => Some(InfoReturn::Float),
            (RESINFO, 1) => Some(InfoReturn::ReciprocalFloat),
            (RESINFO, 2) | (SAMPLE_INFO, 1) => Some(InfoReturn::Uint),
            _ => None,
        }
    }
}

impl Declaration {
    /// The flags of a `dcl_globalFlags` declaration; `None` for any other declaration.
    pub fn global_flags(&self) -> Option<GlobalFlags> {
        match self.kind {
            Declared::GlobalFlags(bits) => Some(GlobalFlags::from_bits(bits)),
            _ => None,
        }
    }

    /// The value in the first word after the token of a declaration this reader does not type (the word of
    /// `dcl_maxout`, `dcl_hs_max_tessfactor` and the phase instance counts).
    fn first_word(&self, opcode: u16) -> Option<u32> {
        match &self.kind {
            Declared::Other { words, .. } if self.opcode == opcode => words.first().copied(),
            _ => None,
        }
    }

    /// The control value of the declaration `opcode`, `mask`ed.
    fn control_value(&self, opcode: u16, mask: u32) -> Option<u32> {
        (self.opcode == opcode).then_some(self.control & mask)
    }

    /// A geometry program's input primitive (`dcl_inputprimitive`; a `D3D_PRIMITIVE`: 1 point, 2 line, 3 triangle, 6 line
    /// and 7 triangle with adjacency).
    pub fn geometry_input_primitive(&self) -> Option<u32> {
        self.control_value(GS_INPUT_PRIMITIVE, 63)
    }

    /// A geometry program's output topology (`dcl_outputtopology`; a `D3D_PRIMITIVE_TOPOLOGY`: 1 point list, 3 line strip,
    /// 5 triangle strip).
    pub fn geometry_output_topology(&self) -> Option<u32> {
        self.control_value(GS_OUTPUT_TOPOLOGY, 63)
    }

    /// A geometry program's largest vertex count (`dcl_maxout`).
    pub fn max_output_vertex_count(&self) -> Option<u32> {
        self.first_word(GS_MAX_OUTPUT_VERTICES)
    }

    /// A hull or domain program's input control point count (`dcl_input_control_point_count`).
    pub fn input_control_point_count(&self) -> Option<u32> {
        self.control_value(INPUT_CONTROL_POINTS, 63)
    }

    /// A hull program's output control point count (`dcl_output_control_point_count`).
    pub fn output_control_point_count(&self) -> Option<u32> {
        self.control_value(OUTPUT_CONTROL_POINTS, 63)
    }

    /// The tessellator domain (`dcl_tessellator_domain`; a `D3D11_TESSELLATOR_DOMAIN`: 1 isoline, 2 triangle, 3 quad).
    pub fn tessellator_domain(&self) -> Option<u32> {
        self.control_value(TESS_DOMAIN, 7)
    }

    /// The tessellator partitioning (`dcl_tessellator_partitioning`; a `D3D11_TESSELLATOR_PARTITIONING`: 1 integer, 2 pow2,
    /// 3 fractional odd, 4 fractional even).
    pub fn tessellator_partitioning(&self) -> Option<u32> {
        self.control_value(TESS_PARTITIONING, 7)
    }

    /// The tessellator output primitive (`dcl_tessellator_output_primitive`; a `D3D11_TESSELLATOR_OUTPUT_PRIMITIVE`: 1
    /// point, 2 line, 3 triangle clockwise, 4 triangle counter-clockwise).
    pub fn tessellator_output_primitive(&self) -> Option<u32> {
        self.control_value(TESS_OUTPUT_PRIMITIVE, 7)
    }

    /// A hull program's largest tessellation factor (`dcl_hs_max_tessfactor`).
    pub fn hull_max_tess_factor(&self) -> Option<f32> {
        self.first_word(HS_MAX_TESS_FACTOR).map(f32::from_bits)
    }

    /// The instance count of a hull program's fork phase (`dcl_hs_fork_phase_instance_count`).
    pub fn fork_phase_instance_count(&self) -> Option<u32> {
        self.first_word(HS_FORK_INSTANCES)
    }

    /// The instance count of a hull program's join phase (`dcl_hs_join_phase_instance_count`).
    pub fn join_phase_instance_count(&self) -> Option<u32> {
        self.first_word(HS_JOIN_INSTANCES)
    }
}
