//! `cargo run -p dxbc-reader --example patched_fixtures`: write the containers in `tests/fixtures` that are fxc builds
//! of `tests/disasm` edited into programs fxc does not write, each with its digest repaired, for Microsoft's
//! disassembler to list (`tests/disasm/generate.py`):
//!
//! - `messages_unknown.vs50.dxbc`, from `messages.vs50.dxbc`: the first message's id made 0x00200104, the second's
//!   format 0 and the third's id 0, which Microsoft writes as `<unknown>` messages; with the digest repaired, the
//!   listing has no debug-layer note.
//! - `doubles_one.ps50.dxbc`, from `ps_doubles.ps50.dxbc`: the first 64-bit immediate made one component of one word,
//!   which Microsoft reads as a single word.
//! - `globalflags_none.cs.dxbc`, from `compute_basic.dxbc`: the `dcl_globalFlags` declaration's flags made none, which
//!   Microsoft writes as `dcl_globalFlagsnone`.
//! - `load_immediates.cs.dxbc`, from `compute_basic.dxbc`: the one-component immediates of its `ld_structured` and
//!   `ld_raw` made four components (1, 2, 3, 4), which Microsoft writes with a space after each comma, as a load's
//!   address, where it writes a move's and a store's values without one.
//! - `xna_parts.ps93.dxbc` and `xna_parts_swapped.ps93.dxbc`, from `level9.mapped.ps93.dxbc`: copies of its `Aon9`
//!   part added as `XNAS` and `XNAP` parts (in that order before the `Aon9` part, as a Wine test container has them,
//!   and in the other), the parts of an XNA build, which Microsoft lists after the level 9 program.
use std::path::Path;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

const CUSTOMDATA: u32 = 0x35;
/// The `customdata` class of a shader message.
const MESSAGE: u32 = 4;
/// An operand token of a four-component 64-bit immediate, and of a one-component one.
const IMMEDIATE64: u32 = 0x5002;
const IMMEDIATE64_ONE: u32 = 0x5001;
/// An operand token of a one-component 32-bit immediate, and of a four-component one.
const IMMEDIATE32_ONE: u32 = 0x4001;
const IMMEDIATE32: u32 = 0x4002;
const DCL_GLOBAL_FLAGS: u32 = 0x6a;
const LD_RAW: u32 = 0xa5;
const LD_STRUCTURED: u32 = 0xa7;

fn words(bytes: &[u8]) -> Vec<u32> {
    bytes
        .as_chunks::<4>()
        .0
        .iter()
        .copied()
        .map(u32::from_le_bytes)
        .collect()
}

/// The program part of a container: its kind and words.
fn program(container: &[u8]) -> Result<([u8; 4], Vec<u32>)> {
    let part = dxcontainer::chunks(container)?
        .into_iter()
        .find(|c| matches!(&c.kind, b"SHEX" | b"SHDR"))
        .ok_or("no program part")?;
    Ok((part.kind, words(part.data)))
}

/// The start and length in words of each instruction (declarations included) of a program's words.
fn instructions(program: &[u32]) -> Result<Vec<(usize, usize)>> {
    let mut at = 2;
    let mut out = Vec::new();
    while at < program.len() {
        let token = program[at];
        let length = if token & 0x7ff == CUSTOMDATA {
            *program.get(at + 1).ok_or("a customdata block with no length")? as usize
        } else {
            (token >> 24 & 0x7f) as usize
        };
        if length == 0 {
            return Err(format!("an instruction of length 0 at word {at}").into());
        }
        out.push((at, length));
        at += length;
    }
    Ok(out)
}

fn write(container: &[u8], kind: [u8; 4], program: &[u32], to: &Path) -> Result<()> {
    let bytes: Vec<u8> = program.iter().flat_map(|w| w.to_le_bytes()).collect();
    std::fs::write(to, dxcontainer::replace_part(container, kind, &bytes)?)?;
    println!("wrote {}", to.display());
    Ok(())
}

