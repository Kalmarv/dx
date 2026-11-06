// A ray tracing library compiled by dxc 1.5.2010 (GitHub release v1.5.2010, dxc_2020_10-22.zip, sha256
// b691f63778f470ebeb94874426779b2f60685fc8711adf1b1f9f01535d9b67f8) with -T lib_6_3 -Fo matrix_lib15.dxil. That dxc
// leaves the high-level `class.matrix.*` structs in the library's buffer types (dxc 1.6 and later write lowered
// `hostlayout.*` types instead), so each matrix field of a structured buffer and a constant buffer is a struct the
// listing prints as its matrix type, and a matrix array of one level prints without its length, as dxc 1.9.2609 does.
// generate.py does not rebuild it: it has no build line for the pinned dxc, which would write the lowered types.
StructuredBuffer<float4x4> m : register(t0);
struct S { float4x4 a; float2x3 b[2]; };
StructuredBuffer<S> s : register(t2);
ConstantBuffer<S> c : register(b0);
cbuffer K : register(b1) { float3x4 k; row_major float2x2 kk[3]; };
RWStructuredBuffer<float4> o : register(u0);
export float4 f(uint i) { return m[i][0] + s[i].a[1] + float4(s[i].b[1][0], 0) + c.a[2] + k[0].xyzz + kk[1][0].xyxy; }
[shader("compute")][numthreads(1,1,1)] void main(uint i : SV_DispatchThreadID) { o[i] = f(i); }
