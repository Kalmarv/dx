groupshared uint64_t g;
RWStructuredBuffer<uint> o : register(u0);
[numthreads(1,1,1)] void main(uint i : SV_DispatchThreadID) { uint64_t old; InterlockedAdd(g, 1, old); o[i] = (uint)old; }
