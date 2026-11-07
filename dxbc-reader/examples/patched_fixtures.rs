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
//! - `globalflags_all.cs.dxbc`, from `compute_basic.dxbc`: every `dcl_globalFlags` bit set, the nine with names and
//!   the four after them, which Microsoft writes in its own order (bit 3 before bit 2) and without the four.
//! - `indices_negated.ps50.dxbc` and `indices_negated.ps51.dxbc`, from `indices.ps50.dxbc` and `indices.ps51.dxbc`:
//!   every number of an operand (register numbers, indices, the constants added to a relative index), the counts of
//!   `dcl_temps` and `dcl_indexrange`, `dcl_indexableTemp`'s register and size, and in Shader Model 5.1 each binding's
//!   space and a constant buffer's row count, made negative as 32-bit integers (`n` becomes `!n`). Microsoft writes them
//!   signed, but for the id, register range and space of a Shader Model 5.1 resource, sampler or view declaration,
//!   which it writes unsigned.
//! - `indices_names.ps50.dxbc` and `indices_names.ps51.dxbc`, from the same: the `_siv` declaration's name word given
//!   bits above its 16 (Microsoft reads the low 16), the `_sgv` one's a name Microsoft has none for (written as
//!   nothing), the texture's return types 0, 8, 9 and 15, the indexable temp's component count 0 (5.0) or 7 (5.1),
//!   which Microsoft writes as 1 and 4, and the system values of the two input signature elements that have one made 17
//!   and 71, which it writes as `NONE`.
//! - `interface_id.ps50.dxbc`, from `classes_calls.ps50.dxbc`: the first `dcl_interface`'s id given bits above its 16,
//!   which Microsoft does not write.
//! - `empty_masks.ps50.dxbc`, from `indices.ps50.dxbc`: the mask of every declaration's and instruction's first operand
//!   that has one cleared, which Microsoft writes as the dot alone (`dcl_output o0.`, `mov r0., ...`).
//! - `controls_join.hs.dxbc`, `controls_fork.hs.dxbc`, `controls.gs50.dxbc`, `controls.ps50.dxbc` and
//!   `controls.cs50.dxbc`, from `tessellation.hs.od.dxbc`, `tessellation.hs.dxbc`, `gs_streams.gs50.dxbc`,
//!   `ps_sampling.ps50.dxbc` and `cs_memory.cs50.dxbc`: control bits (11 to 23 of the opcode token) set where the
//!   opcode gives them no meaning, and declarations' values Microsoft has no name for (`CONTROLS` lists them).
//! - `selections.ps50.dxbc` and `selections.cs50.dxbc`, from `ps_sampling.ps50.dxbc` and `cs_memory.cs50.dxbc`: the
//!   operand of a resource, sampler, view and shared memory declaration given a component selection (a swizzle, a
//!   scalar, a mask), which Microsoft writes after the register.
//! - `extended.ps50.dxbc`, from `ps_sampling.ps50.dxbc`: extended opcode tokens retyped, so an instruction has two
//!   of a kind; Microsoft writes the last one's group once for each.
//! - `labels.ps50.zi.dxbc`, from `classes_resources.ps50.zi.dxbc`: every `label` given a saturate or a precise bit,
//!   which do not keep Microsoft from naming the file on a function body's `#line`.
//! - `relative_index.ps50.dxbc`, from `indices.ps50.dxbc`: the registers of its relative indices given other component
//!   counts and selections (`RELATIVE_SELECTIONS`); Microsoft writes such a register with one component.
//! - `conditionals.ps50.dxbc`, `conditionals_continuec.ps50.dxbc` and `conditionals_retc.gs50.dxbc`, from
//!   `ps_sampling.ps50.dxbc`, `classes_arrays2d.ps50.dxbc` and `gs_streams.gs50.dxbc`: conditionals (`breakc`, `if`,
//!   `discard`, and a `breakc` made a `continuec` and a `retc`) given an immediate, most of them with bits that look
//!   like a float, which Microsoft writes as an integer.
//! - `reserved.ps50.dxbc`, from `ps_sampling.ps50.dxbc`: four arithmetic instructions given the opcodes the format
//!   reserves (107, 209, 218, 235), the second saturated, the third precise and the fourth with an extended token of
//!   sample offsets over its first operand token. Microsoft writes no operand of them, the first named `jmp` and the
//!   others nothing.
//! - `saturated_calls.ps50.zi.dxbc` and `saturated_else.vs93.zi.dxbc`, from `zi_names.ps50.zi.dxbc` and
//!   `level9.twice.vs93.zi.dxbc`: every `call` and every `else` saturated; Microsoft still labels the variable
//!   locations after them (`Post-call locations`, `Prior locations`).
//! - `icb_numbers.ps50.dxbc`, from `ps_sampling.ps50.dxbc`: its first three temps with an immediate index made
//!   immediate constant buffer registers 0, 5 and -2, which Microsoft writes as it writes a temp's number (`icb5`).
//! - `stage_pixel.hs.dxbc` and `stage_hull.ds.dxbc`, from `tess_stages.pass.hs.dxbc` and `tess_stages.tri.ds.dxbc`:
//!   the version token's program type made pixel and hull. Microsoft writes the patch constant signature as an
//!   output's in any program but a domain program's, and the tessellation tables whatever the stage.
//! - `tessellation_values.hs.dxbc` and `tessellation_values.ps50.dxbc`, from `tess_stages.tri.hs.dxbc` and
//!   `ps_sampling.ps50.dxbc`: the `STAT` part's control points, output primitive, partitioning and domain given values,
//!   some with no name (`<internal error>`). Microsoft writes the domain table where the domain or the control points
//!   are not 0, and the output primitive table where the primitive or the partitioning is not 0.
//! - `message_strings.vs50.dxbc`, from `messages.vs50.dxbc`: the first message's character count made the bytes its
//!   string has, leaving no room for the zero (Microsoft's `undecipherable custom data`), the second's 0 and the
//!   third's string given a zero in its third byte; Microsoft reads a string to its zero, whatever its count.
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
const DCL_RESOURCE: u32 = 88;
const DCL_CONSTANT_BUFFER: u32 = 89;
const DCL_SAMPLER: u32 = 90;
const DCL_INDEX_RANGE: u32 = 91;
const DCL_INPUT_PS_SGV: u32 = 99;
const DCL_INPUT_PS_SIV: u32 = 100;
const DCL_TEMPS: u32 = 104;
const DCL_INDEXABLE_TEMP: u32 = 105;
const INTERFACE_CALL: u32 = 120;
const DCL_INTERFACE: u32 = 146;
/// The declarations of a resource, sampler or view, which in Shader Model 5.1 end with the binding's space.
const BINDINGS: [u32; 8] = [
    DCL_RESOURCE,
    DCL_CONSTANT_BUFFER,
    DCL_SAMPLER,
    156,
    157,
    158,
    161,
    162,
];
/// Control bits of an opcode token (from its bit 11): saturate, and the components an instruction is precise for.
const SATURATE: u32 = 1 << 2;
const PRECISE: u32 = 15 << 8;
/// The fixtures of control bits: the program each is made from, and for the first instruction or declaration of each
/// opcode named, the control bits of the mask made the value. Microsoft writes saturate and precise on every
/// instruction (the hull phases among them, `hs_decls` not) in its own order, reads a tessellator domain from two
/// bits, and names the values it knows alone: `???`, `undefined`, `<unknown dimension>` or nothing for the others.
#[allow(clippy::type_complexity)]
const CONTROLS: [(&str, &str, &[(u32, u32, u32)]); 5] = [
    (
        "tessellation.hs.od",
        "controls_join.hs",
        &[
            // hs_decls, hs_control_point_phase, hs_join_phase
            (113, SATURATE | PRECISE, SATURATE | PRECISE),
            (114, SATURATE, SATURATE),
            (116, SATURATE | PRECISE, SATURATE | 5 << 8),
            // the domain 6, read as 2 (tri); partitioning 0; output primitive 7
            (149, 7, 6),
            (150, 7, 0),
            (151, 7, 7),
        ],
    ),
    (
        "tessellation.hs",
        "controls_fork.hs",
        &[
            (115, SATURATE | PRECISE, SATURATE | 8 << 8),
            (149, 7, 4),
            (150, 7, 6),
            (151, 7, 0),
        ],
    ),
    (
        "gs_streams.gs50",
        "controls.gs50",
        &[
            // output topology 2 (a line list), input primitive 0; breakc
            (92, 63, 2),
            (93, 63, 0),
            (3, SATURATE | PRECISE, SATURATE | 2 << 8),
        ],
    ),
    (
        "ps_sampling.ps50",
        "controls.ps50",
        &[
            // interpolation modes 0, 9 and 15; sampler mode 3; resource dimension 0
            (98, 15, 0),
            (99, 15, 9),
            (100, 15, 15),
            (90, 15, 3),
            (88, 31, 0),
            // sample, if, discard, resinfo, breakc
            (69, SATURATE | PRECISE, SATURATE | PRECISE),
            (31, SATURATE | PRECISE, SATURATE | 1 << 8),
            (13, SATURATE, SATURATE),
            (61, SATURATE | PRECISE, SATURATE | 8 << 8),
            (3, PRECISE, 4 << 8),
        ],
    ),
    (
        "cs_memory.cs50",
        "controls.cs50",
        &[
            // sync, whose bit 13 is a sync flag too; a typed UAV of dimension 13
            (190, SATURATE | PRECISE, SATURATE | 3 << 8),
            (156, 31, 13),
        ],
    ),
];
/// The extended resource-dimension token (type 2) that `controls.ps50.dxbc` gives dimension 20: its `sample`'s.
const SAMPLE: u32 = 69;
const EXTENDED_DIMENSION: u32 = 2;

