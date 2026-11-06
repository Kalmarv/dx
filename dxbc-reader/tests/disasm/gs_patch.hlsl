// A geometry program whose input is a patch of control points: `dcl_inputprimitive patch2`.
// fxc: /T gs_5_0 /E main /Fo gs_patch.gs50.dxbc
struct V { float4 p : SV_Position; float2 t : TEXCOORD; };
[maxvertexcount(2)]
void main(InputPatch<V, 2> ip, inout LineStream<V> s)
{
    s.Append(ip[0]);
    s.Append(ip[1]);
}
