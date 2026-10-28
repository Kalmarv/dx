[numthreads(1,1,1)] void main(uint i : SV_DispatchThreadID) { RWStructuredBuffer<uint64_t> o = ResourceDescriptorHeap[0]; uint64_t old; InterlockedAdd(o[i], 1, old); }
