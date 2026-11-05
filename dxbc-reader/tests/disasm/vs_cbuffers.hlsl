// Vertex programs whose reflection has every kind of constant buffer member the listing's Buffer Definitions table
// writes: scalars, vectors, row- and column-major matrices, arrays, nested structs, unused members, default values,
// a tbuffer, a texture read in a vertex program and relative constant buffer addressing.
// fxc: /T vs_4_0 /E main /Fo vs_cbuffers.vs40.dxbc
// fxc: /T vs_5_0 /E main /D SM5 /Fo vs_cbuffers.vs50.dxbc
// fxc: /T vs_5_0 /E main /D SM5 /Qstrip_reflection /Fo vs_cbuffers.strip.dxbc
// fxc: /T vs_5_0 /E main /D SM5 /Od /Fo vs_cbuffers.od.dxbc
struct Light { float3 dir; float range; float4 color[2]; };
struct Bones { row_major float3x4 m; float weight; };
cbuffer Frame : register(b0) {
    float4x4 viewProj;
    row_major float4x4 world;
    float3 eye = float3(1, 2, 3);
    float time = 0.5;
    float2 jitter;
    uint frameIndex;
    int unusedInt;
    bool flag;
    Light lights[4];
    float unusedTail[3];
};
cbuffer Skin : register(b3) {
    Bones bones[32];
#ifdef SM5
    double scaleD;
    min16float halfScale;
#endif
};
tbuffer Extra : register(t2) { float4 extra[8]; };
Texture2D<float> heights : register(t0);
Buffer<uint4> lookup : register(t1);

struct VIn { float3 pos : POSITION; float3 n : NORMAL; float2 uv : TEXCOORD0; uint4 idx : BLENDINDICES; uint vid : SV_VertexID; uint iid : SV_InstanceID; };
struct VOut { float4 pos : SV_Position; float3 n : NORMAL; float2 uv : TEXCOORD0; float4 c : COLOR1; float clip : SV_ClipDistance0; nointerpolation uint id : ID; };

VOut main(VIn v) {
    VOut o;
    float3 p = v.pos;
    for (uint b = 0; b < 2; ++b) {
        Bones k = bones[v.idx[b]];
        p += mul(k.m, float4(v.pos, 1)) * k.weight;
    }
    p.y += heights.Load(int3(v.vid & 15, v.vid >> 4, 0));
    float4 wp = mul(float4(p, 1), world);
    o.pos = mul(wp, viewProj);
    o.n = normalize(v.n + eye * time);
    o.uv = v.uv + jitter;
    float4 c = 0;
    [unroll] for (int i = 0; i < 4; ++i) c += lights[i].color[frameIndex & 1] * saturate(dot(v.n, lights[i].dir));
    o.c = c * (flag ? extra[v.iid & 7] : 1);
#ifdef SM5
    o.c *= (float)scaleD * halfScale;
#endif
    o.clip = dot(wp.xyz, lookup[v.iid].xyz);
    o.id = v.vid ^ v.iid;
    return o;
}
