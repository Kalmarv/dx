// Programs for the Direct3D 9 feature levels: the container holds the Shader Model 2 program (`Aon9` part) beside
// the Shader Model 4 one, and the listing writes both.
// fxc: /T ps_4_0_level_9_1 /E ps /Fo level9.ps91.dxbc
// fxc: /T vs_4_0_level_9_3 /E vs /Fo level9.vs93.dxbc
Texture2D t : register(t0);
SamplerState s : register(s0);
cbuffer C : register(b0) { float4x4 m; float4 tint; };
float4 ps(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_Target { return t.Sample(s, uv) * tint + uv.xyxy; }
float4 vs(float3 p : POSITION, inout float2 uv : TEXCOORD0) : SV_Position { uv *= tint.xy; return mul(float4(p, 1), m); }
