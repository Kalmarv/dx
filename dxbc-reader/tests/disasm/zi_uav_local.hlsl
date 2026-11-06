// A local copy of an array of UAVs: its location in the debug information is the UAV range itself, which Microsoft's
// disassembler names whole, as the instructions name the UAV, by the variable alone: `U1 <- local` (dxc's
// rwstructured-buffer counter test).
// fxc: /T ps_5_1 /E main /Zi /Od /Fo zi_uav_local.ps51.zod.dxbc
RWStructuredBuffer<uint> buffers[5] : register(u1);
float4 main(uint idx : COLOR) : SV_TARGET
{
    RWStructuredBuffer<uint> local[5] = buffers;
    local[0].IncrementCounter();
    return local[1][idx];
}