/// The component count and selection (an operand token's bits 0 to 11) of four components by the swizzle `wyxx`, by
/// the scalar `z`, and by the masks `x` and `xyzw`.
const SWIZZLE_WYXX: u32 = 0x076;
const SCALAR_Z: u32 = 0x02a;
const MASK_X: u32 = 0x012;
const MASK_XYZW: u32 = 0x0f2;
const LABEL: u32 = 44;
/// The component counts and selections the relative indices of `relative_index.ps50.dxbc` are given: four components
/// by the scalar `w`, by the swizzle `wyxx` and by the mask `yz`, one component and none. Microsoft writes the
/// register with the scalar's component, and with `x` for the others.
const RELATIVE_SELECTIONS: [u32; 5] = [0x03a, SWIZZLE_WYXX, 0x062, 0x001, 0x000];
/// The conditionals of the `conditionals` fixtures.
const BREAKC: u32 = 3;
const CONTINUEC: u32 = 8;
const DISCARD: u32 = 13;
const IF: u32 = 31;
const RETC: u32 = 63;
/// The opcodes the format reserves, and the arithmetic opcodes `reserved.ps50.dxbc` writes them over (`add`, `mad`,
/// `mov`, `mul`).
const RESERVED: [u32; 4] = [107, 209, 218, 235];
const ARITHMETIC: [u32; 4] = [0, 50, 54, 56];
/// An extended opcode token of sample offsets (1, 2, 3).
const OFFSETS_123: u32 = 1 | 1 << 9 | 2 << 13 | 3 << 17;
const CALL: u32 = 4;
const ELSE: u32 = 18;

