// Fixture for `texture_reads`: textures sampled, gathered, queried and loaded with default and comparison samplers, a
// texture array indexed by a constant, and typed and raw buffer loads. Compiled with fxc /T ps_5_0 /E main (the same
// source as the DXIL fixture without its register spaces, which Shader Model 5.0 has none of).
Texture2D<float4> a : register(t3);
Texture2D<float4> b : register(t4);
Texture2DArray<float4> c : register(t5);
Texture2D<float> shadow : register(t6);
Texture2D<float4> arr[3] : register(t8);
Texture2D<float4> loaded : register(t20);
Buffer<float4> typed : register(t21);
ByteAddressBuffer raw : register(t22);
SamplerState linear_s : register(s1);
SamplerState wrap_s : register(s2);
SamplerComparisonState cmp_s : register(s4);

float4 main(float4 p : SV_Position, float2 uv : TEXCOORD0, uint i : INDEX) : SV_Target
{
    float4 r = a.Sample(linear_s, uv);
    r += b.SampleLevel(wrap_s, uv, 0);
    r += c.SampleBias(linear_s, float3(uv, 0), 1);
    r += shadow.SampleCmp(cmp_s, uv, 0.5);
    r += shadow.SampleCmpLevelZero(cmp_s, uv, 0.5);
    r += a.Gather(wrap_s, uv);
    r += shadow.GatherCmp(cmp_s, uv, 0.5);
    r += arr[1].SampleGrad(linear_s, uv, ddx(uv), ddy(uv));
    r += loaded.Load(int3(p.xy, 0));
    r += typed.Load(i);
    r += raw.Load4(i * 16);
    r.x += a.CalculateLevelOfDetail(wrap_s, uv);
    return r;
}
