//! The `STAT` part of a Shader Model 4 or 5 container: the compiler's counts of what the program does, as 32-bit words.
//!
//! `fxc` writes 37 words for a Shader Model 5 program and 29 for Shader Model 4.0 and 4.1 ones (148 and 116 bytes).
//! Most words this reader names are fields of `D3D11_SHADER_DESC` that the compiler's own reflection reports for the
//! same container, checked by calling `D3DReflect` (`d3dcompiler_47`) on every container that has the part: the 432
//! Shader Model 5 programs of Sekiro (37 words), the 16 Shader Model 4.0 programs of a Unity player (29 words) and 21
//! programs compiled with `fxc` from small sources (6 with 29 words and 15 with 37). A name is a word that equalled
//! the field in every one of those containers and was not zero in all of them; word 20 is not a field of that
//! structure and is named from the decoder's count (below). The other words are kept as stored
//! ([`Statistics::words`]): 2, 9 to 13, 17 and 22 to 36 are zero in all 448 of Sekiro's and the Unity player's, and
//! words 19 and 21 are nonzero but no count of the decoder's instructions that was tried (`mov`; the conversions)
//! equals them.
//!
//! In a `DXIL` container the `STAT` part is a bitcode module, not counters; [`statistics`] refuses it.
use crate::{Result, error, parts};

/// The counters of a `STAT` part, as stored.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Statistics {
    /// Every word of the part.
    pub words: Vec<u32>,
}

macro_rules! counters {
    ($($(#[$doc:meta])* $name:ident = $at:literal;)+) => {
        impl Statistics {
            $(
                $(#[$doc])*
                pub fn $name(&self) -> Option<u32> {
                    self.words.get($at).copied()
                }
            )+
        }
    };
}

counters! {
    /// Word 0: the program's instructions, declarations not counted (equal to the decoder's instruction count in all
    /// 466 containers that have the part and decode).
    instructions = 0;
    /// Word 1: the temporary registers: the largest `dcl_temps` of the program (a hull program declares them once a
    /// phase), the only one in the other stages; equal to the decoder's in the same 466 containers and the fixtures.
    temp_registers = 1;
    /// Word 3: the declarations (`D3D11_SHADER_DESC::DclCount`). It is not a simple sum of the declaration opcodes.
    declarations = 3;
    /// Word 4: the floating-point instructions.
    float_instructions = 4;
    /// Word 5: the signed-integer instructions.
    int_instructions = 5;
    /// Word 6: the unsigned-integer instructions.
    uint_instructions = 6;
    /// Word 7: the static flow control instructions.
    static_flow_control = 7;
    /// Word 8: the dynamic flow control instructions.
    dynamic_flow_control = 8;
    /// Word 14: the texture instructions that sample normally (`sample`, `gather4`, ...).
    texture_normal = 14;
    /// Word 15: the texture load instructions.
    texture_load = 15;
    /// Word 16: the comparison texture instructions.
    texture_comparison = 16;
    /// Word 18: the instructions that sample with explicit gradients (`sample_d`; equal to the decoder's count in the
    /// same 466 containers).
    texture_gradient = 18;
    /// Word 20: the `movc` instructions (equal to the decoder's count of them in all 466 containers that have the part
    /// and decode, the 21 small programs among them).
    movc_instructions = 20;
}

/// The `STAT` part of a Shader Model 4 or 5 container: `None` for a container without one (Riders Republic's have none; Sekiro's
/// have it in all 432, 16 of the Unity player's 4,854 do). Refuses a container [`parts`] refuses, a `DXIL` container
/// (its `STAT` part is a bitcode module) and a part whose size is not a multiple of four bytes.
pub fn statistics(bytes: &[u8]) -> Result<Option<Statistics>> {
    let directory = parts(bytes)?;
    let Some(stat) = directory.iter().find(|c| &c.kind == b"STAT") else {
        return Ok(None);
    };
    if directory.iter().any(|c| &c.kind == b"DXIL") {
        return Err(error(
            0,
            "the STAT part of a DXIL container is a bitcode module, not counters",
        ));
    }
    let (words, rest) = stat.data.as_chunks::<4>();
    if !rest.is_empty() {
        return Err(error(
            stat.data.len() / 4,
            format!("the STAT part has {} bytes, not a multiple of 4", stat.data.len()),
        ));
    }
    Ok(Some(Statistics {
        words: words.iter().map(|w| u32::from_le_bytes(*w)).collect(),
    }))
}
