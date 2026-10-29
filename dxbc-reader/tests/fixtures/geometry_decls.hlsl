// A geometry program: a triangle in, a triangle strip of at most four vertices out. Compiled with
// fxc /T gs_5_0 /E main (geometry_decls.gs.dxbc, listing geometry_decls.gs.lst): its declarations carry the input
// primitive, the output topology and the vertex count.
struct V { float4 pos : SV_Position; float2 uv : TEXCOORD0; };
[maxvertexcount(4)]
void main(triangle V input[3], inout TriangleStream<V> s) {
    s.Append(input[0]);
    s.Append(input[1]);
    s.Append(input[2]);
    V extra = input[0];
    extra.pos.x += 1;
    s.Append(extra);
}
