// A pixel program that indexes an input array with a value only known at run time. Compiled with dxc -T ps_6_0 -E main
// (dynidx.ps.dxil): the element states the components that are indexed dynamically.
float4 main(float4 a[3] : A, nointerpolation uint k : K) : SV_Target { return a[k % 3]; }
