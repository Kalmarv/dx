//! Which sampler each texture read of a program uses: every sample, gather, level-of-detail query and load that names a
//! texture register, with the texture register, the sampler register and whether the instruction compares.
use crate::decode::{Declared, Decoded, Instruction, Operand, Register};

/// One instruction of a program that reads a texture (a shader resource view, `t<n>`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct TextureRead {
    /// The instruction's first word in the token stream.
    pub word: usize,
    /// The instruction's opcode (see [`crate::opcode_name`]).
    pub opcode: u16,
    /// The number of the `t` register, or the constant part of its index where [`TextureRead::texture_indexed`].
    pub texture: u32,
    /// The texture register is indexed by a register (`t[r1.x + 3]`).
    pub texture_indexed: bool,
    /// The number of the `s` register the instruction samples with; none for a load, which uses no sampler.
    pub sampler: Option<u32>,
    /// The sampler register is indexed by a register.
    pub sampler_indexed: bool,
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

/// The register number of an operand and whether a register adds to it; none for an operand without an index.
fn register(operand: &Operand) -> Option<(u32, bool)> {
    let index = operand.indices.first()?;
    Some((index.base, index.relative.is_some()))
}

fn first(instruction: &Instruction, wanted: Register) -> Option<&Operand> {
    instruction.operands.iter().find(|o| o.register == wanted)
}

/// Every texture read of `program` (an instruction with a `t<n>` operand that samples, gathers, queries the level of
/// detail of or loads it), in program order. An instruction that reads a raw or structured buffer or an
/// unordered-access view through a `u` or `g` register names no texture and is not listed.
pub fn texture_reads(program: &Decoded) -> Vec<TextureRead> {
    let modes: Vec<(u32, u32)> = program
        .declarations
        .iter()
        .filter_map(|d| match d.kind {
            Declared::Sampler { slot, mode } => Some((slot, mode)),
            _ => None,
        })
        .collect();
    let mut reads = Vec::new();
    for instruction in &program.instructions {
        let Some((sampled, comparison)) = kind(instruction.name()) else {
            continue;
        };
        let Some((texture, texture_indexed)) = first(instruction, Register::Texture).and_then(register)
        else {
            continue;
        };
        let sampler = if sampled {
            first(instruction, Register::Sampler).and_then(register)
        } else {
            None
        };
        reads.push(TextureRead {
            word: instruction.word,
            opcode: instruction.opcode,
            texture,
            texture_indexed,
            sampler: sampler.map(|(slot, _)| slot),
            sampler_indexed: sampler.is_some_and(|(_, indexed)| indexed),
            comparison,
            sampler_mode: sampler.and_then(|(slot, _)| {
                modes
                    .iter()
                    .find(|(declared, _)| *declared == slot)
                    .map(|(_, mode)| *mode)
            }),
        });
    }
    reads
}