/// The numbers the temps of `icb_numbers.ps50.dxbc` are given as immediate constant buffer registers: Microsoft
/// writes each after `icb` as it writes a temp's (`icb0`, `icb5`, `icb-2`), where dx wrote it in brackets.
const ICB_NUMBERS: [u32; 3] = [0, 5, (-2i32).cast_unsigned()];
const TYPE_TEMP: u32 = 0;
/// Program types of a version token, and the words of the `STAT` part the tessellation tables are written from.
const PIXEL: u32 = 0;
const HULL: u32 = 3;
const STAT_CONTROL_POINTS: usize = 30;
const STAT_PRIMITIVE: usize = 31;
const STAT_PARTITIONING: usize = 32;
const STAT_DOMAIN: usize = 33;
const TYPE_IMMEDIATE_BUFFER: u32 = 9;

/// The register types of operands that hold values rather than name a register.
const TYPE_IMMEDIATE32: u32 = 4;
const TYPE_IMMEDIATE64: u32 = 5;

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

/// Whether an opcode is a declaration's.
fn declaration(opcode: u32) -> bool {
    matches!(opcode, 88..=106 | 143..=162 | 206)
}

/// The words of operands an edit picks from.
#[derive(Default)]
struct Found {
    /// Immediate indices: a register's number among them, and the constant added to a relative index.
    indices: Vec<usize>,
    /// The operand tokens of the registers relative indices add.
    relatives: Vec<usize>,
}

