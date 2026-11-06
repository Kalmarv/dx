// dxbc: main ps_5_0
// The blur's pixel shader: it reads the taps from the array the vertex
// shader wrote, and only three of the four.
Texture2D image : register(t0);
SamplerState linearClamp : register(s0);

float4 main(float4 position : SV_Position, float2 taps[4] : TEXCOORD0, float weight : TEXCOORD4) : SV_Target
{
	return (image.Sample(linearClamp, taps[0]) + image.Sample(linearClamp, taps[1]) +
		image.Sample(linearClamp, taps[3])) * weight;
}
