float4 main(float4 uv : TEXCOORD0, float2 b : TEXCOORD1, float4 d : COLOR) : SV_Target { return float4(uv.xy, b.x, d.w); }
