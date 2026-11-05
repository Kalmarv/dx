// Pixel programs that read resources of every dimension with every sample and load instruction, an immediate constant
// buffer indexed by a register, flow control (if, loop, switch, discard) and integer and bit arithmetic.
// fxc: /T ps_4_0 /E main /Fo ps_sampling.ps40.dxbc
// fxc: /T ps_4_1 /E main /D SM41 /Fo ps_sampling.ps41.dxbc
// fxc: /T ps_5_0 /E main /D SM41 /D SM5 /Fo ps_sampling.ps50.dxbc
// fxc: /T ps_5_0 /E main /D SM41 /D SM5 /Gfp /Fo ps_sampling.gfp.dxbc
Texture1D<float4> t1 : register(t0);
Texture1DArray<float4> t1a : register(t1);
Texture2D<float4> t2 : register(t2);
Texture2DArray<float4> t2a : register(t3);
Texture3D<float4> t3 : register(t4);
TextureCube<float4> tc : register(t5);
Texture2DMS<float4, 4> tms : register(t6);
Buffer<int2> tb : register(t7);
Texture2D<uint2> tu : register(t8);
Texture2DMSArray<snorm float4> tmsa : register(t9);
Texture2D<unorm float4> tun : register(t10);
#ifdef SM41
TextureCubeArray<float4> tca : register(t11);
#endif
SamplerState ss : register(s0);
SamplerComparisonState sc : register(s1);
SamplerState ss2 : register(s3);
cbuffer P { float4 k; int4 n; uint4 u; };
static const float4 table[6] = { float4(1, 0, 0, 1), float4(0, 1, 0, 1), float4(0, 0, 1, 1), float4(0.5, 0.25, 1e-8, -1e20), float4(3.402823466e+38, -0, 1.0/3.0, 100000), float4(asfloat(0x7f800000), asfloat(0xff800000), asfloat(1), asfloat(0x80000001)) };
static const uint ints[5] = { 1, 0xffffffff, 0x80000000, 12345678, 10000 };

struct PIn { float4 pos : SV_Position; float4 uv : TEXCOORD0; nointerpolation int4 i : TEXCOORD1; noperspective float2 np : TEXCOORD2; centroid float c : TEXCOORD3; bool front : SV_IsFrontFace; uint prim : SV_PrimitiveID; };
struct POut { float4 a : SV_Target0; int4 b : SV_Target2; uint c : SV_Target3; float d : SV_Depth; };

POut main(PIn p) {
    POut o;
    float4 c = t1.Sample(ss, p.uv.x) + t1a.SampleLevel(ss, p.uv.xy, 2) + t2.Sample(ss, p.uv.xy, int2(1, -2));
    c += t2a.SampleBias(ss, p.uv.xyz, k.x) + t3.SampleGrad(ss, p.uv.xyz, ddx(p.uv.xyz), ddy(p.uv.xyz));
    c += tc.Sample(ss2, p.uv.xyz);
    c.x += t2.SampleCmp(sc, p.uv.xy, k.y) + t2.SampleCmpLevelZero(sc, p.uv.zw, k.z, int2(3, 4));
    c += tms.Load(p.i.xy, p.i.z) + tmsa.Load(p.i.xyz, 1) + tun.Load(int3(p.i.xy, 0), int2(-1, 1));
    c += t2.Load(int3(p.i.xy, p.i.w)) + t3.Load(p.i);
    uint w, h, levels;
    t2.GetDimensions(1, w, h, levels);
    float fw, fh;
    tun.GetDimensions(fw, fh);
    c.xy += float2(w, h) * levels + float2(fw, fh);
    c += table[p.i.x % 6] * table[n.y];
#ifdef SM41
    c += tca.SampleLevel(ss, p.uv, 0);
    c += t2.CalculateLevelOfDetail(ss, p.uv.xy);
#endif
#ifdef SM5
    c += t2.Gather(ss, p.uv.xy) + t2.GatherRed(ss, p.uv.xy, int2(1, 1)) + t2.GatherGreen(ss, p.uv.xy, p.i.zw);
    c += t2.GatherCmp(sc, p.uv.xy, k.w) + t2.GatherCmpBlue(sc, p.uv.xy, k.x, p.i.xy);
    uint status;
    c += t2.Sample(ss, p.uv.xy, int2(0, 0), 1.5, status);
    c.w += CheckAccessFullyMapped(status);
    c.x += ddx_fine(p.uv.x) + ddy_coarse(p.uv.y);
#endif
    int2 b = tb.Load(p.i.x) + (int2)tu.Load(int3(p.i.yz, 0));
    [loop] for (int i = 0; i < n.x; ++i) {
        if (c.x > float(i)) break;
        c = c * 0.5 + 0.25;
        if (i == n.z) continue;
        b += i;
    }
    switch (n.w) {
    case 0: c.x = 1; break;
    case 3: c.y = 2;
    case 7: c.z = 3; break;
    default: c.w = -4; break;
    }
    if (c.w < -1000) discard;
    uint x = u.x ^ asuint(c.y);
    x = (x << 3) | (x >> u.y) & ~u.z;
    x += ints[p.prim % 5];
#ifdef SM5
    x += reversebits(x) + countbits(x) + firstbithigh(x) + firstbitlow(x) + firstbithigh((int)x);
    x += f32tof16(c.x) + (uint)f16tof32(x);
#endif
    x = (x / u.w) + (x % (u.w + 1));
    int sx = (int)x;
    sx = (sx >> 2) * n.x + min(sx, n.y) - max(sx, -n.z) + abs(sx) - sx / n.w;
    o.a = p.front ? c : -c.wzyx;
    o.a = isnan(o.a) ? 0 : (isinf(o.a) ? 1 : o.a);
    o.a += sin(c) * cos(c.yxwz) + rsqrt(abs(c)) + exp2(c) + log2(abs(c)) + frac(c) + round(c) + floor(c) + ceil(c) + trunc(c);
    o.a = saturate(o.a + p.np.xyxy * p.c + mad(c, k, o.a)) + rcp(c) + sqrt(abs(c));
    o.b = int4(b, sx, (int)p.uv.z);
    o.c = x + (uint)p.uv.w;
    o.d = saturate(p.pos.z + c.x * 1e-6);
    return o;
}
