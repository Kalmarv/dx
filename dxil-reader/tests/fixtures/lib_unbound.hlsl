// dxc: -T lib_6_6 -Fo lib_unbound.dxil
// dxc: -T lib_6_9 -Fo lib_unbound.69.dxil
// A library's resources bound to no register: dxc gives each the register and space -1, which its listing writes as
// 4294967295 (`U0u4294967295,space4294967295`); and a reorder-coherent UAV array (6.9), whose tag list has the tag 4
// with the value `i1 true`, which reads as -1.
RWBuffer<uint> unbound_uav;
Texture2D<float4> unbound_srv;
RWBuffer<float> bound : register(u1);
#if __SHADER_TARGET_MINOR >= 9
reordercoherent RWTexture2D<float> coherent[12] : register(u2);
#endif

[shader("compute")]
[numthreads(4, 1, 1)]
void main(uint i : SV_DispatchThreadID)
{
    float v = unbound_srv.Load(int3(i, 0, 0)).x;
#if __SHADER_TARGET_MINOR >= 9
    v += coherent[i % 12][uint2(i, 0)];
#endif
    unbound_uav[i] = (uint)v;
    bound[i] = v;
}
