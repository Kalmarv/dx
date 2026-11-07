// Minimum precision in a Direct3D 9 feature level program: the Shader Model 2 program (`Aon9` part) marks each
// operand's precision, which its listing writes after the operand (`r0 {min16f}`).
// fxc: /T ps_4_0_level_9_1 /E main /Fo level9_min16.ps91.dxbc
// fxc: /T ps_4_0_level_9_3 /E main /Fo level9_min16.ps93.dxbc
Texture2D t : register(t0);
SamplerState s : register(s0);
cbuffer C : register(b0) { min16float4 tint; float4 bias; };
min16float4 main(float4 pos : SV_Position, min16float2 uv : TEXCOORD0, min16float4 c : COLOR0) : SV_Target {
  min16float4 x = (min16float4)t.Sample(s, uv) * c * tint;
  return x + (min16float4)bias + abs(-x.yxzw);
}
