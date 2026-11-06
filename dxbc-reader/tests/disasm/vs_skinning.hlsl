// A Shader Model 4.0 vertex program: skinning by indexed constant buffer rows, a typed buffer load by vertex id.
// fxc: /T vs_4_0 /E main /Fo vs_skinning.vs40.dxbc
// fxc: /T vs_4_0 /E main /Zi /Od /Fo vs_skinning.vs40.zod.dxbc
cbuffer B : register(b0) { float4x4 m; float4 bones[64]; };
Buffer<float4> extra : register(t0);
struct O { float4 p : SV_Position; float4 c : COLOR0; float fog : FOG; };
O main(float4 p : POSITION, uint4 idx : BLENDINDICES, float4 w : BLENDWEIGHT, uint vid : SV_VertexID) {
  O o; float4 q = 0;
  [unroll] for (int i = 0; i < 4; i++) q += bones[idx[i]] * w[i];
  o.p = mul(p + q, m); o.c = extra.Load(vid) * (vid % 3 == 0 ? 2 : 0.5); o.fog = o.p.z / o.p.w; return o;
}
