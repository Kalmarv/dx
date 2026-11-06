// Class linkage with textures and samplers in the classes, names longer than the class tables' columns, and (in the
// vertex program) interface pointers it never calls, which the buffer definitions give no offset or size.
// fxc: /T ps_5_0 /E main /Fo classes_resources.ps50.dxbc
// fxc: /T vs_5_0 /E vmain /Fo classes_resources.vs50.dxbc
interface ILight { float3 shade(float3 n); };
interface IVeryLongInterfaceNameForTestingColumnWidths { float4 g(float4 x); };
class TexLight : ILight { Texture2D t; SamplerState s; float3 shade(float3 n) { return t.Sample(s, n.xy).xyz; } };
class TexLight2 : ILight { Texture2D t; Texture2D u; SamplerState s; SamplerState s2; float4 k; float3 shade(float3 n) { return t.Sample(s, n.xy).xyz + u.Sample(s2, n.yz).xyz * k.xyz; } };
class Flat : ILight { float3 shade(float3 n) { return n; } };
class AVeryLongClassNameThatOverflowsTheNameColumnOfTheTable : IVeryLongInterfaceNameForTestingColumnWidths { float4 m; float4 g(float4 x) { return x * m; } };
class Other : IVeryLongInterfaceNameForTestingColumnWidths { float4 g(float4 x) { return x.wzyx; } };
ILight light;
ILight more[3];
IVeryLongInterfaceNameForTestingColumnWidths v;
TexLight tl;
TexLight2 tl2;
Flat flat;
AVeryLongClassNameThatOverflowsTheNameColumnOfTheTable anInstanceWithAnEvenLongerNameThanTheColumnWidth;
Other other;
float4 main(float3 n : NORMAL) : SV_Target {
    float3 c = light.shade(n) + more[0].shade(n) + more[2].shade(n.zyx);
    return v.g(float4(c, 1));
}
float4 vmain(float4 p : POSITION) : SV_Position { return v.g(p); }
