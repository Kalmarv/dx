// /Zi builds of a pixel program whose function is inlined twice and inlines a function from an included file: the
// inlinee lines of signature 1 that code from an `#include` makes (`zi_inlined.hlsli`), the code length a binary
// annotation states (op 4, which moves the code offset past the row), and the variables of an inlined call, whose
// locations are written only after an instruction in the code the call spans.
// fxc: /T ps_5_0 /E main /Zi /Fo zi_inlined.ps50.zi.dxbc
// fxc: /T ps_5_0 /E main /Zi /Od /Fo zi_inlined.ps50.zod.dxbc
// fxc: /T ps_4_0 /E main /Zi /Fo zi_inlined.ps40.zi.dxbc
#include "zi_inlined.hlsli"
cbuffer C { float4x4 wvp; float4 tint; float k; };
Texture2D t : register(t0);
SamplerState s : register(s0);
struct V { float4 pos : SV_Position; float2 uv : TEXCOORD0; float3 n : NORMAL; };
float4 helper(float2 uv, float3 n)
{
    float4 c = t.Sample(s, uv);
    float3 f = fold(n, k);
    if (c.a < 0.5)
        f = f.zyx;
    return float4(c.rgb * f, c.a) * tint;
}
float4 main(V v) : SV_Target
{
    float4 a = helper(v.uv, v.n);
    float4 b = helper(v.uv * 2, -v.n);
    return lerp(a, b, k);
}
