# rsx-reader

Readers for PlayStation 3 RSX graphics data: `CellGcmTexture` texture descriptors, Cg binary (`CgBinaryProgram`) shader
program containers, and RSX fragment program microcode decoded to typed instructions.

```rust
use rsx_reader::{cgbinary, fragment, gcm};

let texture = gcm::CellGcmTexture::parse(&std::fs::read("texture.bin")?)?; // exactly 24 bytes
println!("{}x{}, {} mips, linear: {}", texture.width, texture.height, texture.mipmap, texture.linear());

let shader = std::fs::read("shader.fpo")?;
let program = cgbinary::parse(&shader)?;
if let cgbinary::Stage::Fragment(_) = program.stage {
    let code = fragment::decode(program.microcode)?;
    print!("{}", code.disassemble());
}
```

Run it with `cargo run -p rsx-reader --example inspect_rsx -- <files>`; the source is [`examples/inspect_rsx.rs`](examples/inspect_rsx.rs).

## What it reads

- **`gcm::CellGcmTexture::parse`**: the 24-byte big-endian libgcm texture descriptor (format, mip count, dimension, cube
  flag, component remap, extents, pitch, and the GPU address fields) as data. It refuses only a descriptor of the wrong
  length; whether the described storage can be decoded is the caller's question.
- **`cgbinary::parse`** reads exactly one big-endian revision-6 `CgBinaryProgram`; `parse_prefix` reads the size it
  advertises, for callers that own concatenation or padding. Profiles 7003 (vertex) and 7004 (fragment) have a 32-byte
  header, 48-byte parameter records and a 24-byte stage descriptor. Microcode stays encoded and is returned as bytes.
  Parameter strings keep their source bytes; resource, type, variability and direction keep the original Cg enum values;
  resource indices and parameter numbers stay signed. `Parameter::texture_unit` recognises the resources
  `CG_TEXUNIT0..15` and does not reinterpret a constant-register index as a sampler. Defaults keep float bits for float
  scalars, vectors and matrices; defaults of other types are refused. The fragment instruction count includes inline
  constant slots.
- **`fragment::decode`** reads unchanged big-endian fragment microcode into instructions, rotating each word's halfwords
  first. It keeps sources, swizzles, predicates, destination masks, modifier bits, texture units, control-flow offsets and
  inline float bits. A constant takes a full extra slot shared by the instruction's constant sources. `disassemble`
  produces stable inspection text.
- **`fragment::flow::analyze`** reports which texture units and interpolators can influence caller-selected output
  registers, discard conditions, sampling coordinates and downstream operations. It tracks component writes, full and half
  register overlap, conditional writes, forward `IF`/`ELSE` regions, `KIL` and `RET`.

## What it guarantees

- `cgbinary` bounds every structure against the advertised size, rejects overlapping fixed structures and metadata inside
  them, and checks alignment, boolean values, string termination and embedded constant offsets. Shared metadata and string
  suffixes are allowed. Padding bytes in the fragment descriptor are kept, and no undocumented requirement that they be zero
  is added. Errors name the byte offset.
- `fragment::decode` requires `END` at the exact end of the microcode and refuses reserved source types, opcodes it has no
  entry for (the bump-environment opcodes, whose encoding is unproven, among them; the error gives the opcode number),
  incomplete constants and branches into constants.
- The register overlap in `flow` follows the RSX register file's byte ranges (four 2-byte lanes per H register and four
  4-byte lanes per R register), which is physical binary addressing and differs from the non-overlapping named temporaries
  of the NV program language.
- `flow::analyze` is conservative: arithmetic unions every referenced source component and condition dependencies survive
  joins, so a reported dependency is a possible influence, not proof that a texel or channel changes a rendered pixel.

## What it does not do

It is container validation and instruction decoding, not microcode validation of hardware behaviour. It does not assemble,
execute or translate programs, does not decode vertex program microcode (the vertex stage descriptor is read, the
microcode is returned encoded), and does not assign a sampler a colour, normal or material role. `flow::analyze` refuses
calls, loops, `BRK` and indexed interpolators; the decoder can still inspect their encoded instructions.

## Sources

Layouts follow RPCS3's public
[`CgBinaryProgram` declarations](https://github.com/RPCS3/rpcs3/blob/979a52415003fd7a74ddd216e1a5782b3731281f/rpcs3/Emu/RSX/Program/CgBinaryProgram.h)
and [register-file ranges](https://github.com/RPCS3/rpcs3/blob/979a52415003fd7a74ddd216e1a5782b3731281f/rpcs3/Emu/RSX/Program/Assembler/FPOpcodes.cpp);
instruction encodings follow its public field and opcode declarations. Opcode semantics and condition vocabulary follow
NVIDIA's [NV_fragment_program](https://registry.khronos.org/OpenGL/extensions/NV/NV_fragment_program.txt) and
[NV_fragment_program2](https://registry.khronos.org/OpenGL/extensions/NV/NV_fragment_program2.txt); Cg enum values come
from the published [Cg header](https://help.autodesk.com/cloudhelp/ENU/Mudbox-SDK/cpp_ref/cg_8h_source.html); texture
descriptors follow [PSL1GHT's `gcmTexture`](https://github.com/ps3dev/PSL1GHT/blob/master/ppu/include/rsx/gcm_sys.h). No
RPCS3 implementation code is copied. Texture sampling with a separate LOD, bias or gradient source (`TXL`, `TXB`, `TXD`) keeps
that source in the decoded instruction; RPCS3's `GLSLCommon.cpp` sampling templates describe it.

## Tests

`cargo test -p rsx-reader`: containers, descriptors and fragment programs laid out by hand, bit by bit, without an encoder,
including metadata fields a compiler may omit, inline constants, flow regions and the refusals. No game files are needed.

License: GPL-3.0-or-later.
