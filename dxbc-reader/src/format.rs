//! The operand format of each instruction: how many destination and source operands the token format gives an opcode,
//! and what each carries. [`decode`](crate::decode()) checks every instruction against it, so a program whose
//! instruction has another operand count is not a program of this format.
#![deny(
    clippy::arithmetic_side_effects,
    clippy::indexing_slicing,
    clippy::cast_possible_truncation
)]

/// What an operand of an instruction carries.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum OperandClass {
    /// 32-bit float data. A float operand may carry the negate and absolute-value modifiers.
    Float,
    /// 64-bit float data, two lanes of the register pair per value.
    Double,
    /// 32-bit integer data. Whether it is signed is the instruction's (`iadd`, `uadd`...); the token stream does not say.
    Integer,
    /// A register with no data of its own: a resource, sampler, unordered-access view, thread-group shared memory or
    /// output stream the instruction reads from, writes to or asks about.
    Resource,
    /// Data whose type the sources disagree on, or that the instruction takes from elsewhere: a sampled or loaded
    /// value has the type its resource declares, `resinfo`, `sampleinfo` and `bufinfo` return the type their control
    /// bits choose.
    Varies,
}

/// The operands of one opcode, destinations first as they are stored.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct OperandFormat {
    /// The destination operands: registers the instruction writes. A `Resource` destination is a view it writes through.
    pub destinations: &'static [OperandClass],
    /// The source operands.
    pub sources: &'static [OperandClass],
}
impl OperandFormat {
    /// The number of operands, destinations and sources.
    pub fn operands(&self) -> usize {
        self.destinations.len().saturating_add(self.sources.len())
    }
}

const fn entry(
    destinations: &'static [OperandClass],
    sources: &'static [OperandClass],
) -> Option<OperandFormat> {
    Some(OperandFormat {
        destinations,
        sources,
    })
}

