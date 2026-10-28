[numthreads(1,1,1)] void main(uint i : SV_DispatchThreadID) { RWStructuredBuffer<uint> o = ResourceDescriptorHeap[0]; o[i] = 1; }
