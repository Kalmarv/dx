//! Which sampler each texture read of a program uses: every sample, gather, level-of-detail query and load that names a
//! texture register, with the texture register, the sampler register and whether the instruction compares.
use crate::decode::{Declared, Decoded, Instruction, Operand, Register};

/// What a texture or sampler operand names: its register, whether a register adds to it, and in Shader Model 5.1 the
/// id of the declaration whose range holds it (`T1[r1.x + 4]`: id 1, register 4 plus `r1.x`).
struct Named {
    register: u32,
    indexed: bool,
    id: Option<u32>,
}

/// One instruction of a program that reads a texture (a shader resource view, `t<n>`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct TextureRead {
    /// The instruction's first word in the token stream.
    pub word: usize,
    /// The instruction's opcode (see [`crate::opcode_name`]).
    pub opcode: u16,
    /// The number of the `t` register, or the constant part of its index where [`TextureRead::texture_indexed`]. In
    /// Shader Model 5.1 the register of the declared range the instruction reads, as fxc's disassembly gives it.
    pub texture: u32,
    /// The texture register is indexed by a register (`t[r1.x + 3]`).
    pub texture_indexed: bool,
    /// The texture's register space: 0 before Shader Model 5.1; in 5.1 its declaration's, `None` where the program
    /// declares no texture of the id the instruction names.
    pub texture_space: Option<u32>,
    /// The number of the `s` register the instruction samples with; none for a load, which uses no sampler.
    pub sampler: Option<u32>,
    /// The sampler register is indexed by a register.
    pub sampler_indexed: bool,
    /// The sampler's register space, as [`TextureRead::texture_space`] gives the texture's; none without a sampler.
    pub sampler_space: Option<u32>,
    /// The instruction compares the sampled value with a reference (`sample_c`, `sample_c_lz`, `gather4_c`,
    /// `gather4_po_c` and the feedback forms of them).
    pub comparison: bool,
    /// How the program declares the sampler (`dcl_sampler`): 0 default, 1 comparison, 2 mono; none where the program
    /// declares no sampler of that number (or the instruction has no sampler).
    pub sampler_mode: Option<u32>,
}

/// How an opcode reads its texture: whether it takes a sampler and whether it compares.
fn kind(name: &str) -> Option<(bool, bool)> {
    Some(match name {
        "sample"
        | "sample_l"
        | "sample_d"
        | "sample_b"
        | "lod"
        | "gather4"
        | "gather4_po"
        | "gather4_feedback"
        | "gather4_po_feedback"
        | "sample_l_feedback"
        | "sample_clamp_feedback"
        | "sample_b_clamp_feedback"
        | "sample_d_clamp_feedback" => (true, false),
        "sample_c"
        | "sample_c_lz"
        | "gather4_c"
        | "gather4_po_c"
        | "gather4_c_feedback"
        | "gather4_po_c_feedback"
        | "sample_c_lz_feedback"
        | "sample_c_clamp_feedback" => (true, true),
        "ld"
        | "ld_ms"
        | "ld_raw"
        | "ld_structured"
        | "ld_feedback"
        | "ld_ms_feedback"
        | "ld_raw_feedback"
        | "ld_structured_feedback" => (false, false),
        _ => return None,
    })
}

/// The register an operand names, whether a register adds to it and (Shader Model 5.1) its declaration's id; none for
/// an operand without the indices its model gives it.
fn named(operand: &Operand, sm51: bool) -> Option<Named> {
    let (id, index) = if sm51 {
        let [id, index] = operand.indices.as_slice() else {
            return None;
        };
        (Some(id.base), index)
    } else {
        (None, operand.indices.first()?)
    };
    Some(Named {
        register: index.base,
        indexed: index.relative.is_some(),
        id,
    })
}

fn first(instruction: &Instruction, wanted: Register) -> Option<&Operand> {
    instruction.operands.iter().find(|o| o.register == wanted)
}

/// Every texture read of `program` (an instruction with a `t<n>` operand that samples, gathers, queries the level of
/// detail of or loads it), in program order. An instruction that reads a raw or structured buffer or an
/// unordered-access view through a `u` or `g` register names no texture and is not listed.
pub fn texture_reads(program: &Decoded) -> Vec<TextureRead> {
    let sm51 = (program.major, program.minor) >= (5, 1);
    // the declaration a name refers to: by its id in 5.1, by its register before
    let declared = |name: &Named, sampler: bool| {
        program.declarations.iter().find(|d| {
            let slot = match d.kind {
                Declared::Sampler { slot, .. } if sampler => slot,
                Declared::Resource { slot, .. }
                | Declared::ResourceRaw { slot, .. }
                | Declared::ResourceStructured { slot, .. }
                    if !sampler =>
                {
                    slot
                }
                _ => return false,
            };
            slot == name.id.unwrap_or(name.register)
        })
    };
    let space = |name: &Named, sampler: bool| {
        if sm51 {
            declared(name, sampler)
                .and_then(|d| d.kind.registers())
                .map(|r| r.space)
        } else {
            Some(0)
        }
    };
    let mut reads = Vec::new();
    for instruction in &program.instructions {
        let Some((sampled, comparison)) = kind(instruction.name()) else {
            continue;
        };
        let Some(texture) = first(instruction, Register::Texture).and_then(|o| named(o, sm51)) else {
            continue;
        };
        let sampler = if sampled {
            first(instruction, Register::Sampler).and_then(|o| named(o, sm51))
        } else {
            None
        };
        reads.push(TextureRead {
            word: instruction.word,
            opcode: instruction.opcode,
            texture: texture.register,
            texture_indexed: texture.indexed,
            texture_space: space(&texture, false),
            sampler: sampler.as_ref().map(|s| s.register),
            sampler_indexed: sampler.as_ref().is_some_and(|s| s.indexed),
            sampler_space: sampler.as_ref().and_then(|s| space(s, true)),
            comparison,
            sampler_mode: sampler.as_ref().and_then(|s| {
                declared(s, true).and_then(|d| match d.kind {
                    Declared::Sampler { mode, .. } => Some(mode),
                    _ => None,
                })
            }),
        });
    }
    reads
}
