// A vertex program for Direct3D 9 feature levels 9_1 and 9_3: a loop over light constants and two constant buffers.
// fxc: /T vs_4_0_level_9_1 /E main /Fo level9_vs.vs91.dxbc
// fxc: /T vs_4_0_level_9_3 /E main /Fo level9_vs.vs93.dxbc
cbuffer C : register(b0) { float4x4 wvp; float4 light[4]; }
cbuffer D : register(b1) { float4 scale; }
struct O { float4 p : SV_Position; float4 c : COLOR0; float2 uv : TEXCOORD0; };
O main(float3 p : POSITION, float3 n : NORMAL, float2 uv : TEXCOORD0) {
  O o; o.p = mul(float4(p * scale.xyz, 1), wvp); float l = 0;
  for (int i = 0; i < 4; i++) l += saturate(dot(n, light[i].xyz)) * light[i].w;
  o.c = float4(l.xxx, 1); o.uv = uv; return o; }
