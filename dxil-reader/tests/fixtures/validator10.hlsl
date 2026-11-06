// dxc: -T vs_6_0 -E vs -validator-version 1.0 -Fo validator10.vs.dxil
// dxc: -T ps_6_0 -E ps -validator-version 1.0 -Fo validator10.ps.dxil
// dxc: -T gs_6_0 -E gs -validator-version 1.0 -Fo validator10.gs.dxil
// dxc: -T hs_6_0 -E hs -validator-version 1.0 -Fo validator10.hs.dxil
// dxc: -T ds_6_0 -E ds -validator-version 1.0 -Fo validator10.ds.dxil
// dxc: -T cs_6_0 -E cs -validator-version 1.0 -Fo validator10.cs.dxil
// One program of each Shader Model 6.0 stage as validator 1.0 writes it: its PSV0 part has the 24-byte runtime info
// (the stage union and the wave lane counts, no stage or signature counts) and ends with the resource records, and
// dxc lists the stage from the program header.
cbuffer C : register(b0) { float4x4 wvp; float4 tint; };
Texture2D t : register(t0);
SamplerState ss : register(s0);
struct V { float4 p : SV_Position; float2 uv : TEXCOORD0; };
V vs(float3 p : POSITION, float2 uv : TEXCOORD0) { V o; o.p = mul(float4(p, 1), wvp); o.uv = uv; return o; }
float4 ps(V i) : SV_Target { return t.Sample(ss, i.uv) * tint; }
[maxvertexcount(3)] void gs(triangle V i[3], inout TriangleStream<V> s) { for (int k = 0; k < 3; k++) s.Append(i[k]); }
struct PC { float e[3] : SV_TessFactor; float n : SV_InsideTessFactor; };
PC pc(InputPatch<V, 3> p) { PC o; o.e[0] = o.e[1] = o.e[2] = tint.x; o.n = tint.y; return o; }
[domain("tri")][partitioning("integer")][outputtopology("triangle_cw")][outputcontrolpoints(3)][patchconstantfunc("pc")]
V hs(InputPatch<V, 3> p, uint i : SV_OutputControlPointID) { return p[i]; }
[domain("tri")] V ds(PC c, float3 b : SV_DomainLocation, const OutputPatch<V, 3> p) { V o; o.p = p[0].p * b.x + p[1].p * b.y + p[2].p * b.z; o.uv = p[0].uv; return o; }
RWStructuredBuffer<float4> o : register(u0);
[numthreads(8, 4, 1)] void cs(uint i : SV_DispatchThreadID) { o[i] = tint; }
