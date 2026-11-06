// dxbc: main vs_5_0
// A separable blur's vertex shader: the four tap coordinates go out as an
// array, each float2 in a register of its own where four scalars would pack
// two to a register.
cbuffer Blur : register(b0)
{
	float2 step;
};

void main(float4 pos : POSITION, float2 uv : TEXCOORD0, out float4 position : SV_Position,
	out float2 taps[4] : TEXCOORD0, out float weight : TEXCOORD4)
{
	position = pos;
	[unroll] for (int i = 0; i < 4; i++)
		taps[i] = uv + step * (i - 1.5);
	weight = 0.25;
}
