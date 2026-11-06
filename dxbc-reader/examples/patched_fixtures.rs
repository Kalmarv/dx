//! `cargo run -p dxbc-reader --example patched_fixtures`: write the containers in `tests/fixtures` that are fxc builds
//! of `tests/disasm` edited into programs fxc does not write, each with its digest repaired, for Microsoft's
//! disassembler to list (`tests/disasm/generate.py`):
//!
//! - `messages_unknown.vs50.dxbc`, from `messages.vs50.dxbc`: the first message's id made 0x00200104, the second's
//!   format 0 and the third's id 0, which Microsoft writes as `<unknown>` messages; with the digest repaired, the
//!   listing has no debug-layer note.
//! - `doubles_one.ps50.dxbc`, from `ps_doubles.ps50.dxbc`: the first 64-bit immediate made one component of one word,
//!   which Microsoft reads as a single word.
use std::path::Path;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

const CUSTOMDATA: u32 = 0x35;
/// The `customdata` class of a shader message.
const MESSAGE: u32 = 4;
/// An operand token of a four-component 64-bit immediate, and of a one-component one.
const IMMEDIATE64: u32 = 0x5002;
const IMMEDIATE64_ONE: u32 = 0x5001;

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
    )
}
