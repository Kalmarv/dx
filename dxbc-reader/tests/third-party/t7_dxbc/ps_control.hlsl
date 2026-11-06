// dxbc: main ps_5_0
// Loops with break and continue, a switch, integer and bit operations,
// relative indexing into a constant buffer array, derivatives, and the
// sampling and load variants on 2D, array and cube textures.
cbuffer Params : register(b0)
{
	float4 table[8];
	uint mode;
	int steps;
	float bias;
	float level;
};

Texture2D<float4> tex : register(t0);
Texture2DArray<float4> layers : register(t1);
TextureCube<float4> sky : register(t2);
Texture2D<float> depthMap : register(t3);
SamplerState linearSampler : register(s0);
SamplerComparisonState shadowSampler : register(s1);

float4 main(float4 pos : SV_Position, float3 uvw : TEXCOORD0, nointerpolation uint id : TEXCOORD1) : SV_Target
{
	float4 acc = 0;
	[loop] for (int i = 0; i < steps; i++)
	{
		if (i == 3)
			continue;
		acc += table[(id + (uint)i) & 7];
		if (acc.x > 10)
			break;
	}
	switch (mode)
	{
	case 0:
		acc += tex.Sample(linearSampler, uvw.xy);
		break;
	case 1:
		acc += tex.SampleLevel(linearSampler, uvw.xy, level);
		break;
	case 2:
		acc += tex.SampleBias(linearSampler, uvw.xy, bias);
		break;
	default:
		acc += tex.SampleGrad(linearSampler, uvw.xy, ddx(uvw.xy), ddy(uvw.xy));
		break;
	}
	acc += layers.Sample(linearSampler, uvw);
	acc += sky.Sample(linearSampler, normalize(uvw));
	acc += tex.Load(int3(pos.xy, 0));
	acc += tex.Gather(linearSampler, uvw.xy);
	acc.w *= depthMap.SampleCmpLevelZero(shadowSampler, uvw.xy, uvw.z);
	uint bits = asuint(acc.x) ^ (id << 3) | (mode >> 1);
	acc.y += (float)countbits(bits) + (float)(int)acc.z;
	return acc + fwidth(uvw.x);
}
