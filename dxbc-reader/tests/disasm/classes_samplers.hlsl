// Class instances that hold samplers but no texture.
// fxc: /T ps_5_0 /E main /Fo classes_samplers.ps50.dxbc
// fxc: /T ps_5_0 /E main /Zi /Fo classes_samplers.ps50.zi.dxbc
// fxc: /T ps_5_0 /E main /Zi /Od /Fo classes_samplers.ps50.zod.dxbc
interface IL { float3 f(float3 n); };
Texture2D gT;
class S1 : IL { float4 k; SamplerState s; float3 f(float3 n) { return gT.Sample(s, n.xy).xyz * k.xyz; } };
class S3 : IL { float4 k; SamplerState a, b, c; float3 f(float3 n) { return gT.Sample(a, n.xy).xyz + gT.Sample(b, n.yz).xyz + gT.Sample(c, n.zx).xyz * k.x; } };
IL l;
S1 s1;
S3 s3;
float4 main(float3 n : NORMAL) : SV_Target { return float4(l.f(n), 1); }
