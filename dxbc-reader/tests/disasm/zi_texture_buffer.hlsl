// TextureBuffer structs with an array member: the debug information gives the array its elements' packed length, so
// the offsets of its later elements are held by no member, and Microsoft's disassembler names those locations with
// its internal error, never the member before (dxc's texture-buffer access test).
// fxc: /T vs_5_1 /E main /Zi /Fo zi_texture_buffer.vs51.zi.dxbc
// fxc: /T vs_5_1 /E main /Zi /Od /Fo zi_texture_buffer.vs51.zod.dxbc
struct S
{
    float f;
};
struct T
{
    float a;
    float2 b;
    float3x4 c;
    S s;
    float t[4];
};
TextureBuffer<T> tb : register(t1);
TextureBuffer<T> tbs[3] : register(t2);
float main() : A
{
    return tb.a + tb.b.x + tb.c[1][2] + tb.s.f + tb.t[3]
            + tbs[2].a + tbs[1].b.x + tbs[0].c[1][2] + tbs[1].s.f + tbs[0].t[3];
}
