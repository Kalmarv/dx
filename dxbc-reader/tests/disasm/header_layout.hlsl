// The reflection header's layout of nested and empty structures (where a blank line separates members), default values
// longer than one line, and an output signature whose masks the program does not all write; a vertex program with
// user clip planes.
// fxc: /T vs_5_0 /E main /Fo header_layout.vs50.dxbc
struct E { };
struct In { float2 p; int q; };
struct S { float a; In i; float b; E e; int c; In j; };
cbuffer C : register(b0) { S s; float after; In first; E empty; float4 tail; };
cbuffer K : register(b1) { float4 plane0; float4 plane1; float4 plane2; };
float4x3 m = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 };
float2 pair = { 0.5, -0.25 };
float3 three = { 1.5, 2.5, 3.5 };
StructuredBuffer<S> sb : register(t0);
struct O { float3 n : NORMAL; float4 p : SV_Position; float4 unused : UNUSED; };

[clipplanes(plane0, plane1, plane2)]
O main(float4 p : POSITION, float3 n : NORMAL)
{
    O o;
    o.p = p * s.a * after * first.p.x * tail * sb[0].b * sb[1].j.q + float4(mul(p, m), pair.x) * three.y;
    o.n = n;
    o.unused.xy = pair;
    return o;
}
