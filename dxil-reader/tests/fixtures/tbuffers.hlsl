// dxc: -T ps_6_0 -E main -Fo tbuffers.dxil
// dxc: -T ps_6_0 -E main -Od -Fo tbuffers.od.dxil
// dxc: -T ps_6_6 -E main -Fo tbuffers.66.dxil
// Texture buffers beside a constant buffer: a `tbuffer` block and `TextureBuffer<T>` views, one in a register space and
// one an array, which DXIL keeps as SRVs of the TBuffer kind. What the listing's Buffer Definitions and Resource
// Bindings tables write for them.
struct Light { float4 colour; float3 dir; float range; };
cbuffer Frame : register(b0) { float4 tint; uint pick; };
tbuffer Material : register(t0) { float4 albedo; float4 params[3]; };
TextureBuffer<Light> sun : register(t2, space1);
TextureBuffer<Light> lamps[2] : register(t4);
float4 main(float3 n : NORMAL) : SV_Target
{
    float d = saturate(dot(n, sun.dir)) * sun.range;
    float4 c = albedo * params[pick % 3] * d + sun.colour;
    c += lamps[pick & 1].colour * saturate(dot(n, lamps[pick & 1].dir));
    return c * tint;
}
