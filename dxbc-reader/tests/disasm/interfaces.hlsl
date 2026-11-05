// A pixel program with dynamic shader linkage: interfaces, classes with data and the function tables and calls the
// listing writes for them (dcl_function_body, dcl_function_table, dcl_interface, fcall, this).
// fxc: /T ps_5_0 /E main /Fo interfaces.ps50.dxbc
interface ILight { float3 shade(float3 n); };
class Sun : ILight { float3 dir; float3 color; float3 shade(float3 n) { return color * saturate(dot(n, dir)); } };
class Ambient : ILight { float3 color; float3 shade(float3 n) { return color; } };
interface IMaterial { float4 tint(float3 c); };
class Plain : IMaterial { float4 tint(float3 c) { return float4(c, 1); } };
class Tinted : IMaterial { float4 k; float4 tint(float3 c) { return float4(c, 1) * k; } };
ILight lights[2];
IMaterial material;
cbuffer Classes { Sun sun; Ambient ambient; Plain plain; Tinted tinted; };
float4 main(float3 n : NORMAL) : SV_Target {
    float3 c = 0;
    [unroll] for (int i = 0; i < 2; ++i) c += lights[i].shade(n);
    return material.tint(c);
}
