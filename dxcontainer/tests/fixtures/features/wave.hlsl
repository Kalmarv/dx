// dxc: -T cs_6_0 -E main -Fo wave.dxil
RWStructuredBuffer<uint> o : register(u0);
[numthreads(32,1,1)] void main(uint i : SV_DispatchThreadID) { o[i] = WaveActiveSum(i); }
