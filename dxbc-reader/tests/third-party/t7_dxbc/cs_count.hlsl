// dxbc: main cs_5_0
// A count the application packs into a float variable and the shader reads
// back as bits: a loop over as many points as it says.
cbuffer Debug : register(b0)
{
	float4 packed;
};

StructuredBuffer<float3> points : register(t0);
RWStructuredBuffer<float> nearest : register(u0);

[numthreads(4, 1, 1)]
void main(uint3 id : SV_DispatchThreadID)
{
	float best = 1e30;
	for (uint i = 0; i < asuint(packed.x); i++)
		best = min(best, distance(points[i], float3(id)));
	nearest[id.x] = best;
}
