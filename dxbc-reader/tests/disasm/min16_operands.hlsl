// Which sources take the precision of the result ({def32 as min16u}): arithmetic, bit operations, comparisons,
// conversions, shifts, selects and loads, with min16 and full-precision operands mixed.
// fxc: /T ps_5_0 /E main /Fo min16_operands.ps50.dxbc
// fxc: /T ps_4_0 /E main /Fo min16_operands.ps40.dxbc
Texture2D<float4> tex : register(t0);
Buffer<float4> buf : register(t1);
cbuffer C : register(b0) { float4 k; uint4 u; int4 s; min16float4 h; };
float4 main(float4 p : TEXCOORD0, nointerpolation uint4 q : TEXCOORD1) : SV_Target
{
    min16uint a = (min16uint)p.x;          // ftou to min16u
    min16int b = (min16int)p.y;            // ftoi to min16i
    min16float c = (min16float)q.z;        // utof to min16f
    min16uint d = a + (min16uint)q.x;      // iadd mixed
    min16uint e = (d & 7) | (a ^ q.y);     // and, or, xor
    min16uint f = e >> 2;                  // ushr
    min16int g = b << 1;                   // ishl
    bool eq = a == (min16uint)q.w;         // ieq
    bool lt = b < (min16int)s.x;           // ilt
    bool fl = c < (min16float)p.z;         // lt
    bool ul = a < (min16uint)u.x;          // ult
    float4 t = tex.Load(int3(a, d, 0));    // ld with min16 address
    float4 v = buf.Load(f);                // ld buffer
    float4 sel = eq ? t : v;               // movc
    float4 r = sel * h + k;                // mad mixed
    r.x += fl ? 1 : 0;
    r.y += lt ? (float)g : (float)e;
    r.z += ul ? min(c, h.x) : max(c, h.y);
    r.w += (float)(min16int)abs(b - g);
    return r;
}
