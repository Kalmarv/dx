RWStructuredBuffer<double> o : register(u0);
[numthreads(1,1,1)] void main(uint i : SV_DispatchThreadID) { o[i] = rcp(o[i]) + fma(o[i], o[i], o[i]); }
