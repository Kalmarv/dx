// dxbc: main ps_5_0
// Integer and bit arithmetic (bit fields, bit counts and scans, shifts,
// division and remainder, products), half-float packing, sine and cosine of
// one value, rounding, a local array indexed at run time, a constant table,
// constant-buffer arrays of structs and matrices indexed at run time, a switch
// whose cases share code, a loop that continues, and bools in a constant
// buffer and a structured buffer.
struct Light
{
	float3 position;
	float range;
	float4 color;
	uint flags;
};

cbuffer Scene : register(b0)
{
	Light lights[6];
	row_major float3x4 bones[4];
	float4x4 frames[3];
	uint lightCount;
	int offset;
	uint mode;
	float gain;
	bool mirror;
};

struct Flag
{
	bool on;
	float weight;
};

StructuredBuffer<Flag> flags : register(t0);

static const float weights[5] = { 0.1, 0.2, 0.4, 0.2, 0.1 };

float4 main(float4 pos : SV_Position, float2 uv : TEXCOORD0, nointerpolation uint4 bits : TEXCOORD1,
	nointerpolation int4 ints : TEXCOORD2) : SV_Target
{
	uint b = bits.x;
	uint field = (b >> 5) & 0x3F;
	int sfield = (ints.x << 7) >> 20;
	uint merged = (b & ~0xFF00u) | ((bits.y << 8) & 0xFF00u);
	uint hi = firstbithigh(b), lo = firstbitlow(b);
	int shi = firstbithigh(ints.y);
	uint rev = reversebits(bits.z) ^ countbits(bits.w);
	uint q = bits.z / (bits.w | 1), r = bits.z % (bits.w | 1);
	int prod = ints.z * ints.w + offset;
	uint mx = max(b, bits.y) - min(bits.z, bits.w);
	int imx = max(ints.x, ints.y) - min(ints.z, -ints.w);

	uint packed = f32tof16(uv.x) | (f32tof16(uv.y) << 16);
	float2 unpacked = float2(f16tof32(packed), f16tof32(packed >> 16));

	float angle = uv.x * 6.2831853;
	float s, c;
	sincos(angle, s, c);
	float rounded = round(uv.y * 7.5) + floor(uv.x * 3.3) + ceil(uv.y * 2.2) + trunc(-uv.x * 4.4);

	float local[8];
	[unroll] for (int k = 0; k < 8; k++)
		local[k] = uv.x * k + uv.y;
	float picked = local[(b + mode) & 7] + weights[bits.y % 5];

	float3 lit = 0;
	[loop] for (uint i = 0; i < lightCount; i++)
	{
		Light l = lights[(i + b) % 6];
		if ((l.flags & 1) == 0)
			continue;
		float d = distance(l.position, float3(uv, 0));
		lit += l.color.rgb * saturate(1 - d / l.range);
	}
	float3 skinned = mul(bones[b & 3], float4(uv, 1, 1));
	float4 framed = mul(frames[bits.y % 3], float4(skinned, 1));

	float4 o = float4(lit + skinned, framed.w);
	switch (mode)
	{
	case 0:
	case 1:
		o.x += s;
		break;
	case 2:
		o.y += c * gain;
		break;
	case 5:
		o.z -= picked;
		break;
	default:
		o.w *= rounded;
		break;
	}
	o += float4(field, sfield, merged, hi + lo) * 1e-3 + float4(shi, rev, q, r) * 1e-4;
	o += float4(prod, mx, imx, 0) * 1e-5 + float4(unpacked, picked, rounded);
	Flag f = flags[bits.x & 7];
	if (mirror)
		o.xy = o.yx;
	return f.on ? o * f.weight : o;
}
