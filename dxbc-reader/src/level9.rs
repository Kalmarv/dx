//! The `Aon9` part of a container compiled for a Direct3D 9 feature level (`ps_4_0_level_9_1` and the like): the
//! Shader Model 2 program the runtime runs on such hardware, and the tables that map the Shader Model 4 program's
//! constant buffers, samplers and resources onto Direct3D 9 registers.
//!
//! The layout below was read from containers fxc 10.0.26100.4654 built for every combination the tables have (no
//! constants, float/int/uint/bool constants from several buffers, loops over int constants, branches on bool
//! constants, several texture and sampler pairs, vertex and pixel programs at levels 9_1 and 9_3), each checked
//! against `D3DDisassemble`'s printing of the same tables. Words, from the start of the part:
//!
//! - 0: the part's size in bytes;
//! - 1: a Direct3D 9 version token, the program's version at the feature level's minimum (`vs_2_0` where the program
//!   is `vs_2_x`);
//! - 2 and 3: the program's size and its offset in the part, in bytes;
//! - 4 to 8: five tables, each a `u16` count then a `u16` byte offset: constant buffer ranges (12 bytes a row), int
//!   constants (8), bool constants (8), samplers (4), constants the runtime fills (4).
use crate::{Result, error, parts};

/// One range of a constant buffer copied into float constant registers.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ConstantMapping {
    /// The constant buffer (`cb#`).
    pub buffer: u16,
    /// The buffer's first register copied.
    pub start: u16,
    /// The registers copied.
    pub count: u16,
    /// The first float constant register (`c#`) they go to.
    pub target: u16,
    /// How each component converts, x to w: 0 float, 1 bool, 2 int, 3 uint.
    pub conversion: [u8; 4],
}

/// One component of a constant buffer copied into an int (`i#`) or bool (`b#`) constant register.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ScalarMapping {
    /// The constant buffer (`cb#`).
    pub buffer: u16,
    /// The buffer's register.
    pub source: u16,
    /// The register's component, 0 to 3 for x to w.
    pub component: u16,
    /// The `i#` or `b#` register it goes to.
    pub target: u16,
}

/// A Direct3D 9 sampler register and the Shader Model 4 sampler and resource it stands for.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct SamplerMapping {
    /// The Shader Model 4 resource (`t#`).
    pub resource: u8,
    /// The Shader Model 4 sampler (`s#`).
    pub sampler: u8,
    /// The Direct3D 9 sampler register (`s#`).
    pub target: u8,
}

/// A float constant register the runtime fills itself.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RuntimeConstant {
    /// What it holds: 0 is the vertex program's position offset, the only kind seen.
    pub kind: u16,
    /// The float constant register (`c#`).
    pub target: u16,
}

/// The `Aon9` part.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Level9 {
    /// The version token of word 1: the program's version at the feature level's minimum.
    pub version: u32,
    /// The Direct3D 9 program, from its version token to `END`, for `d3d9_reader`.
    pub program: Vec<u8>,
    /// The program's offset in the part, in bytes (word 3).
    pub program_offset: u32,
    /// Constant buffer ranges copied into float constant registers.
    pub constants: Vec<ConstantMapping>,
    /// Constant buffer components copied into int constant registers.
    pub integers: Vec<ScalarMapping>,
    /// Constant buffer components copied into bool constant registers.
    pub booleans: Vec<ScalarMapping>,
    /// Sampler registers and what they stand for.
    pub samplers: Vec<SamplerMapping>,
    /// Constant registers the runtime fills.
    pub runtime: Vec<RuntimeConstant>,
}

struct Part<'a> {
    data: &'a [u8],
}

