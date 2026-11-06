// /Zi builds of a pixel program with inlined calls three deep, one in a loop, a branch with an else and a function
// returning a struct: which variables' locations the listing writes after an instruction of a caller, of the call or
// of a call nested in it.
// fxc: /T ps_5_0 /E main /Zi /Fo zi_scopes.ps50.zi.dxbc
// fxc: /T ps_5_0 /E main /Zi /Od /Fo zi_scopes.ps50.zod.dxbc
// fxc: /T ps_4_0 /E main /Zi /Fo zi_scopes.ps40.zi.dxbc
cbuffer C { float4 tint; float4 dirs[8]; float k; int n; };
Texture2D t : register(t0);
SamplerState s : register(s0);
struct L { float3 c; float w; };
float inner(float3 a, float3 b)
{
    float d = dot(a, b);
    return d > 0 ? d * k : -d;
}
L middle(float3 nrm, int i)
{
    L l;
    float d = inner(nrm, dirs[i].xyz);
    if (d > 0.25)
        l.c = dirs[i].xyz * d;
    else
        l.c = nrm * (1 - d);
    l.w = d + inner(l.c, nrm);
    return l;
}
float4 outer(float3 nrm, float2 uv)
{
    float3 acc = 0;
    float wsum = 0;
    [loop] for (int i = 0; i < n; i++)
    {
        L l = middle(nrm, i);
        acc += l.c * l.w;
        wsum += l.w;
    }
    float4 c = t.Sample(s, uv);
    return float4(acc / max(wsum, 1e-3), 1) * c;
}
float4 main(float3 nrm : NORMAL, float2 uv : TEXCOORD0) : SV_Target
{
    float4 x = outer(nrm, uv);
    float y = inner(nrm, x.xyz);
    float4 z = outer(-nrm, uv * y);
    return x * tint + z * y;
}
