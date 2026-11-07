// Initialized uniforms, whose values the constant table stores and Microsoft's listing writes under
// D3D_DISASM_ENABLE_DEFAULT_VALUE_PRINTS (0x02): floats of every size, an int2 loop count (an i# row), bools a
// static branch reads (b# rows), a matrix and an array (a row a register), a float4 bound past c99 (c31 in ps_2_0,
// which has 32) and uniforms with no value. generate.py's PATCHED gives the stored values infinities, NaNs, a
// denormal, -0 and the integer limits, and a register past c999 (defaults.specials.ps30).
// fxc: /T ps_3_0 /E main /D LOOPS /Fo defaults.ps30.bin
// fxc: /T vs_3_0 /E vertex /D LOOPS /Fo defaults.vs30.bin
// fxc: /T ps_2_0 /E main /Fo defaults.ps20.bin
float4 small = {0.1, 1e-8, 0.333333333, -2.5e-5};
float4 large = {123456789, 1e30, 100000, 1000000};
float4x4 transform = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
float weights[3] = {0.5, 1.5, 2.5};
#if defined(LOOPS)
float4 far : register(c123) = {65536.25, -3, 0, 4};
#else
float4 far : register(c31) = {65536.25, -3, 0, 4};
#endif
float3 unset;
sampler2D albedo;
#if defined(LOOPS)
int2 count = {3, -4};
bool flags[3] = {true, false, true};
#endif

float4 colour(float4 c)
{
    float4 r = small + large + mul(c, transform) + weights[1] + weights[2] + far + unset.xyzz;
#if defined(LOOPS)
    [loop] for (int i = 0; i < count.x; i++)
        r += c;
    [branch] if (flags[0])
        r *= 2;
    [branch] if (flags[2])
        r += 1;
#endif
    return r;
}

float4 main(float4 c : COLOR0, float2 uv : TEXCOORD0) : COLOR
{
    return colour(c) + tex2D(albedo, uv);
}

float4 vertex(float4 c : COLOR0) : POSITION
{
    return colour(c);
}
