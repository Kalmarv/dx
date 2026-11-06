// dxbc: main gs_5_0
// A triangle's corners each become a point that carries the texture
// coordinates of the edges meeting there: arrays in both vertex structs,
// each element in a register of its own, the next field sharing the first.
struct In
{
	float4 pos : SV_Position;
	float2 uv[2] : TEXCOORD0;
	float fade : TEXCOORD2;
};

struct Out
{
	float4 pos : SV_Position;
	float2 edge[3] : TEXCOORD0;
	float fade : TEXCOORD3;
};

[maxvertexcount(3)]
void main(triangle In t[3], inout PointStream<Out> points)
{
	[unroll] for (uint i = 0; i < 3; i++)
	{
		Out o;
		o.pos = t[i].pos;
		o.edge[0] = t[i].uv[0];
		o.edge[1] = t[i].uv[1] * t[(i + 1) % 3].fade;
		o.edge[2] = t[(i + 2) % 3].uv[0] - t[i].uv[1];
		o.fade = t[i].fade;
		points.Append(o);
	}
}
