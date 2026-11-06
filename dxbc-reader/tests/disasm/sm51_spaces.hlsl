// A Shader Model 5.1 pixel program: an unbounded texture array, a sampler array and a ConstantBuffer<T> array in
// register spaces, a non-uniform resource index and an atomic on a structured buffer.
// fxc: /T ps_5_1 /E main /enable_unbounded_descriptor_tables /Fo sm51_spaces.ps51.dxbc
// fxc: /T ps_5_1 /E main /enable_unbounded_descriptor_tables /Zi /Fo sm51_spaces.ps51.zi.dxbc
Texture2D texs[] : register(t0, space1);
SamplerState samps[4] : register(s2, space3);
struct P { float4 c; uint i; };
ConstantBuffer<P> cbs[3] : register(b1, space2);
RWStructuredBuffer<uint> outb : register(u0, space4);
float4 main(float2 uv : TEXCOORD, nointerpolation uint i : IDX) : SV_Target {
  float4 c = texs[NonUniformResourceIndex(i)].Sample(samps[i & 3], uv) * cbs[i % 3].c;
  InterlockedAdd(outb[cbs[0].i], 1);
  return c;
}
