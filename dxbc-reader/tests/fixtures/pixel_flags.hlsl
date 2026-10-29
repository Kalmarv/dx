// Pixel programs whose dcl_globalFlags and size queries carry control bits. Compiled with fxc /T ps_5_0 /E main and
//   /D EARLY    (pixel_flags.early.dxbc: forced early depth-stencil),
//   /D SAMPLES  (pixel_flags.samples.dxbc: a sample count query `sampleinfo`, and a size query `resinfo_uint`),
//   /D DOUBLES  (pixel_flags.doubles.dxbc: double-precision arithmetic).
#if defined(EARLY)
[earlydepthstencil]
float4 main(float4 p : SV_Position) : SV_Target { return p; }
#elif defined(SAMPLES)
Texture2DMS<float4, 4> ms : register(t0);
float4 main(float4 p : SV_Position) : SV_Target {
    uint n = GetRenderTargetSampleCount();
    uint w, h, s;
    ms.GetDimensions(w, h, s);
    return float4(n, w, h, s);
}
#else
cbuffer C : register(b0) { double d; };
float4 main(float4 p : SV_Position) : SV_Target { return (float)(d * d + p.x); }
#endif
