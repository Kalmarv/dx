// Shader Model 5.1 reflection: resources in register spaces other than 0, a resource array, and a constant buffer
// with a variable the program never reads (its D3D_SVF_USED flag clear). The Shader Model 5.0 build of the same source
// (no spaces, a literal array index) shows what changes with 5.1. Compiled with Microsoft fxc 10.0.26100.0:
//   fxc -T ps_5_1 -E main reflection_sm51.hlsl -Fo reflection_sm51.ps51.dxbc
//   fxc -T ps_5_0 -E main -D SM50 reflection_sm51.hlsl -Fo reflection_sm51.ps50.dxbc
#ifdef SM50
#define SPACE(r, s) register(r)
#define LAYER 2
#else
#define SPACE(r, s) register(r, s)
#define LAYER (layer & 3)
#endif
cbuffer Params : SPACE(b1, space2) { float4 tint; float4 unused_scale; uint layer; };
Texture2D albedo : SPACE(t3, space1);
Texture2D detail[4] : SPACE(t4, space1);
SamplerState linear_wrap : SPACE(s2, space3);

float4 main(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_Target {
    return albedo.Sample(linear_wrap, uv) * tint + detail[LAYER].Sample(linear_wrap, uv);
}
