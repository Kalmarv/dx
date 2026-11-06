// Minimum-precision values through instructions with a resource operand (loads, samples, gathers, LOD, atomics) and
// through the attribute evaluations: Microsoft's listing writes no `{x as y}` precision on any instruction with a
// resource operand.
// fxc: /T ps_5_0 /E main /Fo min16_resources.ps50.dxbc
// fxc: /T ps_5_0 /E casts /Fo min16_resources.casts.ps50.dxbc
StructuredBuffer<min16uint> sb : register(t0);
ByteAddressBuffer bab : register(t1);
Texture2D<min16float4> narrow : register(t2);
Texture2D tex : register(t3);
SamplerState smp : register(s0);
SamplerComparisonState cmp : register(s1);
RWByteAddressBuffer rw : register(u1);

min16float4 main(min16float2 uv : TEXCOORD, min16float r : REF, nointerpolation min16uint i : INDEX) : SV_Target
{
    min16uint a = sb[i];
    min16uint b = sb[3];
    min16uint c = (min16uint)bab.Load(i * 4);
    min16float l = narrow.CalculateLevelOfDetail(smp, uv);
    min16float4 s = narrow.Sample(smp, uv);
    float wide = tex.CalculateLevelOfDetail(smp, uv);
    float sc = tex.SampleCmp(cmp, uv, r);
    float cz = tex.SampleCmpLevelZero(cmp, uv, r);
    float4 g = tex.GatherCmp(cmp, uv, r);
    float4 go = tex.GatherCmp(cmp, uv, r, int2(i, 1));
    float4 gp = tex.Gather(smp, uv, int2(i, 2));
    uint old;
    rw.InterlockedAdd(i * 4, i, old);
    return s * l + a + b + c + (min16float4)(wide + sc + cz + g + go + gp + old);
}

float4 casts(float2 uv : TEXCOORD, min16float r : REF, nointerpolation min16uint i : INDEX, min16float2 e : EVAL) : SV_Target
{
    float c = tex.SampleCmp(cmp, uv, (float)r);
    float4 g = tex.GatherCmp(cmp, uv, (float)r);
    uint old;
    rw.InterlockedAdd(0, (uint)i, old);
    uint old2;
    rw.InterlockedCompareExchange(4, (uint)i, (uint)(i + 1), old2);
    float2 s = EvaluateAttributeAtSample(e, 1);
    float2 cc = EvaluateAttributeCentroid(e);
    return float4(c, old, old2, 0) + g + s.xyxy + cc.xyxy;
}
