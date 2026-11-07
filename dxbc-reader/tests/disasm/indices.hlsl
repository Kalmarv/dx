// Register numbers and indices of every kind: a constant buffer, an indexable temp and an input array read at a
// register plus a constant, a texture array and a sampler, raw and structured views and system values, in Shader Model 5.0
// and 5.1 builds. `../../examples/patched_fixtures.rs` edits them into programs with numbers past 2^31, which
// Microsoft writes signed or unsigned by where they are.
// fxc: /T ps_5_0 /E main /Fo indices.ps50.dxbc
// fxc: /T ps_5_1 /E main /Fo indices.ps51.dxbc
cbuffer C : register(b1) { float4 pad[3]; float4 rows[8]; uint k; };
Texture2D t[2] : register(t2);
SamplerState s : register(s3);
ByteAddressBuffer raw : register(t5);
RWStructuredBuffer<float4> out_rows : register(u1);
// Shader Model 5.0 indexes a texture array by a constant only
#if __SHADER_TARGET_MINOR == 1
#define PICK (k & 1)
#else
#define PICK 1
#endif
float4 main(float4 p : SV_Position, float4 v[3] : TEXCOORD0, bool front : SV_IsFrontFace) : SV_Target {
  float4 x[4] = { p, v[0], v[1], v[2] };
  x[k & 3] += rows[k];
  float4 c = x[(k + 1) & 3] + v[k % 3] + t[PICK].Sample(s, p.xy) + asfloat(raw.Load(k * 4));
  out_rows[k] = c;
  return front ? c : -c;
}
