// dxc: -T ps_6_0 -E main -Fo usage2.ps.dxil
float4 main(float3 a : A, float b : B, float2 c : C) : SV_Target { return float4(a.y, b, c.y, 1); }
