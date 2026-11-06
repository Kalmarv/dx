// Pixel programs of each Direct3D 9 profile: every sampler type and sampling form (projected, biased, gradient and
// level), derivatives, discard, the face and position registers, depth and multiple colour outputs, partial
// precision, predication and dynamic flow control.
// fxc: /T ps_2_0 /E simple /Fo pixel.simple.ps20.bin
// fxc: /T ps_2_a /E main /D DERIVATIVES /Fo pixel.ps2a.bin
// fxc: /T ps_2_b /E main /Fo pixel.ps2b.bin
// fxc: /T ps_3_0 /E main /D SM3 /D DERIVATIVES /Fo pixel.ps30.bin
// fxc: /T ps_3_0 /E main /D SM3 /D DERIVATIVES /D FLOW /Fo pixel.flow.ps30.bin
// fxc: /T ps_3_0 /E constant /Fo pixel.constant.ps30.bin
// fxc: /T ps_3_0 /E main /D SM3 /D DERIVATIVES /Gpp /Fo pixel.pp.ps30.bin
// fxc: /T ps_3_0 /E twosets /Fo pixel.twosets.ps30.bin
sampler2D albedo : register(s0);
samplerCUBE sky : register(s1);
sampler3D volume : register(s2);
sampler1D ramp : register(s3);
sampler2D shadow : register(s4);
float4 tint;
float4 weights[4];
int steps;
float alphaRef;

// centroid interpolation, derivatives (ps_2_a), the face and position registers are not in every profile
#ifdef SM3
#define CENTROID centroid
#else
#define CENTROID
#endif
struct In { float4 uv : TEXCOORD0; float3 n : TEXCOORD1; CENTROID float4 c : COLOR0; float4 proj : TEXCOORD2; };
struct Out { float4 a : COLOR0; float4 b : COLOR1; float depth : DEPTH; };

float4 simple(float2 uv : TEXCOORD0, float4 c : COLOR0) : COLOR0 {
    float4 t = tex2D(albedo, uv) * c;
    clip(t.a - 0.5);
    return t * tint + texCUBE(sky, float3(uv, 1));
}

float4 constant() : COLOR0 { return float4(0.25, 0.5, 1, 1); }

#ifdef SM3
Out main(In i, float face : VFACE, float2 vpos : VPOS) {
#else
Out main(In i) {
#endif
    Out o;
    float4 t = tex2D(albedo, i.uv.xy);
    t += tex2Dproj(shadow, i.proj);
    t += tex2Dbias(albedo, float4(i.uv.xy, 0, i.uv.w));
    t *= texCUBE(sky, reflect(normalize(i.n), float3(0, 0, 1)));
    t += tex3D(volume, i.uv.xyz) * tex1D(ramp, i.uv.z).x;
#ifdef DERIVATIVES
    float2 dx = ddx(i.uv.xy), dy = ddy(i.uv.xy);
    t = lerp(t, i.c, saturate(dot(dx, dy)));
#ifdef SM3
    t += tex2Dgrad(albedo, i.uv.zw, dx, dy) + tex2Dlod(albedo, float4(i.uv.wz, 0, 2));
#endif
#endif
    clip(t.a - alphaRef);
#ifdef SM3
    t.rgb *= face > 0 ? 1 : 0.5;
    t.rg += frac(vpos / 8);
#endif
    half4 h = (half4)t * (half)0.5;
    o.a = t * tint + h;
#ifdef FLOW
    [loop] for (int k = 0; k < steps; k++) {
        [branch] if (o.a.x > weights[k].x) break;
        o.a += weights[k] * tex2Dlod(albedo, float4(i.uv.xy * k, 0, 0));
    }
#else
    [flatten] if (o.a.y > 0.5) o.a.z = 1 / o.a.y;
#endif
    o.b = float4(pow(abs(t.rgb), 2.2), exp2(t.a));
    o.depth = i.proj.z / i.proj.w;
    return o;
}

// one uniform in two register sets: `limit` as a loop count takes i0, and as a float a c# register
int2 limit;
float4 twosets(float4 c : COLOR0) : COLOR0
{
    float4 r = 0;
    [loop] for (int i = 0; i < limit.x; i++) r += c;
    return r * limit.y;
}
