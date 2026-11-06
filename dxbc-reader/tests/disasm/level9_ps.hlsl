// A pixel program for Direct3D 9 feature levels 9_1 and 9_3: two textures and samplers, a constant buffer array and
// discard; with /Zi, the listing of a level 9 program with an SPDB part.
// fxc: /T ps_4_0_level_9_1 /E main /Fo level9_ps.ps91.dxbc
// fxc: /T ps_4_0_level_9_3 /E main /Fo level9_ps.ps93.dxbc
// fxc: /T ps_4_0_level_9_1 /E main /Zi /Fo level9_ps.ps91.zi.dxbc
Texture2D t0 : register(t0); Texture2D t1 : register(t1);
SamplerState s0 : register(s0); SamplerState s1 : register(s1);
cbuffer C { float4 a; float4 b[3]; float th; };
float4 main(float2 uv : TEXCOORD0, float4 c : COLOR0) : SV_Target {
  float4 x = t0.Sample(s0, uv) * c + b[1];
  float4 y = t1.Sample(s1, uv * a.xy);
  if (x.a < th) discard;
  return lerp(x, y, b[2].x) + b[0] * a;
}