/// The word after the operand at word `at`, with its words pushed to `found`, its relative indices' included.
fn operand(program: &[u32], mut at: usize, found: &mut Found) -> Result<usize> {
    let token = *program.get(at).ok_or("an operand past the program's end")?;
    at += 1;
    // the extended operand tokens
    let mut extended = token;
    while extended & 0x8000_0000 != 0 {
        extended = *program
            .get(at)
            .ok_or("an extended operand token past the program's end")?;
        at += 1;
    }
    let components = match token & 3 {
        1 => 1,
        2 => 4,
        _ => 0,
    };
    match token >> 12 & 0xff {
        TYPE_IMMEDIATE32 => return Ok(at + components),
        TYPE_IMMEDIATE64 => return Ok(at + 2 * components),
        _ => {}
    }
    for dimension in 0..(token >> 20 & 3) {
        // immediate32, immediate64, relative, immediate32 plus relative, immediate64 plus relative
        let representation = token >> (22 + 3 * dimension) & 7;
        match representation {
            0 | 3 => {
                found.indices.push(at);
                at += 1;
            }
            1 | 4 => at += 2,
            2 => {}
            other => return Err(format!("index representation {other} at word {at}").into()),
        }
        if matches!(representation, 2..=4) {
            found.relatives.push(at);
            at = operand(program, at, found)?;
        }
    }
    Ok(at)
}

/// The operands of the instruction (not a declaration) at `start`, their words pushed to `found`.
fn instruction_operands(program: &[u32], start: usize, length: usize, found: &mut Found) -> Result<()> {
    let end = start + length;
    let mut at = after_opcode(program, start);
    // an interface call's first word is its call site
    if program[start] & 0x7ff == INTERFACE_CALL {
        at += 1;
    }
    while at < end {
        at = operand(program, at, found)?;
    }
    if at != end {
        return Err(format!("the operands of the instruction at word {start} run past its end").into());
    }
    Ok(())
}

/// The first word of an instruction after its opcode token and extended opcode tokens.
fn after_opcode(program: &[u32], start: usize) -> usize {
    let mut at = start + 1;
    let mut token = program[start];
    while token & 0x8000_0000 != 0 && at < program.len() {
        token = program[at];
        at += 1;
    }
    at
}

