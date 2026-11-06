// dxbc: main ps_5_0
// Texture shapes and their reads: 1D, 3D, cube arrays, multisampled loads,
// typed buffers, gathers of each channel with immediate and programmable
// offsets, comparison gathers and samples, levels of detail, sizes as floats
// and integers; inputs interpolated each way, the front face, several
// render targets of different types, a depth output and a discard.
Texture1D<float4> ramp : register(t0);
Texture3D<float4> volume : register(t1);
TextureCubeArray<float4> probes : register(t2);
Texture2DMS<float4, 4> msaa : register(t3);
Texture2D<float4> albedo : register(t4);
Texture2D<float> shadow : register(t5);
Texture2DArray<uint2> ids : register(t6);
Buffer<uint4> lookup : register(t7);
SamplerState linearSampler : register(s0);
SamplerComparisonState shadowSampler : register(s1);

cbuffer Material : register(b0)
{
	float4 tint;
	float cutoff;
	int2 texelShift;
	uint layer;
};

struct Output
{
	float4 color : SV_Target0;
	uint4 id : SV_Target1;
	float2 motion : SV_Target2;
	float depth : SV_Depth;
};

Output main(float4 pos : SV_Position, float2 uv : TEXCOORD0, centroid float3 normal : NORMAL,
	nointerpolation uint2 key : TEXCOORD1, sample float4 extra : TEXCOORD2, noperspective float fade : TEXCOORD3,
	bool front : SV_IsFrontFace)
{
	float4 c = albedo.Sample(linearSampler, uv, int2(1, -1)) * tint;
	c += ramp.SampleLevel(linearSampler, uv.x, 2);
	c += volume.SampleBias(linearSampler, float3(uv, fade), -0.5, int3(0, 1, -1));
	c += probes.SampleGrad(linearSampler, float4(normal, layer), normal * 0.1, normal.zyx * 0.2);
	c += msaa.Load(int2(pos.xy), key.x & 3);
	c += albedo.GatherGreen(linearSampler, uv, int2(-1, 0));
	c += albedo.GatherAlpha(linearSampler, uv, texelShift);
	c += albedo.Gather(linearSampler, uv);
	c.x += shadow.SampleCmp(shadowSampler, uv, extra.w);
	c.y += shadow.GatherCmpRed(shadowSampler, uv, extra.z).w;
	c.z += albedo.CalculateLevelOfDetail(linearSampler, uv) + albedo.CalculateLevelOfDetailUnclamped(linearSampler, uv);

	float w, h, levels;
	albedo.GetDimensions(1, w, h, levels);
	uint vw, vh, vd, vlevels;
	volume.GetDimensions(0, vw, vh, vd, vlevels);
	uint mw, mh, samples;
	msaa.GetDimensions(mw, mh, samples);
	c.w += w / h + levels + (float)(vw + vh + vd + vlevels + mw + mh + samples);

	uint2 idv = ids.Load(int4(key, layer, 0));
	uint4 l = lookup.Load(idv.x & 15);
	if (c.w < cutoff)
		discard;

	Output o;
	o.color = front ? c : -c;
	o.id = uint4(idv, l.xy ^ key);
	o.motion = extra.xy - pos.xy * fade;
	o.depth = saturate(pos.z + l.z * 0.001);
	return o;
}
