// dxc: -T vs_6_0 -E vs -Zi -Qembed_debug -Fo debug_info.vs.dxil
// dxc: -T ps_6_0 -E ps -Zi -Qembed_debug -Fo debug_info.ps.dxil
// dxc: -T ps_6_0 -E ps -Zi -Qembed_debug -Od -Fo debug_info.ps.od.dxil
// dxc: -T gs_6_0 -E gs -Zi -Qembed_debug -Fo debug_info.gs.dxil
// dxc: -T hs_6_0 -E hs -Zi -Qembed_debug -Fo debug_info.hs.dxil
// dxc: -T ds_6_0 -E ds -Zi -Qembed_debug -Fo debug_info.ds.dxil
// dxc: -T cs_6_0 -E cs -Zi -Qembed_debug -Fo debug_info.cs.dxil
// dxc: -T cs_6_0 -E cs -Zi -Qembed_debug -Od -Fo debug_info.cs.od.dxil
// dxc: -T lib_6_3 -Zi -Qembed_debug -Fo debug_info.lib.dxil
// Programs of every stage and a library built with debug information in the module (-Zi -Qembed_debug), optimized
// and not (-Od): the listing prints the debug metadata nodes, each instruction's !dbg location with its line and
// column, and the debug intrinsics with the variable and expression they describe. The source has an enumeration, a
// namespace, structs, arrays, a matrix, static data, loops with their own locals and helper functions the compiler
// inlines, so the nodes include enumerators, namespaces, lexical blocks, global variables, subranges and inlined
// locations.
namespace Shade {
enum Mode { Plain = 0, Tinted = 2, Inverted = -3 };
static const float weights[3] = { 0.25, 0.5, 0.25 };
float4 tint(float4 c, Mode m) {
    if (m == Inverted) {
        float4 inv = 1 - c;
        return inv;
    }
    return m == Tinted ? c * float4(1, 0.5, 0.5, 1) : c;
}
}
cbuffer C : register(b0) { float4x4 wvp; float4 colour; int mode; uint count; };
Texture2D t : register(t0);
SamplerState ss : register(s0);
struct V { float4 p : SV_Position; float2 uv : TEXCOORD0; };
struct Blend { float4 sum; float total; };
Blend accumulate(Blend b, float4 c, float w) {
    Blend o;
    o.sum = b.sum + c * w;
    o.total = b.total + w;
    return o;
}
V vs(float3 p : POSITION, float2 uv : TEXCOORD0) {
    V o;
    o.p = mul(float4(p, 1), wvp);
    o.uv = uv;
    return o;
}
float4 ps(V i) : SV_Target {
    Blend b = { float4(0, 0, 0, 0), 0 };
    for (uint k = 0; k < 3; k++) {
        float2 at = i.uv + float2(k * 0.01, 0);
        b = accumulate(b, t.Sample(ss, at), Shade::weights[k]);
    }
    return Shade::tint(b.sum / b.total, (Shade::Mode)mode) * colour;
}
[maxvertexcount(3)] void gs(triangle V i[3], inout TriangleStream<V> s) {
    for (int k = 0; k < 3; k++) {
        V v = i[k];
        v.uv *= 2;
        s.Append(v);
    }
}
struct PC { float e[3] : SV_TessFactor; float n : SV_InsideTessFactor; };
PC pc(InputPatch<V, 3> p) {
    PC o;
    o.e[0] = o.e[1] = o.e[2] = colour.x;
    o.n = colour.y;
    return o;
}
[domain("tri")][partitioning("integer")][outputtopology("triangle_cw")][outputcontrolpoints(3)][patchconstantfunc("pc")]
V hs(InputPatch<V, 3> p, uint i : SV_OutputControlPointID) { return p[i]; }
[domain("tri")] V ds(PC c, float3 b : SV_DomainLocation, const OutputPatch<V, 3> p) {
    V o;
    o.p = p[0].p * b.x + p[1].p * b.y + p[2].p * b.z;
    o.uv = p[0].uv * c.n;
    return o;
}
RWStructuredBuffer<float4> o : register(u0);
groupshared float4 shared_rows[8];
[numthreads(8, 1, 1)] void cs(uint i : SV_GroupIndex) {
    shared_rows[i] = colour * i;
    GroupMemoryBarrierWithGroupSync();
    float4 sum = 0;
    for (uint k = 0; k < count && k < 8; k++) {
        sum += shared_rows[k];
    }
    o[i] = Shade::tint(sum, (Shade::Mode)mode);
}
struct Payload { float4 colour; };
[shader("miss")] void miss(inout Payload p) { p.colour = Shade::tint(colour, Shade::Tinted); }
[shader("closesthit")] void hit(inout Payload p, BuiltInTriangleIntersectionAttributes a) {
    p.colour = float4(a.barycentrics, 1 - a.barycentrics.x - a.barycentrics.y, 1);
}
