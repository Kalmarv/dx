// dxbc: main ps_4_1
// Shader Model 4 records no type names: the structs come back named after
// what holds them, and stay apart, a.b's and a_b's too.
struct Light
{
	float3 position;
	float range;
};

struct Flag
{
	bool on;
	float weight;
};

struct Inner
{
	float2 uv;
};

struct Outer
{
	Inner b;
	float w;
};

struct Other
{
	float4 tint;
};

cbuffer Scene : register(b0)
{
	Light lights[2];
	Outer a;
	Other a_b;
};

StructuredBuffer<Flag> flags : register(t0);

float4 main(float4 pos : SV_Position, nointerpolation uint index : TEXCOORD0) : SV_Target
{
	Flag f = flags[index & 3];
	Light l = lights[index & 1];
	float d = distance(l.position.xy + a.b.uv, pos.xy) / l.range;
	return f.on ? float4(d, f.weight, a.w, 1) * a_b.tint : 0;
}