/// The word of the first declaration with this opcode that `word` picks from its start and length.
fn declared(program: &[u32], opcode: u32, word: impl Fn(usize, usize) -> usize) -> Result<usize> {
    instructions(program)?
        .into_iter()
        .find(|&(at, _)| program[at] & 0x7ff == opcode)
        .map(|(at, length)| word(at, length))
        .ok_or_else(|| format!("no declaration of opcode {opcode}").into())
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

fn message_strings(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let messages: Vec<(usize, usize)> = instructions(&program)?
        .into_iter()
        .filter(|&(at, _)| program[at] & 0x7ff == CUSTOMDATA && program[at] >> 11 == MESSAGE)
        .collect();
    let [first, second, third, ..] = messages[..] else {
        return Err("fewer than three messages".into());
    };
    // the body after the opcode and length: id, format, characters, operands, operand words, the operands, the string
    let string = |program: &[u32], at: usize| at + 7 + program[at + 6] as usize;
    let (first_string, third_string) = (string(&program, first.0), string(&program, third.0));
    program[first.0 + 4] = u32::try_from(4 * (first.0 + first.1 - first_string))?;
    program[second.0 + 4] = 0;
    program[third_string] &= 0xff00_ffff;
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
    let at = declared(&program, DCL_GLOBAL_FLAGS, |at, _| at)?;
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

fn all_global_flags(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let at = declared(&program, DCL_GLOBAL_FLAGS, |at, _| at)?;
    // the flags are the control bits, 11 to 23
    program[at] |= 0x1fff << 11;
    write(&container, kind, &program, to)
}

fn negated_numbers(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    // the version token's low byte: Shader Model 5.1 declares a binding's space
    let sm51 = program[0] & 0xff == 0x51;
    let mut found = Found::default();
    for (start, length) in instructions(&program)? {
        let opcode = program[start] & 0x7ff;
        let end = start + length;
        match opcode {
            CUSTOMDATA | DCL_GLOBAL_FLAGS => {}
            DCL_TEMPS => found.indices.push(start + 1),
            DCL_INDEXABLE_TEMP => found.indices.extend([start + 1, start + 2]),
            DCL_INDEX_RANGE => {
                let count = operand(&program, start + 1, &mut found)?;
                found.indices.push(count);
            }
            _ if declaration(opcode) => {
                let after = operand(&program, start + 1, &mut found)?;
                if sm51 && BINDINGS.contains(&opcode) {
                    found.indices.push(end - 1);
                    if opcode == DCL_CONSTANT_BUFFER {
                        found.indices.push(after);
                    }
                }
            }
            _ => instruction_operands(&program, start, length, &mut found)?,
        }
    }
    for at in found.indices {
        program[at] = !program[at];
    }
    write(&container, kind, &program, to)
}

/// The register of each relative index of the instructions given, in order, the component count and selection of
/// `RELATIVE_SELECTIONS`.
fn relative_selections(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let mut found = Found::default();
    for (start, length) in instructions(&program)? {
        let opcode = program[start] & 0x7ff;
        if opcode != CUSTOMDATA && !declaration(opcode) {
            instruction_operands(&program, start, length, &mut found)?;
        }
    }
    if found.relatives.len() < RELATIVE_SELECTIONS.len() {
        return Err(format!(
            "{} relative indices, where the edit takes {}",
            found.relatives.len(),
            RELATIVE_SELECTIONS.len()
        )
        .into());
    }
    for (at, selection) in found.relatives.into_iter().zip(RELATIVE_SELECTIONS) {
        program[at] = program[at] & !0xfff | selection;
    }
    write(&container, kind, &program, to)
}

/// The first temps of the program's instructions with one immediate index and no extended operand token made
/// immediate constant buffer registers of the numbers of `ICB_NUMBERS`.
fn immediate_buffer_numbers(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let mut temps = Vec::new();
    for (start, length) in instructions(&program)? {
        let opcode = program[start] & 0x7ff;
        if opcode == CUSTOMDATA || declaration(opcode) {
            continue;
        }
        let mut at = after_opcode(&program, start);
        while at < start + length {
            let token = program[at];
            // one dimension, an immediate32 index
            if token & 0x8000_0000 == 0 && token >> 12 & 0xff == TYPE_TEMP && token >> 20 & 0x1f == 1 {
                temps.push(at);
            }
            at = operand(&program, at, &mut Found::default())?;
        }
    }
    if temps.len() < ICB_NUMBERS.len() {
        return Err(format!(
            "{} temps, where the edit takes {}",
            temps.len(),
            ICB_NUMBERS.len()
        )
        .into());
    }
    for (at, number) in temps.into_iter().zip(ICB_NUMBERS) {
        program[at] = program[at] & !0xff000 | TYPE_IMMEDIATE_BUFFER << 12;
        program[at + 1] = number;
    }
    write(&container, kind, &program, to)
}

/// The program's version token given the program type `stage` where one is given (its version kept), and the
/// `STAT` part's words of `statistics` (a word and its value).
fn restaged(from: &Path, to: &Path, stage: Option<u32>, statistics: &[(usize, u32)]) -> Result<()> {
    let mut container = std::fs::read(from)?;
    if !statistics.is_empty() {
        let mut stat = words(
            dxcontainer::chunks(&container)?
                .into_iter()
                .find(|c| &c.kind == b"STAT")
                .ok_or("no STAT part")?
                .data,
        );
        for &(at, value) in statistics {
            *stat.get_mut(at).ok_or_else(|| format!("no STAT word {at}"))? = value;
        }
        let bytes: Vec<u8> = stat.iter().flat_map(|w| w.to_le_bytes()).collect();
        container = dxcontainer::replace_part(&container, *b"STAT", &bytes)?;
    }
    let (kind, mut program) = program(&container)?;
    if let Some(stage) = stage {
        program[0] = program[0] & 0xffff | stage << 16;
    }
    write(&container, kind, &program, to)
}

/// Every instruction of `opcode` saturated.
fn saturated(from: &Path, to: &Path, opcode: u32) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let found: Vec<usize> = instructions(&program)?
        .into_iter()
        .filter(|&(at, _)| program[at] & 0x7ff == opcode)
        .map(|(at, _)| at)
        .collect();
    if found.is_empty() {
        return Err(format!("no opcode {opcode}").into());
    }
    for at in found {
        program[at] |= SATURATE << 11;
    }
    write(&container, kind, &program, to)
}

/// The first four arithmetic instructions given the reserved opcodes (`RESERVED`): the first plain, the second
/// saturated, the third precise and the fourth with an extended token of sample offsets.
fn reserved_opcodes(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let found: Vec<usize> = instructions(&program)?
        .into_iter()
        .filter(|&(at, length)| {
            length >= 2 && program[at] & 0x8000_0000 == 0 && ARITHMETIC.contains(&(program[at] & 0x7ff))
        })
        .map(|(at, _)| at)
        .take(RESERVED.len())
        .collect();
    let [plain, saturated, precise, extended] = found[..] else {
        return Err(format!("{} arithmetic instructions, where the edit takes 4", found.len()).into());
    };
    let retyped = |token: u32, opcode: u32| token & 0x7f00_0000 | opcode;
    program[plain] = retyped(program[plain], RESERVED[0]);
    program[saturated] = retyped(program[saturated], RESERVED[1]) | SATURATE << 11;
    program[precise] = retyped(program[precise], RESERVED[2]) | 5 << 8 << 11;
    program[extended] = retyped(program[extended], RESERVED[3]) | 0x8000_0000;
    program[extended + 1] = OFFSETS_123;
    write(&container, kind, &program, to)
}

/// For each of `edits` (an opcode, the opcode written over it, a value), the next three-word instruction of that
/// opcode, a conditional whose one operand is a register with one index, made the opcode written with a one-component
/// immediate of the value.
fn conditional_values(from: &Path, to: &Path, edits: &[(u32, u32, u32)]) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let mut free: Vec<usize> = instructions(&program)?
        .into_iter()
        .filter(|&(at, length)| {
            length == 3 && program[at] & 0x8000_0000 == 0 && program[at + 1] >> 20 & 3 == 1
        })
        .map(|(at, _)| at)
        .collect();
    for &(opcode, written, value) in edits {
        let n = free
            .iter()
            .position(|&at| program[at] & 0x7ff == opcode)
            .ok_or_else(|| format!("no three-word instruction of opcode {opcode} left"))?;
        let at = free.remove(n);
        program[at] = program[at] & !0x7ff | written;
        program[at + 1] = IMMEDIATE32_ONE;
        program[at + 2] = value;
    }
    write(&container, kind, &program, to)
}

