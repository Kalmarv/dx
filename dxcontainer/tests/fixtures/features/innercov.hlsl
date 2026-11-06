// dxc: -T ps_6_0 -E main -Fo innercov.dxil
float4 main(uint c : SV_InnerCoverage) : SV_Target { return c; }
