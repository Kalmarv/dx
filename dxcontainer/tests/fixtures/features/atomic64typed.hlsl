RWTexture2D<uint64_t> t : register(u0);
[numthreads(1,1,1)] void main(uint2 i : SV_DispatchThreadID) { uint64_t old; InterlockedAdd(t[i], 1, old); }
