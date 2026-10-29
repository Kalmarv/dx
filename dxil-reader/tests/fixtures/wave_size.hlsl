// A compute program that states the wave size it needs (Shader Model 6.6). Compiled with dxc -T cs_6_6 -E main
// (wave_size.cs.dxil).
RWStructuredBuffer<uint> o : register(u0);
[WaveSize(32)]
[numthreads(32, 1, 1)]
void main(uint i : SV_DispatchThreadID) { o[i] = WaveGetLaneCount(); }
