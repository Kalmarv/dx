// Double immediates that are infinities and NaNs: Microsoft's disassembler writes -1.#INF00l and 1.#INF00l, 1.#SNAN0l
// for a signaling NaN (the quiet bit, 51, clear), -1.#IND00l for the default NaN and 1.#QNAN0l for another quiet one.
// Each NaN is chosen by a dmovc, which fxc does not fold.
// fxc: /T cs_5_0 /E main /Fo double_specials.cs50.dxbc
RWByteAddressBuffer o : register(u0);
void put(uint at, double v) { uint lo, hi; asuint(v, lo, hi); o.Store2(at, uint2(lo, hi)); }
[numthreads(1, 1, 1)]
void main(uint3 t : SV_DispatchThreadID)
{
    double x = asdouble(t.x, t.y);
    put(0, x * asdouble(0u, 0xfff00000u));          // -inf
    put(8, x * asdouble(0u, 0x7ff00000u));          // +inf
    put(16, t.z ? x : asdouble(1u, 0x7ff00001u));   // a signaling NaN
    put(24, t.z ? x : asdouble(1u, 0xfff00001u));   // a negative signaling NaN
    put(32, t.z ? x : asdouble(0u, 0xfff80000u));   // the default NaN
    put(40, t.z ? x : asdouble(5u, 0x7ff80000u));   // a quiet NaN
    put(48, t.z ? x : asdouble(5u, 0xfff80000u));   // a negative quiet NaN
}
