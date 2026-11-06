// dxbc: main gs_5_0
// Extrudes each triangle into a prism, twice over by instancing: a loop of
// appends, strips restarted, the primitive and instance ids, an integer and
// a centroid output.
cbuffer Extrude : register(b0)
{
	float4x4 viewProj;
	float depth;
	uint sides;
};

struct VSOut
{
	float4 pos : SV_Position;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
};

struct GSOut
{
	float4 pos : SV_Position;
	centroid float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
	nointerpolation uint face : TEXCOORD1;
};

[maxvertexcount(18)]
[instance(2)]
void main(triangle VSOut tri[3], uint prim : SV_PrimitiveID, uint inst : SV_GSInstanceID,
	inout TriangleStream<GSOut> stream)
{
	float3 n = normalize(cross(tri[1].pos.xyz - tri[0].pos.xyz, tri[2].pos.xyz - tri[0].pos.xyz));
	float offset = depth * (inst + 1);
	GSOut o;
	[loop] for (uint i = 0; i < min(sides, 3); i++)
	{
		uint j = (i + 1) % 3;
		o.normal = n;
		o.face = prim * 4 + i + inst * 64;
		o.pos = mul(tri[i].pos, viewProj); o.uv = tri[i].uv; stream.Append(o);
		o.pos = mul(tri[j].pos, viewProj); o.uv = tri[j].uv; stream.Append(o);
		o.pos = mul(tri[i].pos + float4(n * offset, 0), viewProj); o.uv = tri[i].uv * 0.5; stream.Append(o);
		o.pos = mul(tri[j].pos + float4(n * offset, 0), viewProj); o.uv = tri[j].uv * 0.5; stream.Append(o);
		stream.RestartStrip();
	}
}
