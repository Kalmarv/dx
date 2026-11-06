// A Shader Model 5.1 compute program: a UAV array indexed by thread id, a raw buffer in register space 7 and group
// shared memory with a barrier.
// fxc: /T cs_5_1 /E main /Fo sm51_compute.cs51.dxbc
RWTexture2D<float4> img[2] : register(u1);
ByteAddressBuffer raw : register(t3, space7);
groupshared float sh[64];
[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID, uint gi : SV_GroupIndex) {
  sh[gi] = asfloat(raw.Load(gi * 4)); GroupMemoryBarrierWithGroupSync();
  img[id.z & 1][id.xy] = sh[63 - gi];
}
