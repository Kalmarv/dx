// A hull and a domain program whose patch-constant structure holds a min16float. fxc then writes the 32-byte
// signature records (ISG1/OSG1) and the patch-constant signature as a PSG1 part with no PCSG. With -D PLAIN the
// min16float members are float and fxc writes the usual PCSG: the twin the lifted output is compared against.
// Compiled with Microsoft fxc 10.0.26100.0:
//   fxc -T hs_5_0 -E hs_main min16_patch.hlsl -Fo min16_patch.hs.dxbc
//   fxc -T ds_5_0 -E ds_main min16_patch.hlsl -Fo min16_patch.ds.dxbc
//   fxc -T hs_5_0 -E hs_main -D PLAIN min16_patch.hlsl -Fo min16_patch.plain.hs.dxbc
//   fxc -T ds_5_0 -E ds_main -D PLAIN min16_patch.hlsl -Fo min16_patch.plain.ds.dxbc
#ifdef PLAIN
typedef float3 narrow3;
typedef float4 narrow4;
#else
typedef min16float3 narrow3;
typedef min16float4 narrow4;
#endif

struct VS_OUT { float4 pos : POSITION; narrow3 col : COLOR0; };
struct HS_CP { float4 pos : POSITION; narrow3 col : COLOR0; };
struct HS_PC { float edges[3] : SV_TessFactor; float inside : SV_InsideTessFactor; narrow4 pc : PCDATA; };
struct DS_OUT { float4 pos : SV_Position; narrow4 col : COLOR0; };

HS_PC pcf(InputPatch<VS_OUT, 3> ip, uint id : SV_PrimitiveID) {
    HS_PC o;
    o.edges[0] = 2; o.edges[1] = 2; o.edges[2] = 2; o.inside = 2;
    o.pc = narrow4(ip[0].col, 1);
    return o;
}

[domain("tri")]
[partitioning("integer")]
[outputtopology("triangle_cw")]
[outputcontrolpoints(3)]
[patchconstantfunc("pcf")]
HS_CP hs_main(InputPatch<VS_OUT, 3> ip, uint i : SV_OutputControlPointID) {
    HS_CP o;
    o.pos = ip[i].pos;
    o.col = ip[i].col;
    return o;
}

[domain("tri")]
DS_OUT ds_main(HS_PC pc, float3 uvw : SV_DomainLocation, const OutputPatch<HS_CP, 3> op) {
    DS_OUT o;
    o.pos = op[0].pos * uvw.x + op[1].pos * uvw.y + op[2].pos * uvw.z;
    o.col = narrow4(op[0].col, 1) * pc.pc;
    return o;
}
