//! Hand-laid tokens: each test spells a program as Microsoft's assembler encodes it (the token layout is the one
//! `d3d9types.h` and the "Direct3D 9 shader codes" reference give).
#![allow(dead_code)]

/// `D3DSPR_*` register types.
pub const TEMP: u32 = 0;
pub const INPUT: u32 = 1;
pub const CONST: u32 = 2;
pub const ADDR: u32 = 3;
pub const TEXTURE: u32 = 3;
pub const RASTOUT: u32 = 4;
pub const ATTROUT: u32 = 5;
pub const OUTPUT: u32 = 6;
pub const CONSTINT: u32 = 7;
pub const COLOROUT: u32 = 8;
pub const DEPTHOUT: u32 = 9;
pub const SAMPLER: u32 = 10;
pub const CONSTBOOL: u32 = 14;
pub const LOOP: u32 = 15;
pub const MISC: u32 = 17;
pub const LABEL: u32 = 18;
pub const PREDICATE: u32 = 19;

/// Bit 31 and the register type, split over bits 28 to 30 and 11 to 12.
pub fn reg(kind: u32, n: u32) -> u32 {
    0x8000_0000 | ((kind & 7) << 28) | ((kind & 0x18) << 8) | n
}
/// A destination token with a write mask.
pub fn dst(kind: u32, n: u32, mask: u32) -> u32 {
    reg(kind, n) | (mask << 16)
}
/// A source token with a swizzle (`0xe4` is `.xyzw`) and a modifier.
pub fn src(kind: u32, n: u32, swizzle: u32, modifier: u32) -> u32 {
    reg(kind, n) | (swizzle << 16) | (modifier << 24)
}
/// An instruction token of Shader Model 2 or 3: the opcode, then the operand tokens counted in bits 24 to 27.
pub fn op(code: u32, operands: &[u32]) -> Vec<u32> {
    [vec![code | ((operands.len() as u32) << 24)], operands.to_vec()].concat()
}
/// A Shader Model 1 instruction token, which states no length.
pub fn op1(code: u32, operands: &[u32]) -> Vec<u32> {
    [vec![code], operands.to_vec()].concat()
}
/// The bytes of a program: its version token, the body, END.
pub fn program(version: u32, body: &[Vec<u32>]) -> Vec<u8> {
    std::iter::once(version)
        .chain(body.iter().flatten().copied())
        .chain([0xffff])
        .flat_map(u32::to_le_bytes)
        .collect()
}
/// The word of a refusal.
pub fn refusal(bytes: &[u8]) -> (usize, String) {
    let e = d3d9_reader::read(bytes).expect_err("a refusal");
    (e.word, e.detail)
}
