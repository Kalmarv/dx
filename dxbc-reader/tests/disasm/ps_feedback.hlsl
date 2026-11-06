// Every resource read that returns a residency status (the `_s` opcodes), and gathers with programmable offsets: the
// number style of each operand (a gather with offsets from a register writes even its address and reference value as
// integers), and the word fxc leaves after the operands of `sample_d_cl_s`.
// fxc: /T ps_5_0 /E main /Fo ps_feedback.ps50.dxbc
Texture2D tex : register(t0);
Texture2DMS<float4> ms : register(t1);
ByteAddressBuffer bab : register(t2);
StructuredBuffer<float> sb : register(t3);
SamplerState smp : register(s0);
SamplerComparisonState cmp : register(s1);
RWTexture2D<float4> rwt : register(u1);
cbuffer C : register(b0) { float k; int2 o; float2 c; float ref; float4 g; }

float4 main(float2 uv : TEXCOORD) : SV_Target
{
    uint s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15;
    float4 r = 0;
    r += tex.Sample(smp, float2(0.25, 0.5), int2(0, 0), 1.5, s0);
    r += tex.SampleBias(smp, float2(0.25, 0.75), 0.5, int2(0, 0), 2.5, s1);
    r += tex.SampleGrad(smp, float2(0.125, 0.5), float2(0.5, 1), float2(1, 2), int2(0, 0), 3.5, s2);
    r += tex.SampleGrad(smp, uv, g.xy, g.zw, int2(1, -1), g.y, s15);
    r += tex.SampleLevel(smp, float2(0.375, 0.5), 2, int2(0, 0), s3);
    r += tex.SampleCmp(cmp, float2(0.625, 0.5), 0.5, int2(0, 0), 1.25, s4);
    r += tex.SampleCmpLevelZero(cmp, float2(0.875, 0.5), 0.75, int2(0, 0), s5);
    r += tex.Gather(smp, float2(0.25, 0.25), int2(0, 0), s6);
    r += tex.GatherCmp(cmp, float2(0.25, 0.125), 0.5, int2(0, 0), s7);
    r += tex.Gather(smp, float2(0.5, 0.25), o, s8);
    r += tex.GatherCmp(cmp, float2(0.5, 0.125), 0.5, o, s9);
    r += tex.Load(int3(3, 4, 0), int2(0, 0), s10);
    r += ms.Load(int2(5, 6), 1, int2(0, 0), s11);
    r += bab.Load(16, s12);
    r += sb.Load(7, s13);
    r += rwt.Load(int2(8, 9), s14);
    r += tex.Gather(smp, float2(0.25, 0.5), o) + tex.GatherCmp(cmp, uv, 0.5, o) + tex.GatherCmp(cmp, uv, ref, int2(-11, 1))
        + tex.Gather(smp, uv, int2(9, 8)) + tex.Sample(smp, uv, int2(1, 2), 0.25);
    return r + CheckAccessFullyMapped(s0 & s1 & s2 & s3 & s4 & s5 & s6 & s7 & s8 & s9 & s10 & s11 & s12 & s13 & s14 & s15);
}