fn odd_names(from: &Path, to: &Path, components: u32) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let sm51 = program[0] & 0xff == 0x51;
    // a system value declaration's name is its last word
    let siv = declared(&program, DCL_INPUT_PS_SIV, |at, length| at + length - 1)?;
    program[siv] |= 0x0005_0000;
    let sgv = declared(&program, DCL_INPUT_PS_SGV, |at, length| at + length - 1)?;
    program[sgv] = 0xffff;
    // a resource's return types follow its operand, and in Shader Model 5.1 its space follows them
    let returns = declared(&program, DCL_RESOURCE, |at, length| {
        at + length - if sm51 { 2 } else { 1 }
    })?;
    program[returns] = 0xf980;
    let temp = declared(&program, DCL_INDEXABLE_TEMP, |at, _| at + 3)?;
    program[temp] = components;
    let bytes: Vec<u8> = program.iter().flat_map(|w| w.to_le_bytes()).collect();
    let container = dxcontainer::replace_part(&container, kind, &bytes)?;
    // the input signature: a count and a word, then 24-byte elements whose third word is the system value
    let mut signature = dxcontainer::chunks(&container)?
        .into_iter()
        .find(|c| &c.kind == b"ISGN")
        .ok_or("no ISGN part")?
        .data
        .to_vec();
    let count = u32::from_le_bytes(signature[..4].try_into()?) as usize;
    let mut changed = 0;
    for element in 0..count {
        let at = 8 + 24 * element + 8;
        if u32::from_le_bytes(signature[at..at + 4].try_into()?) != 0 {
            let value: u32 = if changed == 0 { 17 } else { 71 };
            signature[at..at + 4].copy_from_slice(&value.to_le_bytes());
            changed += 1;
        }
    }
    if changed != 2 {
        return Err(format!(
            "{changed} input signature elements with a system value, where the source has 2"
        )
        .into());
    }
    std::fs::write(to, dxcontainer::replace_part(&container, *b"ISGN", &signature)?)?;
    println!("wrote {}", to.display());
    Ok(())
}

fn empty_masks(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let mut cleared = 0;
    for (start, length) in instructions(&program)? {
        // the first operand of each declaration and instruction: four components (bits 0 and 1), selected by a mask
        // (bits 2 and 3), the mask bits 4 to 7
        let at = after_opcode(&program, start);
        if program[start] & 0x7ff == CUSTOMDATA || at >= start + length || program[at] & 0xf != 2 {
            continue;
        }
        program[at] &= !0xf0;
        cleared += 1;
    }
    if cleared == 0 {
        return Err("no operand selected by a mask".into());
    }
    write(&container, kind, &program, to)
}

