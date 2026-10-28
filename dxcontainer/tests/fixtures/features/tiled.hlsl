Texture2D<float4> t : register(t0);
SamplerState s : register(s0);
float4 main(float2 uv : UV) : SV_Target { uint st; float4 c = t.Sample(s, uv, int2(0,0), 0, st); return CheckAccessFullyMapped(st) ? c : 0; }
