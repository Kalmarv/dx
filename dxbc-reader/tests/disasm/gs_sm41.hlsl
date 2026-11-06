// A Shader Model 4.1 geometry program: a cube-map pass writing six faces with the render target array index.
// fxc: /T gs_4_1 /E main /Fo gs_sm41.gs41.dxbc
// fxc: /T gs_4_1 /E main /Zi /Fo gs_sm41.gs41.zi.dxbc
struct G { float4 p : SV_Position; float4 c : COLOR; uint id : SV_RenderTargetArrayIndex; };
cbuffer C { float4x4 m[6]; };
[maxvertexcount(18)]
void main(triangle float4 p[3] : POSITION, inout TriangleStream<G> o) {
  for (uint f = 0; f < 6; f++) { for (uint v = 0; v < 3; v++) { G g; g.p = mul(p[v], m[f]); g.c = float4(f/6.0, v/3.0, 0, 1); g.id = f; o.Append(g); } o.RestartStrip(); }
}
