// dcl_globalFlags with several flags at once, which Microsoft writes in its own order (minimum precision after skipped
// optimization, all resources bound last): early depth-stencil, doubles, minimum precision, /Od, and Shader Model 5.1
// builds with /all_resources_bound. `globalflags_all.cs.dxbc` in `../fixtures` has every flag.
// fxc: /T ps_5_0 /E main /Fo global_flags.ps50.dxbc
// fxc: /T ps_5_0 /E main /Od /Fo global_flags.ps50.od.dxbc
// fxc: /T ps_5_0 /E main /D DOUBLES /Fo global_flags.doubles.ps50.dxbc
// fxc: /T ps_5_1 /E main /all_resources_bound /Fo global_flags.ps51.dxbc
// fxc: /T ps_5_1 /E main /all_resources_bound /Od /Fo global_flags.ps51.od.dxbc
StructuredBuffer<float4> s : register(t0);
cbuffer C : register(b0) { min16float4 tint; double scale; };
[earlydepthstencil] float4 main(float4 p : SV_Position) : SV_Target {
  float4 c = s[(uint)p.x] * tint;
#ifdef DOUBLES
  c.x = (float)(scale * c.x);
#endif
  return c;
}
