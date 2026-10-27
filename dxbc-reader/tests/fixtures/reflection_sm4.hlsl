// A program whose reflection has every record kind the SM4 and SM5 RDEF layouts differ in: constant buffers with
// scalar, vector, matrix, array and struct variables, texture and sampler bindings. The same source is compiled for
// Shader Model 4.0 (28-byte header, 24-byte variable records, 16-byte type records), 4.1 and 5.0 (the `RD11` layout), so
// the three reflections can be compared. Compiled with Microsoft fxc 10.0.26100.0:
//   fxc -T ps_4_0 -E main reflection_sm4.hlsl -Fo reflection_sm4.ps40.dxbc
//   fxc -T ps_4_1 -E main reflection_sm4.hlsl -Fo reflection_sm4.ps41.dxbc
//   fxc -T ps_5_0 -E main reflection_sm4.hlsl -Fo reflection_sm4.ps50.dxbc
struct Light { float3 position; float radius; float4 color[2]; };

cbuffer Frame : register(b0) {
    float4x4 view_projection;
    row_major float2x3 skew;
    float3 eye;
    float time;
    int count;
    Light lights[2];
    float weights[3];
};
cbuffer Material : register(b2) { float4 tint; uint flags; };

Texture2D albedo : register(t0);
Texture2DArray layers : register(t3);
SamplerState linear_wrap : register(s0);
SamplerComparisonState shadow : register(s4);

float4 main(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_Target {
    float4 c = albedo.Sample(linear_wrap, uv) * tint + layers.Sample(linear_wrap, float3(uv, 1));
    float s = albedo.SampleCmpLevelZero(shadow, uv, eye.z);
    c.xyz += skew[1][2] * eye + lights[1].color[1].xyz * lights[1].position + weights[2] * s;
    c.w += time + count + flags + lights[0].radius;
    return mul(view_projection, c);
}
