// fxc /Zi builds: the DBUG comment's source lines and variable locations, which the listing writes as `#line` lines
// and `// name<components>` after the lines that write a variable. The /Od builds keep one statement to a run of
// instructions, so the lines step by 1, 2 and 3 and back.
// fxc: /T ps_3_0 /E tinted /Zi /Fo debug.tinted.ps30.bin
// fxc: /T ps_2_0 /E tinted /Zi /Od /Fo debug.tinted.ps20.od.bin
// fxc: /T vs_3_0 /E stepped /Zi /Fo debug.stepped.vs30.bin
// fxc: /T vs_2_0 /E stepped /Zi /Od /Fo debug.stepped.vs20.od.bin
// fxc: /T vs_3_0 /E packed /Zi /Fo debug.packed.vs30.bin
// fxc: /T vs_2_0 /E packed /Zi /Od /Fo debug.packed.vs20.od.bin
// fxc: /T vs_3_0 /E looped /Zi /Fo debug.looped.vs30.bin
// fxc: /T vs_3_0 /E looped /Zi /Od /Fo debug.looped.vs30.od.bin
// fxc: /T ps_2_0 /E near1 /Zi /Od /Fo debug.near1.ps20.od.bin
// fxc: /T ps_2_0 /E near2 /Zi /Od /Fo debug.near2.ps20.od.bin
#include "debug.hlsli"
float4 k; float4 j; float4 m; float4 n;
float2x2 w; float4 arr[3]; int count; bool gate;
sampler2D s;

float4 tinted(float2 uv : TEXCOORD0) : COLOR0
{
    float4 c = tex2D(s, uv) * k;


    return c + j;
}

// helpers just above their callers, for lines that go back by one and two
float4 h1(float4 v) { return v * m.yzwx; }

float4 h2(float4 v) { return v + n.wxyz; }
float4 stepped(float4 p : POSITION) : POSITION
{
    float4 o = p * k;
    o = h2(o);
    o = h1(o);

    o = o + j;

    o = o * j.yzwx;


    o = o - k.zwxy;
    o = twist(o);
    o = o * m;
    o = o + n;
    return o;
}

// a struct return, a matrix, an array, and two scalars one instruction writes
struct Out { float4 pos : POSITION; float2 uv : TEXCOORD0; float s : TEXCOORD1; };
Out packed(float4 p : POSITION, float2 t : TEXCOORD0)
{
    float a = p.x * k.x;
    float b = p.y * k.y;
    float2 ab = float2(a, b);
    float2x2 mm = w * a;
    float vals[2] = { a + 1, b + 2 };
    Out o;
    o.pos = p * j + arr[1];
    o.uv = mul(ab, mm) + t;
    o.s = vals[0] * vals[1];
    return o;
}

float4 looped(float4 p : POSITION) : POSITION
{
    float4 o = p;
    [loop] for (int i = 0; i < count; i++) o += arr[2] * i;
    [branch] if (gate) o = -o;
    return o;
}

// the output copied to oC0 on the signature's line, one and two lines above the statement before: no `#line`
float4 near1(float2 uv : TEXCOORD0) : COLOR0 {
    return tex2D(s, uv).x > k.x ? m : n; }
float4 near2(float2 uv : TEXCOORD0) : COLOR0 {
    float4 c = tex2D(s, uv) * k.x;
    return c.y > j.y ? c * m + n : c - j;
}
