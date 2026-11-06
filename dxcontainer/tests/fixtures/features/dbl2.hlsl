// dxc: -T cs_6_0 -E main -Fo dbl2.dxil
RWStructuredBuffer<double> o : register(u0);
[numthreads(1,1,1)] void main(uint i : SV_DispatchThreadID) { o[i] = o[i] / o[i+1]; }
