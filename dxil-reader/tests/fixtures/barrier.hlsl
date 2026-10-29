// A compute program with a group barrier: the barrier's declaration carries the attributes noduplicate and nounwind.
// Compiled with dxc -T cs_6_0 -E main (barrier.cs.dxil).
RWStructuredBuffer<uint> o : register(u0);
groupshared uint g[8];
[numthreads(8, 1, 1)]
void main(uint i : SV_GroupIndex) { g[i] = i; GroupMemoryBarrierWithGroupSync(); o[i] = g[7 - i]; }
