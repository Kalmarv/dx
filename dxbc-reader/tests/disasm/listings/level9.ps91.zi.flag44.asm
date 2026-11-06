      ps_4_0
      dcl_constantbuffer CB0[5], immediateIndexed
      dcl_sampler s0, mode_default
      dcl_resource_texture2d (float,float,float,float) t0
      dcl_input_ps linear v1.xy
      dcl_output o0.xyzw
      dcl_temps 1
//
// Initial variable locations:
//   v0.x <- pos.x; v0.y <- pos.y; v0.z <- pos.z; v0.w <- pos.w; 
//   v1.x <- uv.x; v1.y <- uv.y; 
//   o0.x <- <ps return value>.x; o0.y <- <ps return value>.y; o0.z <- <ps return value>.z; o0.w <- <ps return value>.w
//
#line 8 "C:\dx-fixtures\level9.hlsl"
   0: sample r0.xyzw, v1.xyxx, t0.xyzw, s0
   1: mad o0.xyzw, r0.xyzw, cb0[4].xyzw, v1.xyxy
   2: ret 
