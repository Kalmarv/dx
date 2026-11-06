# d3d9-reader

A bounded reader of Direct3D 9 shader bytecode: a vertex or pixel program of Shader Model 1.x, 2.0, 2.x or 3.0, from its
version token to `END`, as typed declarations, definitions, instructions and comments, with the `CTAB` constant table.

```rust
let bytes = std::fs::read("shader.bin")?; // a token stream, not a DXBC container
let program = d3d9_reader::read(&bytes)?;
println!("{} with {} instructions", program.version, program.instructions().count());
for i in program.instructions() {
    println!("word {}: {} with {} sources", i.word, i.opcode.name(), i.sources.len());
}
if let Some(table) = &program.constants {
    for c in &table.constants {
        println!("{} in register set {} at {}+{}", c.name, c.register_set, c.register, c.count);
    }
}
```

`disassemble` writes a program's listing as Microsoft's disassembler does with no flags, byte for byte: the constant
table's parameters and registers, the program, and the instruction slot count. `dx disasm` runs it over files.

## What it reads

- **Versions:** `vs_1_0`, `vs_1_1`, `vs_2_0`, `vs_2_x`, `vs_3_0` and the software profiles `vs_2_sw` and `vs_3_sw`;
  `ps_1_0` to `ps_1_4`, `ps_2_0`, `ps_2_x`, `ps_3_0` and `ps_2_sw`, `ps_3_sw`. Each program is read under its own
  version's rules: which opcodes and register types exist, and how many operands an instruction takes where that
  changed (`sincos`, `sgn`, `tex` and `texcoord`).
- **Instructions** (`Instruction`): the opcode (every `D3DSIO` opcode, by `Opcode`), the control bits (a `texld`'s
  project and bias forms, the comparison of `if_comp`, `break_comp` and `setp_comp`), the predicate of a predicated
  instruction, co-issue in pixel 1.x, the destination with its write mask, saturate, partial precision, centroid and
  pixel 1.x result shift, and the sources with their swizzles and modifiers (negate, bias, sign, complement, `_x2`,
  `_dz`, `_dw`, abs, not). Relative addressing keeps its address register (`a0` or the loop counter `aL`) and the
  swizzle as stored; in vertex 1.x, where the index is the implicit `a0.x`, `Relative::word` is `None`.
- **Flow control:** `if`, `if_comp`, `else`, `endif`, `loop`, `endloop`, `rep`, `endrep`, `break`, `break_comp`,
  `breakp`, `call`, `callnz`, `ret` and `label` are read as instructions with their operands; the reader does not
  check that blocks nest.
- **Declarations** (`Declaration`): a sampler's texture type (2D, cube, volume) or an input's or output's usage and
  usage index, with the declared register and its modifiers.
- **Definitions** (`Definition`): `def`, `defi` and `defb`, with the literal as stored (float bits, integers, a bool word).
- **Comments** (`Comment`) with their words, and the `CTAB` comment read as a `ConstantTable`: the creator, target,
  flags and each constant's name, register set, register range, type tree and default value, with the word of its record.
- **Framing** (`frame`): a program at the start of a larger buffer, read to its `END` (found by reading, so an
  `END`-shaped word inside a comment or a literal is not taken for it), and the bytes it spans.
- **One record at a time** (`records`): the same reading as an iterator, so a caller can act on each record in order
  and stop at the first it refuses.

Numbers are Direct3D's own (`D3DSIO_*`, `D3DSPR_*`, `D3DDECLUSAGE`, `D3DXREGISTER_SET`, `D3DXPARAMETER_CLASS`), as
stored.

## What it guarantees

Whatever the stream states (a comment's or an instruction's length, an operand count, a table offset) is checked
against the words that exist before it is read, and the reader does not index or do unchecked arithmetic (both denied
at compile time). Every refusal is an `Error` naming the 32-bit word where it happened and what was expected there:
an opcode or a register type the program's version does not have, reserved bits, an instruction whose stated length
disagrees with its operands, a relative address without its address token, a definition naming another bank's
register, a `CTAB` whose version is not the program's or whose ranges overlap, words after `END`.

## What it does not do

It does not execute, translate, validate or assemble programs. It reads what one instruction says, not what a program
means: it does not check that flow control nests, that a register is written before it is read, that a declaration
comes before the code, or that an index is under a device's register count (the counts are the device's and the
version's caps; `CTAB` ranges are checked to be nonempty and not to overlap). Texture-stage programs from before vs/ps
1.0, effects (`fx_2_0`) and the DXBC container are not its subject.

## Tests

`cargo test -p d3d9-reader`: token streams laid out by hand for every version (the vertex and pixel 1.x texture
instructions, co-issue and result shifts, the 2.x and 3.0 flow control, predication, `aL`, vertex texture fetch,
`vPos` and `vFace`), the constant table, framing, and the refusals by word; every truncation of a program is refused
and every single-bit change of one is read or refused without a panic. `tests/disasm.rs` compares the listing of each
fixture in `tests/disasm` with `D3DDisassemble`'s under 23 flag words. No game files are needed for these.

With `GAME_DATA` naming a real-data configuration, `tests/corpora.rs` compares the listing with Microsoft's for every
program of Shaun White Skateboarding's three SDB2 bundles (7,306) and three more of its programs; the inputs are in
[`tests/inputs/README.md`](tests/inputs/README.md), and each test skips where its input is not configured.

The reader was also checked, outside the repository, against the 173 programs of Wine's `d3dx9` assembler tests
(`vs_1_1` to `ps_3_0`; each read, and its disassembly the same as Wine's apart from spelling), and against the 7,308
distinct `vs_3_0` and `ps_3_0` programs of Shaun White Skateboarding's three shader bundles, whose 783,092 records equal
those of an independent parser. Those programs use none of the flow control, predication or `aL`; the hand-laid tests
are what checks them.

## Check the examples

From the repository root, `cargo test -p d3d9-reader --doc` checks the crate documentation, and
`cargo build -p d3d9-reader --examples` builds the example program, which reads the caller's files.

License: GPL-3.0-or-later.
