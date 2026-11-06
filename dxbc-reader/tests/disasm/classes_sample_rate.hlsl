// Class linkage in a pixel program that runs at sample frequency: the class tables come after that note.
// fxc: /T ps_5_0 /E main /Fo classes_sample_rate.ps50.dxbc
// fxc: /T ps_5_0 /E main /Zi /Fo classes_sample_rate.ps50.zi.dxbc
// fxc: /T ps_5_0 /E main /Zi /Od /Fo classes_sample_rate.ps50.zod.dxbc
interface IA { float3 f(float3 n); };
class A : IA { float k; float3 f(float3 n) { return n * k; } };
IA a; A x;
float4 main(float3 n : NORMAL, uint s : SV_SampleIndex) : SV_Target { return float4(a.f(n) * s, 1); }
