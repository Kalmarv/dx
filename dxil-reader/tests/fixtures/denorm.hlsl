// dxc: -T ps_6_2 -E main -denorm any -Fo denorm.any.ps.dxil
// dxc: -T ps_6_2 -E main -denorm preserve -Fo denorm.preserve.ps.dxil
// dxc: -T ps_6_2 -E main -denorm ftz -Fo denorm.ftz.ps.dxil
// dxc: -T ps_6_2 -E main -Fo denorm.default.ps.dxil
// Float arithmetic whose denormal handling the compiler states as a function attribute (Shader Model 6.2 and later). Compiled
// with dxc -T ps_6_2 -E main and -denorm any, preserve or ftz (denorm.any.ps.dxil, denorm.preserve.ps.dxil, denorm.ftz.ps.dxil),
// and without the option (denorm.default.ps.dxil).
float4 main(float4 a : A, float4 b : B) : SV_Target { return a * b + a; }
