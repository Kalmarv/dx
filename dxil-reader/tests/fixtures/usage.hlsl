// dxc: -T ps_6_0 -E main -Fo usage.ps.dxil
float4 main(float4 uv : TEXCOORD0, float2 b : TEXCOORD1, float4 d : COLOR) : SV_Target { return float4(uv.xy, b.x, d.w); }
