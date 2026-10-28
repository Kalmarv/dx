Texture2D<float> t : register(t0);
SamplerComparisonState s : register(s0);
float4 main(float2 uv : UV) : SV_Target { return t.SampleCmp(s, uv, 0.5); }