impl Part<'_> {
    fn u16(&self, at: usize) -> Result<u16> {
        self.data
            .get(at..at.saturating_add(2))
            .and_then(|b| b.try_into().ok())
            .map(u16::from_le_bytes)
            .ok_or_else(|| error(at / 4, format!("the Aon9 part ends before byte {at}")))
    }
    fn u32(&self, at: usize) -> Result<u32> {
        self.data
            .get(at..at.saturating_add(4))
            .and_then(|b| b.try_into().ok())
            .map(u32::from_le_bytes)
            .ok_or_else(|| error(at / 4, format!("the Aon9 part ends before byte {at}")))
    }
    fn byte(&self, at: usize) -> Result<u8> {
        self.data
            .get(at)
            .copied()
            .ok_or_else(|| error(at / 4, format!("the Aon9 part ends before byte {at}")))
    }
    /// The byte offsets of the rows of the table whose count and offset are at byte `at`, each checked to lie in the
    /// part.
    fn rows(&self, at: usize, row: usize) -> Result<Vec<usize>> {
        let count = usize::from(self.u16(at)?);
        let offset = usize::from(self.u16(at.saturating_add(2))?);
        let end = count.checked_mul(row).and_then(|n| n.checked_add(offset));
        if end.is_none_or(|end| end > self.data.len()) {
            return Err(error(
                at / 4,
                format!(
                    "a table of {count} rows of {row} bytes at byte {offset} runs past the Aon9 part's {} bytes",
                    self.data.len()
                ),
            ));
        }
        Ok((0..count)
            .map(|n| offset.saturating_add(n.saturating_mul(row)))
            .collect())
    }
    fn scalars(&self, at: usize) -> Result<Vec<ScalarMapping>> {
        self.rows(at, 8)?
            .into_iter()
            .map(|r| {
                Ok(ScalarMapping {
                    buffer: self.u16(r)?,
                    source: self.u16(r.saturating_add(2))?,
                    component: self.u16(r.saturating_add(4))?,
                    target: self.u16(r.saturating_add(6))?,
                })
            })
            .collect()
    }
}

/// The `Aon9` part: `None` for a container without one. Refuses a container [`parts`] refuses, a part whose stated
/// size is not its own, and a program or table that runs past the part; errors name the part's word.
pub fn level9(bytes: &[u8]) -> Result<Option<Level9>> {
    let directory = parts(bytes)?;
    let Some(chunk) = directory.iter().find(|c| &c.kind == b"Aon9") else {
        return Ok(None);
    };
    let part = Part { data: chunk.data };
    let size = part.u32(0)?;
    if usize::try_from(size).ok() != Some(part.data.len()) {
        return Err(error(
            0,
            format!("the Aon9 part states {size} bytes but has {}", part.data.len()),
        ));
    }
    let length = usize::try_from(part.u32(8)?).unwrap_or(usize::MAX);
    let program_offset = part.u32(12)?;
    let offset = usize::try_from(program_offset).unwrap_or(usize::MAX);
    let program = offset
        .checked_add(length)
        .and_then(|end| part.data.get(offset..end))
        .ok_or_else(|| {
            error(
                2,
                format!(
                    "a program of {length} bytes at byte {offset} runs past the Aon9 part's {} bytes",
                    part.data.len()
                ),
            )
        })?;
    let constants = part
        .rows(16, 12)?
        .into_iter()
        .map(|r| {
            Ok(ConstantMapping {
                buffer: part.u16(r)?,
                start: part.u16(r.saturating_add(2))?,
                count: part.u16(r.saturating_add(4))?,
                target: part.u16(r.saturating_add(6))?,
                conversion: [
                    part.byte(r.saturating_add(8))?,
                    part.byte(r.saturating_add(9))?,
                    part.byte(r.saturating_add(10))?,
                    part.byte(r.saturating_add(11))?,
                ],
            })
        })
        .collect::<Result<_>>()?;
    let samplers = part
        .rows(28, 4)?
        .into_iter()
        .map(|r| {
            let fourth = part.byte(r.saturating_add(3))?;
            if fourth != 0 {
                return Err(error(
                    r / 4,
                    format!(
                        "byte {} of a sampler mapping is {fourth}, where every one seen is 0",
                        r.saturating_add(3)
                    ),
                ));
            }
            Ok(SamplerMapping {
                resource: part.byte(r)?,
                sampler: part.byte(r.saturating_add(1))?,
                target: part.byte(r.saturating_add(2))?,
            })
        })
        .collect::<Result<_>>()?;
    let runtime = part
        .rows(32, 4)?
        .into_iter()
        .map(|r| {
            Ok(RuntimeConstant {
                kind: part.u16(r)?,
                target: part.u16(r.saturating_add(2))?,
            })
        })
        .collect::<Result<_>>()?;
    Ok(Some(Level9 {
        version: part.u32(4)?,
        program: program.to_vec(),
        program_offset,
        constants,
        integers: part.scalars(20)?,
        booleans: part.scalars(24)?,
        samplers,
        runtime,
    }))
}
