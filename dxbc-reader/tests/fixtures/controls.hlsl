// Instructions whose opcode token carries control bits besides saturate and the test: the synchronisation flags of a barrier,
// the return type of a size query and the precise mask of an arithmetic instruction. Compiled with
// fxc /T cs_5_0 /E main (controls.cs.dxbc, listing controls.cs.lst).
RWStructuredBuffer<float> o : register(u0);
Texture2D<float4> t : register(t0);
groupshared float g[64];

[numthreads(64, 1, 1)]
void main(uint i : SV_GroupIndex) {
    uint w, h, m;
    t.GetDimensions(0, w, h, m);
    float fw, fh, fm;
    t.GetDimensions(0, fw, fh, fm);
    precise float p = o[i] * 3.0 + o[i + 1];
    g[i] = p + (float)w + fw;
    GroupMemoryBarrierWithGroupSync();
    DeviceMemoryBarrier();
    AllMemoryBarrier();
    AllMemoryBarrierWithGroupSync();
    DeviceMemoryBarrierWithGroupSync();
    GroupMemoryBarrier();
    o[i] = g[63 - i] + h + fh;
}
