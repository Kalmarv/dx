// dxbc: main ps_5_0
// A material's parameters as global variables, the way Black Ops III's
// shaders take them: the compiler gathers them into $Globals, which the
// decompilation writes back as globals; the one never read stays declared.
float4 colorTint;
float2 uvScroll;
float glow;
float unused;

Texture2D colorMap : register(t0);
SamplerState colorSampler : register(s0);

float4 main(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_Target
{
	float4 c = colorMap.Sample(colorSampler, uv + uvScroll);
	return float4(c.rgb * colorTint.rgb * (1 + glow), c.a);
}
