// dxc: -T cs_6_0 -E main -Fo typeduav.dxil
RWTexture2D<float4> t : register(u0);
[numthreads(1,1,1)] void main(uint2 i : SV_DispatchThreadID) { t[i] = t[i] + 1; }