fn unknown_messages(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let messages: Vec<usize> = instructions(&program)?
        .into_iter()
        .filter(|&(at, _)| program[at] & 0x7ff == CUSTOMDATA && program[at] >> 11 == MESSAGE)
        .map(|(at, _)| at)
        .collect();
    let [first, second, third, ..] = messages[..] else {
        return Err("fewer than three messages".into());
    };
    // the body: id, format, characters, operands, operand words
    program[first + 2] = 0x0020_0104;
    program[second + 3] = 0;
    program[third + 2] = 0;
    write(&container, kind, &program, to)
}

fn one_word_double(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let (start, length, operand) = instructions(&program)?
        .into_iter()
        .find_map(|(at, length)| {
            (1..length)
                .find(|&i| program[at + i] == IMMEDIATE64)
                .map(|i| (at, length, at + i))
        })
        .ok_or("no four-component 64-bit immediate")?;
    program[operand] = IMMEDIATE64_ONE;
    program.drain(operand + 2..operand + 5);
    program[start] = program[start] & !(0x7f << 24) | ((length as u32 - 3) << 24);
    program[1] -= 3;
    write(&container, kind, &program, to)
}

fn no_global_flags(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let (at, _) = instructions(&program)?
        .into_iter()
        .find(|&(at, _)| program[at] & 0x7ff == DCL_GLOBAL_FLAGS)
        .ok_or("no dcl_globalFlags")?;
    // the flags are the control bits, 11 to 23
    program[at] &= !(0x1fff << 11);
    write(&container, kind, &program, to)
}

fn four_component_load_immediates(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let mut patched = 0;
    // from the end, so the earlier instructions keep their starts
    for (start, length) in instructions(&program)?.into_iter().rev() {
        if !matches!(program[start] & 0x7ff, LD_RAW | LD_STRUCTURED) {
            continue;
        }
        let Some(operand) = (1..length)
            .map(|i| start + i)
            .find(|&i| program[i] == IMMEDIATE32_ONE)
        else {
            continue;
        };
        program[operand] = IMMEDIATE32;
        program.splice(operand + 1..operand + 2, [1, 2, 3, 4]);
        program[start] = program[start] & !(0x7f << 24) | ((length as u32 + 3) << 24);
        program[1] += 3;
        patched += 1;
    }
    if patched != 2 {
        return Err(format!("{patched} loads with a one-component immediate, where the source has 2").into());
    }
    write(&container, kind, &program, to)
}

fn xna_parts(from: &Path, to: &Path, order: [[u8; 4]; 2]) -> Result<()> {
    let container = std::fs::read(from)?;
    let parts = dxcontainer::chunks(&container)?;
    let level9 = parts
        .iter()
        .position(|c| &c.kind == b"Aon9")
        .ok_or("no Aon9 part")?;
    let mut out = parts.clone();
    for (n, kind) in order.into_iter().enumerate() {
        out.insert(
            level9 + n,
            dxcontainer::Chunk {
                kind,
                data: parts[level9].data,
            },
        );
    }
    std::fs::write(to, dxcontainer::serialize(&out)?)?;
    println!("wrote {}", to.display());
    Ok(())
}

fn main() -> Result<()> {
    let tests = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests");
    let (disasm, fixtures) = (tests.join("disasm"), tests.join("fixtures"));
    unknown_messages(
        &disasm.join("messages.vs50.dxbc"),
        &fixtures.join("messages_unknown.vs50.dxbc"),
    )?;
    one_word_double(
        &disasm.join("ps_doubles.ps50.dxbc"),
        &fixtures.join("doubles_one.ps50.dxbc"),
    )?;
    no_global_flags(
        &fixtures.join("compute_basic.dxbc"),
        &fixtures.join("globalflags_none.cs.dxbc"),
    )?;
    four_component_load_immediates(
        &fixtures.join("compute_basic.dxbc"),
        &fixtures.join("load_immediates.cs.dxbc"),
    )?;
    let level9 = disasm.join("level9.mapped.ps93.dxbc");
    xna_parts(
        &level9,
        &fixtures.join("xna_parts.ps93.dxbc"),
        [*b"XNAS", *b"XNAP"],
    )?;
    xna_parts(
        &level9,
        &fixtures.join("xna_parts_swapped.ps93.dxbc"),
        [*b"XNAP", *b"XNAS"],
    )
}