/// The operand format of `opcode` (the opcode token's low 11 bits, see [`opcode_name`](crate::opcode_name)). `None` for
/// the opcodes without one: declarations, which [`Declared`](crate::Declared) types, and `call`, `callc`, `label` and
/// `interface_call`, whose operands are not registers a program declares.
///
/// The table is the one vkd3d and DXVK both publish, with their counts agreeing for every opcode both list; where the
/// sources disagree on a type class it is [`OperandClass::Varies`]. `umad`, `emitthencut`, `emitthencut_stream` and
/// `eval_snapped` come from DXVK alone, and `uaddc` and `usubb` (two destinations and two sources) from Microsoft's
/// instruction reference, since neither public table lists them.
pub fn operand_format(opcode: u16) -> Option<OperandFormat> {
    use OperandClass::{Double as D, Float as F, Integer as I, Resource as R, Varies as V};
    match opcode {
        0 => entry(&[F], &[F, F]),                  // add
        1 => entry(&[I], &[I, I]),                  // and
        2 => entry(&[], &[]),                       // break
        3 => entry(&[], &[I]),                      // breakc
        6 => entry(&[], &[I]),                      // case
        7 => entry(&[], &[]),                       // continue
        8 => entry(&[], &[I]),                      // continuec
        9 => entry(&[], &[]),                       // cut
        10 => entry(&[], &[]),                      // default
        11 => entry(&[F], &[F]),                    // deriv_rtx
        12 => entry(&[F], &[F]),                    // deriv_rty
        13 => entry(&[], &[I]),                     // discard
        14 => entry(&[F], &[F, F]),                 // div
        15 => entry(&[F], &[F, F]),                 // dp2
        16 => entry(&[F], &[F, F]),                 // dp3
        17 => entry(&[F], &[F, F]),                 // dp4
        18 => entry(&[], &[]),                      // else
        19 => entry(&[], &[]),                      // emit
        20 => entry(&[], &[]),                      // emitthencut
        21 => entry(&[], &[]),                      // endif
        22 => entry(&[], &[]),                      // endloop
        23 => entry(&[], &[]),                      // endswitch
        24 => entry(&[I], &[F, F]),                 // eq
        25 => entry(&[F], &[F]),                    // exp
        26 => entry(&[F], &[F]),                    // frc
        27 => entry(&[I], &[F]),                    // ftoi
        28 => entry(&[I], &[F]),                    // ftou
        29 => entry(&[I], &[F, F]),                 // ge
        30 => entry(&[I], &[I, I]),                 // iadd
        31 => entry(&[], &[I]),                     // if
        32 => entry(&[I], &[I, I]),                 // ieq
        33 => entry(&[I], &[I, I]),                 // ige
        34 => entry(&[I], &[I, I]),                 // ilt
        35 => entry(&[I], &[I, I, I]),              // imad
        36 => entry(&[I], &[I, I]),                 // imax
        37 => entry(&[I], &[I, I]),                 // imin
        38 => entry(&[I, I], &[I, I]),              // imul
        39 => entry(&[I], &[I, I]),                 // ine
        40 => entry(&[I], &[I]),                    // ineg
        41 => entry(&[I], &[I, I]),                 // ishl
        42 => entry(&[I], &[I, I]),                 // ishr
        43 => entry(&[F], &[I]),                    // itof
        45 => entry(&[V], &[I, R]),                 // ld
        46 => entry(&[V], &[I, R, I]),              // ld_ms
        47 => entry(&[F], &[F]),                    // log
        48 => entry(&[], &[]),                      // loop
        49 => entry(&[I], &[F, F]),                 // lt
        50 => entry(&[F], &[F, F, F]),              // mad
        51 => entry(&[F], &[F, F]),                 // min
        52 => entry(&[F], &[F, F]),                 // max
        54 => entry(&[F], &[F]),                    // mov
        55 => entry(&[F], &[I, F, F]),              // movc
        56 => entry(&[F], &[F, F]),                 // mul
        57 => entry(&[I], &[F, F]),                 // ne
        58 => entry(&[], &[]),                      // nop
        59 => entry(&[I], &[I]),                    // not
        60 => entry(&[I], &[I, I]),                 // or
        61 => entry(&[F], &[I, R]),                 // resinfo
        62 => entry(&[], &[]),                      // ret
        63 => entry(&[], &[I]),                     // retc
        64 => entry(&[F], &[F]),                    // round_ne
        65 => entry(&[F], &[F]),                    // round_ni
        66 => entry(&[F], &[F]),                    // round_pi
        67 => entry(&[F], &[F]),                    // round_z
        68 => entry(&[F], &[F]),                    // rsq
        69 => entry(&[V], &[F, R, R]),              // sample
        70 => entry(&[F], &[F, R, R, F]),           // sample_c
        71 => entry(&[F], &[F, R, R, F]),           // sample_c_lz
        72 => entry(&[V], &[F, R, R, F]),           // sample_l
        73 => entry(&[V], &[F, R, R, F, F]),        // sample_d
        74 => entry(&[V], &[F, R, R, F]),           // sample_b
        75 => entry(&[F], &[F]),                    // sqrt
        76 => entry(&[], &[I]),                     // switch
        77 => entry(&[F, F], &[F]),                 // sincos
        78 => entry(&[I, I], &[I, I]),              // udiv
        79 => entry(&[I], &[I, I]),                 // ult
        80 => entry(&[I], &[I, I]),                 // uge
        81 => entry(&[I, I], &[I, I]),              // umul
        82 => entry(&[I], &[I, I, I]),              // umad
        83 => entry(&[I], &[I, I]),                 // umax
        84 => entry(&[I], &[I, I]),                 // umin
        85 => entry(&[I], &[I, I]),                 // ushr
        86 => entry(&[F], &[I]),                    // utof
        87 => entry(&[I], &[I, I]),                 // xor
        108 => entry(&[F], &[F, R, R]),             // lod
        109 => entry(&[V], &[F, R, R]),             // gather4
        110 => entry(&[F], &[R, I]),                // sample_pos
        111 => entry(&[V], &[R]),                   // sample_info
        117 => entry(&[], &[R]),                    // emit_stream
        118 => entry(&[], &[R]),                    // cut_stream
        119 => entry(&[], &[R]),                    // emitthencut_stream
        121 => entry(&[V], &[R]),                   // bufinfo
        122 => entry(&[F], &[F]),                   // deriv_rtx_coarse
        123 => entry(&[F], &[F]),                   // deriv_rtx_fine
        124 => entry(&[F], &[F]),                   // deriv_rty_coarse
        125 => entry(&[F], &[F]),                   // deriv_rty_fine
        126 => entry(&[F], &[F, R, R, F]),          // gather4_c
        127 => entry(&[F], &[F, I, R, R]),          // gather4_po
        128 => entry(&[F], &[F, I, R, R, F]),       // gather4_po_c
        129 => entry(&[F], &[F]),                   // rcp
        130 => entry(&[I], &[F]),                   // f32tof16
        131 => entry(&[F], &[I]),                   // f16tof32
        132 => entry(&[I, I], &[I, I]),             // uaddc
        133 => entry(&[I, I], &[I, I]),             // usubb
        134 => entry(&[I], &[I]),                   // countbits
        135 => entry(&[I], &[I]),                   // firstbit_hi
        136 => entry(&[I], &[I]),                   // firstbit_lo
        137 => entry(&[I], &[I]),                   // firstbit_shi
        138 => entry(&[I], &[I, I, I]),             // ubfe
        139 => entry(&[I], &[I, I, I]),             // ibfe
        140 => entry(&[I], &[I, I, I, I]),          // bfi
        141 => entry(&[I], &[I]),                   // bfrev
        142 => entry(&[F, F], &[I, F, F]),          // swapc
        163 => entry(&[V], &[I, R]),                // ld_uav_typed
        164 => entry(&[R], &[I, V]),                // store_uav_typed
        165 => entry(&[I], &[I, R]),                // ld_raw
        166 => entry(&[R], &[I, I]),                // store_raw
        167 => entry(&[I], &[I, I, R]),             // ld_structured
        168 => entry(&[R], &[I, I, I]),             // store_structured
        169 => entry(&[R], &[I, I]),                // atomic_and
        170 => entry(&[R], &[I, I]),                // atomic_or
        171 => entry(&[R], &[I, I]),                // atomic_xor
        172 => entry(&[R], &[I, I, I]),             // atomic_cmp_store
        173 => entry(&[R], &[I, I]),                // atomic_iadd
        174 => entry(&[R], &[I, I]),                // atomic_imax
        175 => entry(&[R], &[I, I]),                // atomic_imin
        176 => entry(&[R], &[I, I]),                // atomic_umax
        177 => entry(&[R], &[I, I]),                // atomic_umin
        178 => entry(&[I], &[R]),                   // imm_atomic_alloc
        179 => entry(&[I], &[R]),                   // imm_atomic_consume
        180 => entry(&[I, R], &[I, I]),             // imm_atomic_iadd
        181 => entry(&[I, R], &[I, I]),             // imm_atomic_and
        182 => entry(&[I, R], &[I, I]),             // imm_atomic_or
        183 => entry(&[I, R], &[I, I]),             // imm_atomic_xor
        184 => entry(&[I, R], &[I, I]),             // imm_atomic_exch
        185 => entry(&[I, R], &[I, I, I]),          // imm_atomic_cmp_exch
        186 => entry(&[I, R], &[I, I]),             // imm_atomic_imax
        187 => entry(&[I, R], &[I, I]),             // imm_atomic_imin
        188 => entry(&[I, R], &[I, I]),             // imm_atomic_umax
        189 => entry(&[I, R], &[I, I]),             // imm_atomic_umin
        190 => entry(&[], &[]),                     // sync
        191 => entry(&[D], &[D, D]),                // dadd
        192 => entry(&[D], &[D, D]),                // dmax
        193 => entry(&[D], &[D, D]),                // dmin
        194 => entry(&[D], &[D, D]),                // dmul
        195 => entry(&[I], &[D, D]),                // deq
        196 => entry(&[I], &[D, D]),                // dge
        197 => entry(&[I], &[D, D]),                // dlt
        198 => entry(&[I], &[D, D]),                // dne
        199 => entry(&[D], &[D]),                   // dmov
        200 => entry(&[D], &[I, D, D]),             // dmovc
        201 => entry(&[F], &[D]),                   // dtof
        202 => entry(&[D], &[F]),                   // ftod
        203 => entry(&[F], &[F, V]),                // eval_snapped
        204 => entry(&[F], &[F, I]),                // eval_sample_index
        205 => entry(&[F], &[F]),                   // eval_centroid
        210 => entry(&[D], &[D, D]),                // ddiv
        211 => entry(&[D], &[D, D, D]),             // dfma
        212 => entry(&[D], &[D]),                   // drcp
        213 => entry(&[I], &[I, I, I]),             // msad
        214 => entry(&[I], &[D]),                   // dtoi
        215 => entry(&[I], &[D]),                   // dtou
        216 => entry(&[D], &[I]),                   // itod
        217 => entry(&[D], &[I]),                   // utod
        219 => entry(&[V, I], &[F, R, R]),          // gather4_feedback
        220 => entry(&[F, I], &[F, R, R, F]),       // gather4_c_feedback
        221 => entry(&[F, I], &[F, I, R, R]),       // gather4_po_feedback
        222 => entry(&[F, I], &[F, I, R, R, F]),    // gather4_po_c_feedback
        223 => entry(&[V, I], &[I, R]),             // ld_feedback
        224 => entry(&[V, I], &[I, R, I]),          // ld_ms_feedback
        225 => entry(&[V, I], &[I, R]),             // ld_uav_typed_feedback
        226 => entry(&[I, I], &[I, R]),             // ld_raw_feedback
        227 => entry(&[I, I], &[I, I, R]),          // ld_structured_feedback
        228 => entry(&[V, I], &[F, R, R, F]),       // sample_l_feedback
        229 => entry(&[F, I], &[F, R, R, F]),       // sample_c_lz_feedback
        230 => entry(&[V, I], &[F, R, R, F]),       // sample_clamp_feedback
        231 => entry(&[V, I], &[F, R, R, F, F]),    // sample_b_clamp_feedback
        232 => entry(&[V, I], &[F, R, R, F, F, F]), // sample_d_clamp_feedback
        233 => entry(&[F, I], &[F, R, R, F, F]),    // sample_c_clamp_feedback
        234 => entry(&[I], &[I]),                   // check_access_fully_mapped
        _ => None,
    }
}
