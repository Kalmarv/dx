// dxbc: main ps_5_0
// Bits a float literal can't keep: firstbithigh of a whole int4 (whose
// helper must take vectors), and a select between an input and constants
// whose bits are -0 and a large negative float (reversebits of 1 and 13).
cbuffer Params : register(b0)
{
	float4 fv;
	float fs;
};

void main(float4 inF : TEXCOORD0, nointerpolation uint4 inU : TEXCOORD1, nointerpolation int4 inI : TEXCOORD2,
	out float4 outF : SV_Target0, out uint4 outU : SV_Target1)
{
	float4 lf = inF;
	uint4 lu = inU;
	int4 li = firstbithigh(inI + int4(fv));
	if (any(dot(-lf.xzw, mad((float3)fs, (float3)fs, lf.yzz)) > inF.yx))
		lu.x = firstbithigh(inU.y);
	else
		lu.yz = reversebits(uint2(13u, 1u));
	outF = lf;
	outU = lu ^ asuint(li);
}
