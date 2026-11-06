// dxbc: main gs_5_0
// A point becomes a short line, or nothing: a line strip out of a point in.
cbuffer Sparks : register(b0)
{
	float4 velocity;
	float minSize;
};

struct In
{
	float4 pos : SV_Position;
	float size : PSIZE;
	uint flags : TEXCOORD0;
};

struct Out
{
	float4 pos : SV_Position;
	float fade : TEXCOORD0;
};

[maxvertexcount(2)]
void main(point In p[1], inout LineStream<Out> lines)
{
	if (p[0].size < minSize || (p[0].flags & 1) != 0)
		return;
	Out o;
	o.pos = p[0].pos;
	o.fade = 1;
	lines.Append(o);
	o.pos = p[0].pos + velocity * p[0].size;
	o.fade = 0;
	lines.Append(o);
}
