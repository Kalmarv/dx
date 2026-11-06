// Shader Model 5.1 pixel and vertex programs: resource arrays with dynamic and non-uniform indices, register spaces,
// constant buffers declared as structured ConstantBuffer<T> arrays, a rasterizer-ordered view and a stencil
// reference output.
// fxc: /T ps_5_1 /E main /enable_unbounded_descriptor_tables /Fo sm51.ps51.dxbc
// fxc: /T vs_5_1 /E vs /Fo sm51.vs51.dxbc
// fxc: /T ps_5_1 /E main /enable_unbounded_descriptor_tables /Zi /Fo sm51.ps51.zi.dxbc
// fxc: /T ps_5_1 /E main /enable_unbounded_descriptor_tables /Zi /Od /Fo sm51.ps51.zod.dxbc
// fxc: /T vs_5_1 /E vs /Zi /Fo sm51.vs51.zi.dxbc
// fxc: /T vs_5_1 /E vs /Zi /Od /Fo sm51.vs51.zod.dxbc
struct Material { float4 color; uint tex; float3 pad; };
ConstantBuffer<Material> materials[8] : register(b0, space1);
cbuffer Frame : register(b2) { float4x4 viewProj; uint drawIndex; };
Texture2D<float4> textures[] : register(t0, space2);
Texture2D<float4> single : register(t4);
SamplerState samplers[4] : register(s1, space3);
RasterizerOrderedTexture2D<float4> rov : register(u0);
RWStructuredBuffer<uint> counts[2] : register(u1, space4);
struct PIn { float4 pos : SV_Position; float2 uv : TEXCOORD0; nointerpolation uint id : ID; };
struct POut { float4 c : SV_Target; uint stencil : SV_StencilRef; };
POut main(PIn p) {
    POut o;
    Material m = materials[p.id & 7];
    float4 c = textures[NonUniformResourceIndex(m.tex)].Sample(samplers[drawIndex & 3], p.uv) * m.color;
    c += single.Sample(samplers[0], p.uv);
    rov[uint2(p.pos.xy)] = rov[uint2(p.pos.xy)] * 0.5 + c;
    InterlockedAdd(counts[p.id & 1][0], 1);
    o.c = c;
    o.stencil = m.tex & 255;
    return o;
}
float4 vs(float3 pos : POSITION, uint iid : SV_InstanceID) : SV_Position {
    return mul(float4(pos, 1) * materials[iid & 7].color, viewProj);
}
