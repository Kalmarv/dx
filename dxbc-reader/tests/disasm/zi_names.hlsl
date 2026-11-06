// The names Microsoft's disassembler gives the bytes of variables in /Zi listings: a variable of one value by its own
// name (a one-member struct, a one-component vector), a one-component vector member's `.x`, an indexable temp by
// its number and the path of its first byte unless that is the variable's first, a minimum-precision scalar's
// words for an unknown built-in, the locations after a call, and its internal errors: a static member before the
// member named, an offset past a texture in a struct, and an offset inside a double where fxc's structured-buffer
// layout differs from the debug information's.
// fxc: /T ps_5_0 /E main /Zi /Fo zi_names.ps50.zi.dxbc
// fxc: /T ps_5_0 /E main /Zi /Od /Fo zi_names.ps50.zod.dxbc
struct One { uint a; };
struct Pair { Texture2D tex; float u; };
struct Wide { float1 f1; float2 g; min16float h; };
struct Counter { static const int limit = 4; float value; float twice; float get() { return value * twice; } };
struct Objects { float2 aa; Texture2D bb[2]; float4 cc; };
struct Inner { float a; double3 b[2]; float last; };
struct Outer { float first; Inner second; float last; };
Texture2D t0 : register(t0);
Texture2D t1 : register(t1);
StructuredBuffer<Outer> outer : register(t2);
cbuffer C : register(b0) { float4 k; uint pick; float1 single; };
static Counter counter = { 4.25, 2.0 };

float helper(float x, float1 y)
{
    float r = x * y.x;
    return r > 1 ? sqrt(r) : r;
}

float4 main(float4 p : POSITION, uint id : ID, int3 b : B) : SV_Target
{
    One one; one.a = pick;
    Pair pair; pair.tex = t0; pair.u = k.x;
    Wide w; w.f1 = single; w.g = k.yz; w.h = (min16float)k.w;
    Objects q = { 10, 20, t0, t1, 30, 40, 50, 60 };
    float arr[4] = { k.x, k.y, k.z, k.w };
    float2 arr2[3] = { k.xy, k.zw, p.xy };
    float1 lone = single * 2;
    Outer o = outer[id];
    float sum = arr[id % 4] + arr2[id % 3].y + lone.x + one.a + pair.u + w.f1.x + w.g.y + w.h + counter.get();
    float r;
    [call] switch (b.x)
    {
    case 1: r = 5.f; break;
    case 2: r = p.x; break;
    default: r = 3.f; break;
    }
    sum += helper(sum, lone) + o.last + r;
    return pair.tex.Load(int3(id, 0, 0)) * sum + q.bb[0].Load(int3(0, 0, 0)) + q.cc;
}
