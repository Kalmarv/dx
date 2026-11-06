// Arrays of class instances (`suns[3]`), one class with data and one with a texture and sampler only.
// fxc: /T ps_5_0 /E main /Fo classes_arrays.ps50.dxbc
// fxc: /T ps_5_0 /E main /Zi /Fo classes_arrays.ps50.zi.dxbc
// fxc: /T ps_5_0 /E main /Zi /Od /Fo classes_arrays.ps50.zod.dxbc
interface IL { float3 f(float3 n); };
class Sun : IL { float3 d; float3 f(float3 n) { return d * n; } };
class Sky : IL { Texture2D t; SamplerState s; float3 f(float3 n) { return t.Sample(s, n.xy).xyz; } };
IL l;
Sun suns[3];
Sky skies[2];
float4 main(float3 n : NORMAL, float4 p : SV_Position, uint i : SV_SampleIndex) : SV_Target { return float4(l.f(n), 1); }
