// Resource records with their optional fields: a multisampled texture (sample count), a globally coherent buffer, a
// rasterizer-ordered view, a 64-bit atomic target, structured and typed views, a constant buffer and a sampler. Compiled with
// dxc -T ps_6_6 -E main (extras.ps.dxil).
Texture2DMS<float4, 4> ms : register(t0);
Texture2D<float4> plain : register(t1);
StructuredBuffer<uint2> sb : register(t2);
globallycoherent RWBuffer<uint> coherent : register(u0);
RasterizerOrderedTexture2D<float4> rov : register(u1);
RWByteAddressBuffer atomic64 : register(u2);
RWStructuredBuffer<float> counted : register(u3);
cbuffer C : register(b0) { float4 k; };
SamplerState s : register(s0);
SamplerComparisonState sc : register(s1);

float4 main(float4 p : SV_Position) : SV_Target {
    uint2 xy = (uint2)p.xy;
    InterlockedAdd(coherent[0], 1);
    uint64_t old;
    atomic64.InterlockedAdd64(0, 1ull, old);
    uint n = counted.IncrementCounter();
    counted[n] = k.x;
    rov[xy] = ms.Load(xy, 1) + plain.Sample(s, p.xy) + sb[1].xyxy + (float)old + plain.SampleCmp(sc, p.xy, 0.5);
    return rov[xy];
}
