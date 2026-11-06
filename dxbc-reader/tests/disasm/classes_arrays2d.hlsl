// Arrays of interface instances indexed by a register (`lights[i * 2 + (sel & 1)]`): `dcl_interface` with an array of
// six and of two, `fcall` through a dynamically indexed slot, and a class method calling another of its class.
// fxc: /T ps_5_0 /E main /Fo classes_arrays2d.ps50.dxbc
// fxc: /T ps_5_0 /E main /Zi /Fo classes_arrays2d.ps50.zi.dxbc
// fxc: /T ps_5_0 /E main /Zi /Od /Fo classes_arrays2d.ps50.zod.dxbc
interface ILight { float3 Shade(float3 n, float3 p); float Atten(float d); };
interface IMat { float4 Albedo(float2 uv); };
Texture2D tex0 : register(t0);
Texture2D tex1 : register(t1);
SamplerState samp : register(s0);
class Dir : ILight { float3 dir; float3 col;
  float3 Shade(float3 n, float3 p) { return col * saturate(dot(n, dir)); }
  float Atten(float d) { return 1; } };
class Point : ILight { float3 pos; float3 col; float range;
  float3 Shade(float3 n, float3 p) { float3 l = pos - p; return col * saturate(dot(n, normalize(l))) * Atten(length(l)); }
  float Atten(float d) { return saturate(1 - d / range); } };
class Plain : IMat { float4 c; float4 Albedo(float2 uv) { return c; } };
class Tex : IMat { Texture2D t; float4 Albedo(float2 uv) { return t.Sample(samp, uv); } };
cbuffer Lights { Dir d0; Point p0; Point p1; Plain m0; Tex m1; };
ILight lights[6];
IMat mats[2];
int count; uint sel;
float4 main(float3 n : NORMAL, float3 p : POS, float2 uv : TEXCOORD) : SV_Target {
  float3 acc = 0;
  [loop] for (int i = 0; i < count; i++) { acc += lights[i * 2 + (sel & 1)].Shade(n, p) * lights[i * 2 + 1].Atten(i); }
  return float4(acc, 1) * mats[sel & 1].Albedo(uv) + mats[0].Albedo(uv * 2);
}
