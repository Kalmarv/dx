RWStructuredBuffer<uint4> o : register(u0);
[numthreads(1,1,1)] void main(uint i : SV_DispatchThreadID) { o[i] = msad4(o[i].x, o[i].xy, o[i]); }
