// dxbc: main ps_5_0
// Per-sample shading: a multisampled texture of unknown sample count, sample
// positions of a texture and of the render target, attributes evaluated at
// the centroid, at a sample and snapped to an offset, and signed atomics on
// a UAV from a pixel shader, whose depth test runs before it.
Texture2DMS<float4> ms : register(t0);
RWStructuredBuffer<int> extremes : register(u1);

[earlydepthstencil]
float4 main(float4 pos : SV_Position, float2 uv : TEXCOORD0, float3 normal : NORMAL, uint s : SV_SampleIndex) : SV_Target
{
	uint w, h, count;
	ms.GetDimensions(w, h, count);
	float2 sp = ms.GetSamplePosition(s % count);
	float2 centroidUV = EvaluateAttributeCentroid(uv);
	float2 sampleUV = EvaluateAttributeAtSample(uv, (s + 1) % count);
	float3 snapped = EvaluateAttributeSnapped(normal, int2(1, -2));
	InterlockedMax(extremes[0], int(pos.x) - 900);
	int old;
	InterlockedMin(extremes[1], -int(pos.y), old);
	uint rtCount = GetRenderTargetSampleCount();
	float2 rtPos = GetRenderTargetSamplePosition(s % rtCount);
	float4 texel = ms.Load(int2(pos.xy) % int2(w, h), s % count);
	return texel + float4(sp + rtPos + centroidUV, sampleUV.x + snapped.x, (float)old + snapped.y + snapped.z);
}
