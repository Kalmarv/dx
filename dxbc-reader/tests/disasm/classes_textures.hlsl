// Class instances that hold one texture, textures and samplers, one of each, and an array of instances: the
// `// Texture:` lines of the buffer definitions.
// fxc: /T ps_5_0 /E main /Fo classes_textures.ps50.dxbc
// fxc: /T ps_5_0 /E main /Zi /Fo classes_textures.ps50.zi.dxbc
// fxc: /T ps_5_0 /E main /Zi /Od /Fo classes_textures.ps50.zod.dxbc
interface IL { float3 f(float3 n); };
class T1 : IL { float4 k; Texture2D t; float3 f(float3 n) { return t.Load(int3(n.xy, 0)).xyz * k.xyz; } };
class S2 : IL { float4 k; SamplerState a; SamplerState b; Texture2D t; float3 f(float3 n) { return t.Sample(a, n.xy).xyz + t.Sample(b, n.yz).xyz * k.x; } };
class TS : IL { float4 k; Texture2D t; SamplerState s; float3 f(float3 n) { return t.Sample(s, n.xy).xyz * k.y; } };
class U : IL { float4 k; Texture2D t; SamplerState s; float3 f(float3 n) { return t.Sample(s, n.xy).xyz * k.w; } };
IL l;
IL m;
T1 t1;
S2 s2;
TS ts[2];
U u;
float4 main(float3 n : NORMAL) : SV_Target { return float4(l.f(n), 1); }
