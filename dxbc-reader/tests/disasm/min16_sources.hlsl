// Destinations and sources of mixed precision: samples and gathers into min16, two-destination imul and udiv, a
// shift amount of each precision, bit counts, and an absolute value (whose bars hold the precision).
// fxc: /T ps_5_0 /E main /Fo min16_sources.ps50.dxbc
Texture2D<min16float4> tex : register(t0);
SamplerState smp : register(s0);
cbuffer C : register(b0) { float4 k; uint4 u; int4 s; };
min16float4 main(float4 p : TEXCOORD0, nointerpolation uint4 q : TEXCOORD1, nointerpolation min16uint4 m : TEXCOORD2) : SV_Target
{
    min16float4 t = tex.Sample(smp, p.xy);                 // sample into min16
    min16float4 g = tex.Gather(smp, p.zw);                 // gather4
    min16uint a = m.x;
    min16uint b = (a >> (min16uint)q.y) + (a << m.y);      // shift amount min16 and def32
    min16uint c = reversebits(a) + countbits(b) + firstbithigh(a);
    uint d = f32tof16(p.x) + (uint)m.z;                    // f32tof16, iadd def32 with min16 source
    min16uint e = (b * a) / (min16uint)q.z;                // imul, udiv
    min16int f = (min16int)m.w * (min16int)s.y;
    min16float h = (min16float)f16tof32(q.w);
    uint bits = (d >> 3) & 0x1f;                           // ubfe
    min16float4 r = t * g + (min16float)c + (min16float)e + h;
    r.x += (min16float)(bits + (uint)f);
    r.y = dot(r.xyz, (min16float3)p.xyz);                  // dp3 mixed
    r.z = sqrt(abs(r.z)) + rcp((min16float)k.w);
    r.w = clamp(r.w, (min16float)k.x, (min16float)k.y);
    return r;
}