fn wide_interface_id(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let id = declared(&program, DCL_INTERFACE, |at, _| at + 1)?;
    program[id] |= 0xfffe_0000;
    write(&container, kind, &program, to)
}

/// The control bits of the first instruction or declaration of each opcode of `edits` set, and with `dimension` the
/// resource dimension of the first extended resource-dimension token of an instruction of that opcode.
fn controls(from: &Path, to: &Path, edits: &[(u32, u32, u32)], dimension: Option<(u32, u32)>) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let found = instructions(&program)?;
    for &(opcode, mask, value) in edits {
        let &(at, _) = found
            .iter()
            .find(|&&(at, _)| program[at] & 0x7ff == opcode)
            .ok_or_else(|| format!("no opcode {opcode}"))?;
        program[at] = program[at] & !(mask << 11) | (value & mask) << 11;
    }
    if let Some((opcode, value)) = dimension {
        let token = found
            .iter()
            .filter(|&&(at, _)| program[at] & 0x7ff == opcode && program[at] & 0x8000_0000 != 0)
            .find_map(|&(at, _)| {
                (at + 1..after_opcode(&program, at)).find(|&e| program[e] & 0x3f == EXTENDED_DIMENSION)
            })
            .ok_or_else(|| format!("no extended resource dimension on opcode {opcode}"))?;
        program[token] = program[token] & !(31 << 6) | value << 6;
    }
    write(&container, kind, &program, to)
}

/// The first operand token of the first declaration of each opcode of `edits` given the component count and selection
/// paired with it.
fn selections(from: &Path, to: &Path, edits: &[(u32, u32)]) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    for &(opcode, selection) in edits {
        let at = declared(&program, opcode, |at, _| at + 1)?;
        program[at] = program[at] & !0xfff | selection;
    }
    write(&container, kind, &program, to)
}

/// The extended opcode tokens of the first instruction of each opcode of `edits` with extended tokens: the token at
/// the index given (from 0) made the type given.
fn retyped(from: &Path, to: &Path, edits: &[(u32, usize, u32)]) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let found = instructions(&program)?;
    for &(opcode, index, kind) in edits {
        let &(at, _) = found
            .iter()
            .find(|&&(at, _)| program[at] & 0x7ff == opcode && program[at] & 0x8000_0000 != 0)
            .ok_or_else(|| format!("no opcode {opcode} with extended tokens"))?;
        let token = at + 1 + index;
        if token >= after_opcode(&program, at) {
            return Err(format!("opcode {opcode} has no extended token {index}").into());
        }
        program[token] = program[token] & !0x3f | kind;
    }
    write(&container, kind, &program, to)
}

