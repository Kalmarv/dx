// An interface with three methods called from different call sites, one through a register-indexed array: the
// operand order of `fcall fp#[array][call site]` and the call site count of `dcl_interface`.
// fxc: /T ps_5_0 /E main /Fo classes_calls.ps50.dxbc
interface IA { float3 f(float3 n); float3 g(float3 n); float h(float x); };
class A : IA { float k; float3 f(float3 n) { return n * k; } float3 g(float3 n) { return n + k; } float h(float x) { return x - k; } };
class B : IA { float3 f(float3 n) { return n; } float3 g(float3 n) { return -n; } float h(float x) { return x * 2; } };
IA a[3];
IA b;
cbuffer S { uint sel; };
float4 main(float3 n : NORMAL) : SV_Target { return float4(a[0].g(n) + a[1].f(n) + a[2].f(n) + a[sel].h(n.x) + b.h(n.y), 1); }
