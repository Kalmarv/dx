// dxbc: main cs_5_0
// Every barrier, over group memory, UAVs coherent for the group and for the
// device, with and without the group's threads; a group-shared scalar the
// compiler keeps as raw memory.
globallycoherent RWByteAddressBuffer coherent : register(u0);
RWStructuredBuffer<uint> local : register(u1);

groupshared uint counter;
groupshared uint stage[32];

[numthreads(32, 1, 1)]
void main(uint gi : SV_GroupIndex, uint3 gid : SV_GroupID)
{
	if (gi == 0)
		counter = 0;
	GroupMemoryBarrierWithGroupSync();
	uint slot;
	InterlockedAdd(counter, gi + 1, slot);
	stage[gi] = slot;
	GroupMemoryBarrier();
	local[gid.x * 32 + gi] = stage[(gi + 1) & 31];
	DeviceMemoryBarrier();
	coherent.Store(gi * 4, local[gid.x * 32 + (gi ^ 1)]);
	DeviceMemoryBarrierWithGroupSync();
	uint other = coherent.Load(((gi + 3) & 31) * 4);
	AllMemoryBarrier();
	stage[gi] = other + counter;
	AllMemoryBarrierWithGroupSync();
	local[gid.x * 32 + gi] = stage[31 - gi];
}
