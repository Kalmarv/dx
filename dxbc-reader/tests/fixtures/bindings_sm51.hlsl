// Shader Model 5.1 declarations of every kind of binding, in register spaces other than 0: constant buffer arrays, an
// unbounded texture array indexed per thread (NonUniformResourceIndex), comparison and default samplers, raw,
// structured and typed views and unordered-access views. Compiled with Microsoft fxc 10.0.26100.0:
//   fxc -T cs_5_1 -E main -enable_unbounded_descriptor_tables bindings_sm51.hlsl -Fo bindings_sm51.cs.dxbc
struct Light { float4 color; float3 direction; float range; };
struct Params { float4 scale; uint count; };
ConstantBuffer<Params> params[2] : register(b0, space4);
cbuffer Frame : register(b5) { float4x4 view; float time; };
Texture2D<float4> textures[] : register(t0, space1);
Texture2D<float> shadow : register(t2, space2);
ByteAddressBuffer raw : register(t3, space2);
StructuredBuffer<Light> lights : register(t4, space2);
Buffer<uint> indices : register(t5, space2);
SamplerState linear_clamp : register(s0, space1);
SamplerComparisonState shadow_compare : register(s1, space1);
RWTexture2D<float4> output : register(u0, space3);
RWByteAddressBuffer counters : register(u1, space3);
RWStructuredBuffer<Light> lights_out[3] : register(u2, space3);
groupshared float4 shared_color[64];

[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID, uint flat : SV_GroupIndex) {
    uint which = indices[id.x];
    float2 uv = float2(id.xy) * params[which & 1].scale.xy;
    float4 c = textures[NonUniformResourceIndex(which)].SampleLevel(linear_clamp, uv, 0);
    float lit = shadow.SampleCmpLevelZero(shadow_compare, uv, time);
    Light l = lights[flat % params[0].count];
    shared_color[flat] = c * lit * l.color + mul(view, float4(l.direction, 1));
    GroupMemoryBarrierWithGroupSync();
    output[id.xy] = shared_color[(flat + 1) & 63] + asfloat(raw.Load(flat * 4));
    uint old;
    counters.InterlockedAdd(0, 1, old);
    lights_out[old % 3][flat] = l;
}
