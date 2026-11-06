// Debug information naming values of every kind of type fxc records: typedefs, arrays of them, a structure with a
// base, a class with overloaded methods, a structure with a static member and a method.
// fxc: /T ps_5_0 /E main /Zi /Fo zi_types.ps50.zi.dxbc
typedef float3 Triple;
typedef Triple Corners[3];
struct Base { float4 a : A; float4 b : B; };
struct Derived : Base { float3 t : T; float4 c : C; };
class Light
{
    float3 dir;
    float3 color;
    float3 shade(float3 n) { return color * saturate(dot(n, dir)); }
    float3 shade(float3 n, float k) { return shade(n) * k; }
};
struct Counter
{
    static const int limit = 4;
    float value;
    float twice;
    float get() { return value * twice; }
};
static Counter counter = { 4.25, 2.0 };
cbuffer K : register(b0) { Light light; float gain; };
float4 main(Derived input, Corners corners : CORNER) : SV_Target
{
    Triple n = normalize(input.t + corners[1]);
    float3 c = light.shade(n, gain) + light.shade(corners[2]);
    return float4(c, 1) * input.c + input.a * counter.get() + input.b * Counter::limit;
}
