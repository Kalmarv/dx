// dxbc: main vs_5_0
// Per-instance data from structured and byte-address buffers, indexed by
// SV_InstanceID: the pattern an engine's instancing uses.
struct Instance
{
	float4x3 transform;
	float4 color;
	uint flags;
};

StructuredBuffer<Instance> instances : register(t0);
ByteAddressBuffer extra : register(t1);

cbuffer Camera : register(b0)
{
	float4x4 viewProj;
};

void main(float3 position : POSITION, uint instance : SV_InstanceID,
	out float4 outPos : SV_Position, out float4 outColor : COLOR0)
{
	Instance inst = instances[instance];
	float3 world = mul(float4(position, 1), inst.transform);
	outPos = mul(float4(world, 1), viewProj);
	float scale = asfloat(extra.Load(instance * 4));
	outColor = inst.color * scale * ((inst.flags & 1) ? 0.5 : 1);
}
