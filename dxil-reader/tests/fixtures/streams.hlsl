// A geometry program writing two streams, a point per input corner to each (when several streams are used they must be
// point lists). Compiled with dxc -T gs_6_0 -E main (streams.gs.dxil). The output elements of stream 1 state their stream in
// their tail tags.
struct V { float4 pos : SV_Position; float2 uv : TEXCOORD0; };
struct P { float4 pos : SV_Position; float tag : TAG; };
[maxvertexcount(3)]
void main(triangle V input[3], inout PointStream<V> s0, inout PointStream<P> s1) {
    for (uint i = 0; i < 3; i++) { s0.Append(input[i]); }
    P p; p.pos = input[0].pos; p.tag = input[1].uv.x;
    s1.Append(p);
}
