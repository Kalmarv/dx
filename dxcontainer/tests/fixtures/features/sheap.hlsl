// dxc: -T cs_6_6 -E main -Fo sheap.dxil
Texture2D<float4> t : register(t0);
RWStructuredBuffer<float4> o : register(u0);
[numthreads(1,1,1)] void main(uint i : SV_DispatchThreadID) { SamplerState s = SamplerDescriptorHeap[0]; o[i] = t.SampleLevel(s, 0.5, 0); }
