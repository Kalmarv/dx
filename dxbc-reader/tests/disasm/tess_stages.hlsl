// Hull and domain programs of each tessellator domain and partitioning: control-point phases, fork phases over arrays
// of tessellation factors, a patch-constant function that reads the output control points, and the domain programs
// that read the patch.
// fxc: /T hs_5_0 /E hs_tri /Fo tess_stages.tri.hs.dxbc
// fxc: /T hs_5_0 /E hs_quad /Fo tess_stages.quad.hs.dxbc
// fxc: /T hs_5_0 /E hs_line /Fo tess_stages.line.hs.dxbc
// fxc: /T hs_5_0 /E hs_pass /Fo tess_stages.pass.hs.dxbc
// fxc: /T ds_5_0 /E ds_tri /Fo tess_stages.tri.ds.dxbc
// fxc: /T ds_5_0 /E ds_quad /Fo tess_stages.quad.ds.dxbc
// fxc: /T ds_5_0 /E ds_line /Fo tess_stages.line.ds.dxbc
// fxc: /T hs_5_0 /E hs_tri /Zi /Fo tess_stages.tri.hs.zi.dxbc
// fxc: /T hs_5_0 /E hs_tri /Zi /Od /Fo tess_stages.tri.hs.zod.dxbc
// fxc: /T hs_5_0 /E hs_quad /Zi /Fo tess_stages.quad.hs.zi.dxbc
// fxc: /T hs_5_0 /E hs_quad /Zi /Od /Fo tess_stages.quad.hs.zod.dxbc
// fxc: /T hs_5_0 /E hs_line /Zi /Fo tess_stages.line.hs.zi.dxbc
// fxc: /T hs_5_0 /E hs_line /Zi /Od /Fo tess_stages.line.hs.zod.dxbc
// fxc: /T hs_5_0 /E hs_pass /Zi /Fo tess_stages.pass.hs.zi.dxbc
// fxc: /T hs_5_0 /E hs_pass /Zi /Od /Fo tess_stages.pass.hs.zod.dxbc
// fxc: /T ds_5_0 /E ds_tri /Zi /Fo tess_stages.tri.ds.zi.dxbc
// fxc: /T ds_5_0 /E ds_tri /Zi /Od /Fo tess_stages.tri.ds.zod.dxbc
// fxc: /T ds_5_0 /E ds_quad /Zi /Fo tess_stages.quad.ds.zi.dxbc
// fxc: /T ds_5_0 /E ds_quad /Zi /Od /Fo tess_stages.quad.ds.zod.dxbc
// fxc: /T ds_5_0 /E ds_line /Zi /Fo tess_stages.line.ds.zi.dxbc
// fxc: /T ds_5_0 /E ds_line /Zi /Od /Fo tess_stages.line.ds.zod.dxbc
struct CP { float4 p : POSITION; float3 n : NORMAL; };
cbuffer T { float4 factors; float4x4 viewProj; };
struct TriPC { float e[3] : SV_TessFactor; float i : SV_InsideTessFactor; float3 b : CENTER; };
struct QuadPC { float e[4] : SV_TessFactor; float i[2] : SV_InsideTessFactor; };
struct LinePC { float e[2] : SV_TessFactor; };

TriPC tri_pc(InputPatch<CP, 3> patch, OutputPatch<CP, 3> outp, uint id : SV_PrimitiveID) {
    TriPC o;
    [unroll] for (int k = 0; k < 3; ++k) o.e[k] = factors[k] * length(outp[k].p - patch[(k + 1) % 3].p);
    o.i = factors.w + id;
    o.b = (patch[0].p.xyz + patch[1].p.xyz + patch[2].p.xyz) / 3;
    return o;
}
[domain("tri")] [partitioning("fractional_odd")] [outputtopology("triangle_cw")] [outputcontrolpoints(3)]
[patchconstantfunc("tri_pc")] [maxtessfactor(15.0)]
CP hs_tri(InputPatch<CP, 3> patch, uint i : SV_OutputControlPointID) {
    CP o = patch[i];
    o.p.xyz += o.n * factors.x;
    return o;
}

QuadPC quad_pc(InputPatch<CP, 16> patch) {
    QuadPC o;
    [unroll] for (int k = 0; k < 4; ++k) o.e[k] = factors[k] + patch[k * 4].p.w;
    o.i[0] = factors.x;
    o.i[1] = factors.y;
    return o;
}
[domain("quad")] [partitioning("fractional_even")] [outputtopology("triangle_ccw")] [outputcontrolpoints(4)]
[patchconstantfunc("quad_pc")]
CP hs_quad(InputPatch<CP, 16> patch, uint i : SV_OutputControlPointID, uint id : SV_PrimitiveID) {
    CP o;
    o.p = patch[i * 4].p + patch[i * 4 + 3].p * id;
    o.n = patch[i].n;
    return o;
}

LinePC line_pc() {
    LinePC o;
    o.e[0] = 8;
    o.e[1] = 1;
    return o;
}
[domain("isoline")] [partitioning("pow2")] [outputtopology("line")] [outputcontrolpoints(2)]
[patchconstantfunc("line_pc")]
CP hs_line(InputPatch<CP, 2> patch, uint i : SV_OutputControlPointID) { return patch[i]; }

[domain("tri")] [partitioning("integer")] [outputtopology("point")] [outputcontrolpoints(0)]
[patchconstantfunc("tri_pc_pass")]
void hs_pass(InputPatch<CP, 3> patch) {}
TriPC tri_pc_pass(InputPatch<CP, 3> patch) {
    TriPC o;
    o.e[0] = o.e[1] = o.e[2] = patch[0].p.x;
    o.i = 1;
    o.b = patch[1].p.xyz;
    return o;
}

struct DOut { float4 pos : SV_Position; float3 n : NORMAL; };
[domain("tri")]
DOut ds_tri(TriPC pc, float3 uvw : SV_DomainLocation, const OutputPatch<CP, 3> patch) {
    DOut o;
    float4 p = patch[0].p * uvw.x + patch[1].p * uvw.y + patch[2].p * uvw.z;
    o.pos = mul(p + float4(pc.b, 0) * pc.e[1], viewProj);
    o.n = normalize(patch[0].n * uvw.x + patch[1].n * uvw.y + patch[2].n * uvw.z) * pc.i;
    return o;
}
[domain("quad")]
DOut ds_quad(QuadPC pc, float2 uv : SV_DomainLocation, const OutputPatch<CP, 4> patch, uint id : SV_PrimitiveID) {
    DOut o;
    float4 a = lerp(patch[0].p, patch[1].p, uv.x), b = lerp(patch[3].p, patch[2].p, uv.x);
    // a domain program indexes its inputs, the patch and its constants, by literals only
    o.pos = mul(lerp(a, b, uv.y) * lerp(pc.i[0], pc.i[1], (float)(id & 1)), viewProj);
    o.n = lerp(patch[1].n, patch[3].n, (float)(id & 1));
    return o;
}
[domain("isoline")]
DOut ds_line(LinePC pc, float2 uv : SV_DomainLocation, const OutputPatch<CP, 2> patch) {
    DOut o;
    o.pos = lerp(patch[0].p, patch[1].p, uv.x) * pc.e[0];
    o.n = patch[0].n;
    return o;
}
