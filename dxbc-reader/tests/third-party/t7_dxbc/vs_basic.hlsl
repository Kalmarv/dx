// dxbc: main vs_5_0
// A vertex transform with several inputs and outputs.
cbuffer Scene : register(b0)
{
	float4x4 worldViewProj;
	float4x4 world;
	float time;
};

struct VertexIn
{
	float3 position : POSITION;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
	float4 color : COLOR0;
};

struct VertexOut
{
	float4 position : SV_Position;
	float2 uv : TEXCOORD0;
	float3 normal : NORMAL;
	float4 color : COLOR0;
};

VertexOut main(VertexIn v)
{
	VertexOut o;
	float3 p = v.position + v.normal * sin(time) * 0.05;
	o.position = mul(float4(p, 1), worldViewProj);
	o.uv = v.uv;
	o.normal = normalize(mul(v.normal, (float3x3)world));
	o.color = v.color;
	return o;
}
