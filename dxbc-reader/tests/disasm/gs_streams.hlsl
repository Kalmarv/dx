// Geometry programs: adjacency input, several output streams, instancing and the system values a geometry program
// writes (render target array index, viewport array index, primitive id).
// fxc: /T gs_5_0 /E main /Fo gs_streams.gs50.dxbc
// fxc: /T gs_4_0 /E points /Fo gs_streams.gs40.dxbc
// fxc: /T gs_5_0 /E main /Zi /Fo gs_streams.gs50.zi.dxbc
// fxc: /T gs_5_0 /E main /Zi /Od /Fo gs_streams.gs50.zod.dxbc
// fxc: /T gs_4_0 /E points /Zi /Fo gs_streams.gs40.zi.dxbc
// fxc: /T gs_4_0 /E points /Zi /Od /Fo gs_streams.gs40.zod.dxbc
struct V { float4 pos : SV_Position; float2 uv : TEXCOORD0; };
struct G { float4 pos : SV_Position; float2 uv : TEXCOORD0; uint layer : SV_RenderTargetArrayIndex; uint vp : SV_ViewportArrayIndex; uint prim : SV_PrimitiveID; };
struct S { float4 data : DATA; };
[maxvertexcount(6)]
[instance(3)]
void main(triangleadj V input[6], uint prim : SV_PrimitiveID, uint inst : SV_GSInstanceID, inout PointStream<G> s, inout PointStream<S> s1) {
    for (uint i = 0; i < 6; i += 2) {
        G g;
        g.pos = input[i].pos;
        g.uv = input[i].uv;
        g.layer = inst;
        g.vp = i / 2;
        g.prim = prim;
        s.Append(g);
    }
    s.RestartStrip();
    S d;
    d.data = input[1].pos + input[3].pos;
    s1.Append(d);
    s1.RestartStrip();
}
[maxvertexcount(4)]
void points(point V input[1], inout LineStream<V> s) {
    V a = input[0];
    s.Append(a);
    a.pos.x += 1;
    s.Append(a);
    s.RestartStrip();
}
