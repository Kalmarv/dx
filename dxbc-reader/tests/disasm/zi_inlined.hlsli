// Included by zi_inlined.hlsl: inlined code from a second file.
float3 fold(float3 v, float k)
{
    float3 r = v * k;
    r = r + frac(r * 0.5);
    return r;
}
