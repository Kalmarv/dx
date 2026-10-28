RWStructuredBuffer<uint64_t> o : register(u0);
[numthreads(1,1,1)] void main(uint i : SV_DispatchThreadID) { o[i] = o[i] * 3; }
