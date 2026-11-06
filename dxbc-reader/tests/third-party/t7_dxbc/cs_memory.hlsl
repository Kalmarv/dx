// dxbc: main cs_5_0
// Group-shared memory raw and structured, barriers, atomics on group memory
// and on raw, structured and typed UAVs, a counter, byte-address loads and
// stores of several widths, a structured element with an array reached at a
// computed offset, and the sizes of UAVs and buffers.
struct Bin
{
	uint count;
	float weight;
	uint slots[4];
};

struct Pair
{
	float a;
	uint b;
};

cbuffer Params : register(b0)
{
	uint binCount;
	uint pick;
	float scale;
	int bias;
};

RWByteAddressBuffer raw : register(u0);
RWStructuredBuffer<Bin> bins : register(u1);
RWTexture2D<uint> counts : register(u2);
RWStructuredBuffer<Pair> pairs : register(u3);
RWTexture2DArray<float4> layers : register(u4);
StructuredBuffer<Pair> source : register(t0);
ByteAddressBuffer table : register(t1);
Buffer<float4> typed : register(t2);

groupshared uint sharedRaw[64];
groupshared Pair sharedPairs[64];

[numthreads(8, 4, 1)]
void main(uint3 tid : SV_DispatchThreadID, uint3 gtid : SV_GroupThreadID, uint gi : SV_GroupIndex)
{
	sharedRaw[gi] = tid.x * 3 + tid.y;
	sharedPairs[gi].a = source[gi].a * scale;
	sharedPairs[gi].b = source[gi].b + pick;
	GroupMemoryBarrierWithGroupSync();

	uint neighbor = sharedRaw[(gi + 1) & 31];
	Pair p = sharedPairs[(gi + pick) & 31];
	InterlockedAdd(sharedRaw[gi & 7], neighbor);
	uint before;
	InterlockedMax(sharedRaw[(gi + 3) & 31], p.b, before);
	InterlockedMin(sharedPairs[gi & 15].b, neighbor);
	GroupMemoryBarrierWithGroupSync();

	uint slot = (gi + pick) & 3;
	InterlockedAdd(bins[gi & 3].slots[slot], 1);
	InterlockedOr(bins[0].count, 1u << (gi & 31));
	uint old;
	InterlockedExchange(bins[1].count, neighbor, old);
	InterlockedCompareExchange(bins[2].slots[1], 0, gi, old);
	InterlockedCompareStore(bins[3].slots[2], 7, gi);
	bins[gi & 3].weight = p.a + (float)before;
	bins[gi & 3].slots[slot] = old ^ neighbor;

	raw.InterlockedAdd(gi * 4, neighbor);
	raw.InterlockedXor(128 + gi * 4, p.b);
	uint4 four = table.Load4(gi * 16);
	uint2 two = raw.Load2(256 + gi * 8);
	raw.Store3(512 + gi * 12, four.xyz + two.xxy);
	raw.Store(1024 + gi * 4, sharedRaw[gi] + (uint)bias);

	InterlockedAnd(counts[tid.xy], neighbor | 0xF0);
	counts[tid.xy + uint2(16, 0)] = counts[tid.xy] + four.w;

	uint w, h, n;
	layers.GetDimensions(w, h, n);
	uint pairCount, stride;
	pairs.GetDimensions(pairCount, stride);
	uint typedCount;
	typed.GetDimensions(typedCount);
	float4 t = typed[gi % typedCount];
	layers[uint3(tid.xy % uint2(w, h), gi % n)] = t * (float)pairCount + layers[uint3(tid.xy, 0)];

	uint at = pairs.IncrementCounter();
	pairs[at % pairCount].a = t.x + (float)binCount;
	pairs[at % pairCount].b = sharedRaw[gi] + stride;
}
