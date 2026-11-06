// A /Zi compute program with no input or output registers to name, so no initial-locations block before its first
// `#line`.
// fxc: /T cs_5_0 /E main /Zi /Fo zi_compute.cs50.zi.dxbc
RWTexture2D<float4> u : register(u0);
[numthreads(1, 1, 1)]
void main()
{
    u[uint2(0, 0)] = -123;
    u[uint2(1, 0)] = 7;
}
