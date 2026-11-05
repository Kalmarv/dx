// Pixel programs with Shader Model 5 inputs and outputs: attribute evaluation, sample index and coverage, a
// conservative depth output, the coverage mask, an indexable temporary, minimum precision, doubles, unordered-access
// views written from a pixel program and forced early depth-stencil.
// fxc: /T ps_5_0 /E main /Fo ps_sm5.ps50.dxbc
// fxc: /T ps_5_0 /E main /D EARLY /Fo ps_sm5.early.dxbc
// fxc: /T ps_5_0 /E main /Od /Zi /Fo ps_sm5.debug.dxbc
RWTexture2D<float4> image : register(u1);
RWStructuredBuffer<uint> counts : register(u2);
globallycoherent RWByteAddressBuffer bytes : register(u3);
cbuffer C { float4 k; double2 dk; uint sel; };
struct PIn {
    float4 pos : SV_Position;
    float4 a : TEXCOORD0;
    sample float2 s : TEXCOORD1;
    noperspective centroid float3 nc : TEXCOORD2;
    linear noperspective sample float ns : TEXCOORD3;
    min16float2 h : TEXCOORD4;
    uint coverage : SV_Coverage;
    uint index : SV_SampleIndex;
};
struct POut { float4 c : SV_Target; min16float4 h : SV_Target1; float d : SV_DepthGreaterEqual; uint mask : SV_Coverage; };
#ifdef EARLY
[earlydepthstencil]
#endif
POut main(PIn p) {
    POut o;
    float4 arr[5];
    [unroll] for (int i = 0; i < 5; ++i) arr[i] = p.a * i;
    float4 c = arr[sel % 5];
    c += EvaluateAttributeAtSample(p.a, p.index) + EvaluateAttributeAtCentroid(p.a) + EvaluateAttributeSnapped(p.a, int2(1, -1));
    c.xy += p.s + GetRenderTargetSamplePosition(p.index) * GetRenderTargetSampleCount();
    double d = dk.x * (double)c.x + dk.y;
    d = fma(d, dk.y, dk.x);
    c.x += (float)(d / dk.y);
    c.y += (float)min(d, dk.x) + (float)(d == dk.y);
    min16float2 h = p.h * (min16float2)k.xy + (min16float)1.5;
    uint old;
    InterlockedAdd(counts[sel], 1, old);
    image[uint2(p.pos.xy)] = c;
    bytes.InterlockedMax(sel * 4, old);
    bytes.Store3(16, asuint(c.xyz));
    o.c = c + p.nc.xyzx + p.ns;
    o.h = h.xyxy;
    o.d = p.pos.z + 0.01;
    o.mask = p.coverage & 5;
    return o;
}
