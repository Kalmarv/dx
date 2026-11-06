// dxbc: main ps_5_0
// Constant buffer layouts (scalars, vectors, a matrix, an array, a struct),
// a texture sampled through a sampler, arithmetic, a branch and a discard.
struct Light
{
	float3 color;
	float intensity;
};

cbuffer Material : register(b0)
{
	float4 tint;
	float roughness;
	float2 uvScroll;
	float4x4 uvTransform;
	float4 weights[3];
	Light key;
};

Texture2D<float4> colorMap : register(t0);
SamplerState colorSampler : register(s0);

float4 main(float4 pos : SV_Position, float2 uv : TEXCOORD0, float3 normal : NORMAL) : SV_Target
{
	float2 st = mul(float4(uv + uvScroll, 0, 1), uvTransform).xy;
	float4 c = colorMap.Sample(colorSampler, st) * tint;
	if (c.a < 0.25)
		discard;
	float ndl = saturate(dot(normalize(normal), float3(0, 0, 1)));
	float3 lit = c.rgb * (key.color * key.intensity * ndl + weights[1].xyz) * (1 - roughness);
	return float4(lit, c.a);
}