/// Every `label` given saturate (the first, third, ...) or precise for y (the others).
fn labels(from: &Path, to: &Path) -> Result<()> {
    let container = std::fs::read(from)?;
    let (kind, mut program) = program(&container)?;
    let found: Vec<usize> = instructions(&program)?
        .into_iter()
        .filter(|&(at, _)| program[at] & 0x7ff == LABEL)
        .map(|(at, _)| at)
        .collect();
    if found.is_empty() {
        return Err("no label".into());
    }
    for (n, at) in found.into_iter().enumerate() {
        program[at] |= if n % 2 == 0 { SATURATE } else { 2 << 8 } << 11;
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
    all_global_flags(
        &fixtures.join("compute_basic.dxbc"),
        &fixtures.join("globalflags_all.cs.dxbc"),
    )?;
    for (model, components) in [("ps50", 0), ("ps51", 7)] {
        let from = disasm.join(format!("indices.{model}.dxbc"));
        negated_numbers(&from, &fixtures.join(format!("indices_negated.{model}.dxbc")))?;
        odd_names(
            &from,
            &fixtures.join(format!("indices_names.{model}.dxbc")),
            components,
        )?;
    }
    empty_masks(
        &disasm.join("indices.ps50.dxbc"),
        &fixtures.join("empty_masks.ps50.dxbc"),
    )?;
    wide_interface_id(
        &disasm.join("classes_calls.ps50.dxbc"),
        &fixtures.join("interface_id.ps50.dxbc"),
    )?;
    for (source, fixture, edits) in CONTROLS {
        let from = [&disasm, &fixtures]
            .map(|d| d.join(format!("{source}.dxbc")))
            .into_iter()
            .find(|p| p.exists())
            .ok_or_else(|| format!("no {source}.dxbc"))?;
        let dimension = (fixture == "controls.ps50").then_some((SAMPLE, 20));
        controls(&from, &fixtures.join(format!("{fixture}.dxbc")), edits, dimension)?;
    }
    relative_selections(
        &disasm.join("indices.ps50.dxbc"),
        &fixtures.join("relative_index.ps50.dxbc"),
    )?;
    let sampling = disasm.join("ps_sampling.ps50.dxbc");
    // values a float would be written for, a negative zero and integers beyond ten thousand
    conditional_values(
        &sampling,
        &fixtures.join("conditionals.ps50.dxbc"),
        &[
            (BREAKC, BREAKC, 0x8000_0000),
            (IF, IF, 0x3f80_0000),
            (IF, IF, 0xffff_d8ef),
            (DISCARD, DISCARD, 0xbf80_0000),
        ],
    )?;
    conditional_values(
        &disasm.join("classes_arrays2d.ps50.dxbc"),
        &fixtures.join("conditionals_continuec.ps50.dxbc"),
        &[(BREAKC, CONTINUEC, 0x4000_0000)],
    )?;
    conditional_values(
        &disasm.join("gs_streams.gs50.dxbc"),
        &fixtures.join("conditionals_retc.gs50.dxbc"),
        &[(BREAKC, RETC, 0x4120_0000)],
    )?;
    reserved_opcodes(&sampling, &fixtures.join("reserved.ps50.dxbc"))?;
    immediate_buffer_numbers(&sampling, &fixtures.join("icb_numbers.ps50.dxbc"))?;
    restaged(
        &disasm.join("tess_stages.pass.hs.dxbc"),
        &fixtures.join("stage_pixel.hs.dxbc"),
        Some(PIXEL),
        &[],
    )?;
    restaged(
        &disasm.join("tess_stages.tri.ds.dxbc"),
        &fixtures.join("stage_hull.ds.dxbc"),
        Some(HULL),
        &[],
    )?;
    // a domain and a partitioning with no name, and no output primitive
    restaged(
        &disasm.join("tess_stages.tri.hs.dxbc"),
        &fixtures.join("tessellation_values.hs.dxbc"),
        None,
        &[
            (STAT_CONTROL_POINTS, 5),
            (STAT_PRIMITIVE, 0),
            (STAT_PARTITIONING, 6),
            (STAT_DOMAIN, 4),
        ],
    )?;
    // control points with no domain, and an output primitive with no name, in a pixel program
    restaged(
        &sampling,
        &fixtures.join("tessellation_values.ps50.dxbc"),
        None,
        &[(STAT_CONTROL_POINTS, 7), (STAT_PRIMITIVE, 9)],
    )?;
    saturated(
        &disasm.join("zi_names.ps50.zi.dxbc"),
        &fixtures.join("saturated_calls.ps50.zi.dxbc"),
        CALL,
    )?;
    saturated(
        &disasm.join("level9.twice.vs93.zi.dxbc"),
        &fixtures.join("saturated_else.vs93.zi.dxbc"),
        ELSE,
    )?;
    selections(
        &sampling,
        &fixtures.join("selections.ps50.dxbc"),
        &[(DCL_RESOURCE, SWIZZLE_WYXX), (DCL_SAMPLER, SCALAR_Z)],
    )?;
    selections(
        &disasm.join("cs_memory.cs50.dxbc"),
        &fixtures.join("selections.cs50.dxbc"),
        // a typed and a raw view, and structured shared memory
        &[(156, MASK_X), (157, MASK_XYZW), (160, SWIZZLE_WYXX)],
    )?;
    // `sample`'s first token made a return type token, `ld`'s second a dimension token and `ldms`'s second an offsets
    // token
    retyped(
        &sampling,
        &fixtures.join("extended.ps50.dxbc"),
        &[(SAMPLE, 0, 3), (45, 1, EXTENDED_DIMENSION), (46, 1, 1)],
    )?;
    labels(
        &disasm.join("classes_resources.ps50.zi.dxbc"),
        &fixtures.join("labels.ps50.zi.dxbc"),
    )?;
    message_strings(
        &disasm.join("messages.vs50.dxbc"),
        &fixtures.join("message_strings.vs50.dxbc"),
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
