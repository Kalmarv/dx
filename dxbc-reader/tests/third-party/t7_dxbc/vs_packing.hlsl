// dxbc: main vs_5_0
// Outputs whose interpolation modes keep them out of each other's registers
// (which the output signature doesn't record), integer outputs, a clip
// distance, and the vertex and instance ids.
cbuffer Frame : register(b0)
{
	float4x4 viewProj;
	float4 clipPlane;
	float time;
};

struct Output
{
	float4 pos : SV_Position;
	float2 uv : TEXCOORD0;
	nointerpolation uint id : TEXCOORD1;
	float fog : TEXCOORD2;
	centroid float3 normal : NORMAL;
	noperspective float2 screen : TEXCOORD3;
	nointerpolation int2 cell : TEXCOORD4;
	float clip : SV_ClipDistance0;
	float3 tangent : TANGENT;
	float weight : TEXCOORD5;
};

Output main(float3 position : POSITION, float3 normal : NORMAL, float2 uv : TEXCOORD0,
	uint vertex : SV_VertexID, uint instance : SV_InstanceID)
{
	Output o;
	float4 world = float4(position + float3(instance * 2.0, 0, sin(time + vertex)), 1);
	o.pos = mul(world, viewProj);
	o.uv = uv;
	o.id = vertex ^ (instance << 16);
	o.fog = saturate(o.pos.z * 0.01);
	o.normal = normalize(normal);
	o.screen = o.pos.xy / o.pos.w;
	o.cell = int2(floor(world.xz / 8));
	o.clip = dot(world, clipPlane);
	o.tangent = cross(o.normal, float3(0, 1, 0));
	o.weight = frac(time * 0.25);
	return o;
}
