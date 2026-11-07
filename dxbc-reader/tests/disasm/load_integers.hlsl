// The loads and queries whose immediates Microsoft writes as integers: a raw and a structured buffer's address and
// offset (from a view and a read-write view, and with a residency status), a mip level, a sample index and a sample
// position's, each an immediate a float's bits would write as a float (0x3f800000 is 1.0).
// fxc: /T ps_5_0 /E main /Fo load_integers.ps50.dxbc
ByteAddressBuffer raw : register(t0);
StructuredBuffer<float4> structured : register(t1);
Texture2D<float4> plain : register(t2);
Texture2DMS<float4, 4> multi : register(t3);
RWByteAddressBuffer rw_raw : register(u1);
RWStructuredBuffer<float4> rw_structured : register(u2);
float4 main(float4 p : SV_Position, float4 a : TEXCOORD0) : SV_Target {
  uint status, w, h, levels;
  float4 c = asfloat(raw.Load(0x3f800000)) + structured[0x3f800000];
  c += asfloat(raw.Load(0x40000000, status)) + structured.Load(0x40400000, status);
  c += asfloat(rw_raw.Load(0x3f800000)) + rw_structured[0x3f800000];
  plain.GetDimensions(0x3f800000, w, h, levels);
  c += float4(w, h, levels, CheckAccessFullyMapped(status));
  c.xy += multi.GetSamplePosition(0x3f800000);
  return c + EvaluateAttributeAtSample(a, 0x3f800000);
}
