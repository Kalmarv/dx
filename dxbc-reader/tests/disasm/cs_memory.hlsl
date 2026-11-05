// Compute programs over thread-group memory and every kind of unordered-access view: raw and structured group-shared
// memory, typed views of each dimension, append and consume buffers, structured counters, every atomic, barriers of
// each kind and the group's ids.
// fxc: /T cs_5_0 /E main /Fo cs_memory.cs50.dxbc
// fxc: /T cs_4_0 /E main4 /Fo cs_memory.cs40.dxbc
// fxc: /T cs_4_1 /E main4 /Fo cs_memory.cs41.dxbc
struct Item { float3 p; uint id; };
RWByteAddressBuffer raw : register(u0);
RWStructuredBuffer<Item> items : register(u1);
AppendStructuredBuffer<uint> outq : register(u2);
ConsumeStructuredBuffer<uint> inq : register(u3);
RWTexture1D<int> i1 : register(u4);
RWTexture2DArray<float2> f2a : register(u5);
RWTexture3D<uint> u3 : register(u6);
RWBuffer<float4> fb : register(u7);
RWTexture1DArray<unorm float4> un : register(u8);
RWStructuredBuffer<uint> dec : register(u9);
StructuredBuffer<Item> src : register(t0);
ByteAddressBuffer rsrc : register(t1);
groupshared uint gshared[64];
groupshared float4 tile[8][8];
[numthreads(8, 8, 1)]
void main(uint3 tid : SV_DispatchThreadID, uint3 gid : SV_GroupID, uint3 lid : SV_GroupThreadID, uint flat : SV_GroupIndex) {
    gshared[flat] = tid.x;
    tile[lid.y][lid.x] = float4(src[flat].p, 1);
    GroupMemoryBarrierWithGroupSync();
    uint v = gshared[(flat + 1) & 63], old;
    InterlockedAdd(gshared[0], v, old);
    InterlockedMin(gshared[1], v);
    InterlockedMax(gshared[2], (int)v);
    InterlockedAnd(gshared[3], v);
    InterlockedOr(gshared[4], v);
    InterlockedXor(gshared[5], v);
    InterlockedExchange(gshared[6], v, old);
    InterlockedCompareExchange(gshared[7], v, old, old);
    InterlockedCompareStore(gshared[8], v, old);
    raw.InterlockedAdd(0, v);
    raw.InterlockedCompareExchange(4, v, 1, old);
    raw.InterlockedMin(8, v, old);
    InterlockedMin(i1[gid.x], -(int)v, old);
    InterlockedMax(u3[tid], v);
    DeviceMemoryBarrier();
    uint c = items.IncrementCounter();
    items[c].p = tile[lid.x][lid.y].xyz;
    items[c].id = gid.x + gid.y * 3 + gid.z;
    // a buffer may increment its counter or decrement it, not both
    dec[0] = dec.DecrementCounter();
    outq.Append(inq.Consume() + old);
    AllMemoryBarrierWithGroupSync();
    f2a[uint3(tid.xy, gid.z)] = f2a[uint3(lid.xy, 0)] + float2(c, v);
    fb[flat] = fb[flat + 1] * 2;
    un[tid.xy] = float4(1, 0, 0, 1);
    raw.Store2(flat * 8, rsrc.Load2(flat * 8) + uint2(old, c));
    GroupMemoryBarrier();
    AllMemoryBarrier();
    DeviceMemoryBarrierWithGroupSync();
    uint count, stride;
    src.GetDimensions(count, stride);
    raw.Store(512, count * stride);
}
RWStructuredBuffer<uint> out4 : register(u0);
groupshared uint shared4[256];
[numthreads(256, 1, 1)]
void main4(uint tid : SV_DispatchThreadID, uint flat : SV_GroupIndex) {
    shared4[flat] = tid;
    GroupMemoryBarrierWithGroupSync();
    out4[tid] = shared4[255 - flat];
}
