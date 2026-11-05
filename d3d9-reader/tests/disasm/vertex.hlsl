// Vertex programs of each Direct3D 9 profile: matrices and their macros, relative constant addressing, the
// transcendental macros, static and dynamic flow control, loops over integer constants, bool constants, calls, and
// sampling in a vertex program.
// fxc: /T vs_2_0 /E main /Fo vertex.vs20.bin
// fxc: /T vs_2_a /E main /Fo vertex.vs2a.bin
// fxc: /T vs_3_0 /E main /Fo vertex.vs30.bin
// fxc: /T vs_3_0 /E main /D FETCH /Fo vertex.fetch.vs30.bin
// fxc: /T vs_2_0 /E main /Gfp /Fo vertex.gfp.vs20.bin
struct Light { float3 direction; float4 colour; };
float4x4 worldViewProj;
row_major float4x3 world;
float3x3 normalMatrix;
float4 bones[48];
Light lights[3];
struct Material { float4 albedo; Light rim; float2x2 warp; };
Material material;
int count;
bool fog;
float time : register(c90);
#ifdef FETCH
sampler2D heights;
#endif

struct In { float4 pos : POSITION; float3 n : NORMAL; float2 uv : TEXCOORD0; float4 w : BLENDWEIGHT; int4 bi : BLENDINDICES; };
struct Out { float4 pos : POSITION; float4 c : COLOR0; float2 uv : TEXCOORD0; float3 n : TEXCOORD1; float f : FOG; float4 extra : TEXCOORD2; };

float4 skin(In i) {
    float4 p = 0;
    [unroll] for (int k = 0; k < 2; k++)
        p += mul(i.pos, float4x4(bones[i.bi[k] * 3], bones[i.bi[k] * 3 + 1], bones[i.bi[k] * 3 + 2], float4(0, 0, 0, 1))) * i.w[k];
    return p;
}

Out main(In i) {
    Out o;
    float4 p = skin(i);
#ifdef FETCH
    p.y += tex2Dlod(heights, float4(i.uv, 0, 0)).x;
#endif
    o.pos = mul(p, worldViewProj);
    float3 wp = mul(p, world);
    o.n = normalize(mul(i.n, normalMatrix));
    float4 c = 0;
    for (int l = 0; l < count; l++)
        c += lights[l].colour * pow(saturate(dot(o.n, -lights[l].direction)), 8);
    float s, co;
    sincos(time, s, co);
    o.c = c * float4(s, co, exp(wp.x), log(abs(wp.y) + 1));
    o.uv = i.uv * frac(time) + float2(sign(wp.z), lerp(s, co, wp.x));
    o.f = fog ? length(wp) / 100 : 0;
    o.extra = float4(cross(wp, o.n), rsqrt(abs(wp.z) + 1)) * material.albedo + material.rim.colour * dot(material.rim.direction, wp);
    o.uv = mul(o.uv, material.warp);
    o.extra = max(o.extra, min(o.extra.wzyx, 1)) * step(0.5, o.extra) + (o.extra > 0.5 ? 1 : 0);
    if (o.extra.x > 0.25) o.extra.y = 1 / o.extra.x;
    return o;
}
