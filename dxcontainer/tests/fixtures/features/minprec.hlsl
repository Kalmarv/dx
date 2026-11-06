// dxc: -T ps_6_0 -E main -Fo minprec.dxil
min16float4 main(min16float4 a : A) : SV_Target { return a * a; }
