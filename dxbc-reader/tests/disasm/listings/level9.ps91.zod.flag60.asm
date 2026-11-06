0x00000000: ps_4_0
0x00000008: dcl_constantbuffer CB0[5], immediateIndexed
0x00000018: dcl_sampler s0, mode_default
0x00000024: dcl_resource_texture2d (float,float,float,float) t0
0x00000034: dcl_input_ps linear v1.xy
0x00000040: dcl_output o0.xyzw
0x0000004C: dcl_temps 1
//
// Initial variable locations:
//   v0.x <- pos.x; v0.y <- pos.y; v0.z <- pos.z; v0.w <- pos.w; 
//   v1.x <- uv.x; v1.y <- uv.y; 
//   o0.x <- <ps return value>.x; o0.y <- <ps return value>.y; o0.z <- <ps return value>.z; o0.w <- <ps return value>.w
//
#line 8 "C:\dx-fixtures\level9.hlsl"
0x00000054: sample r0.xyzw, v1.xyxx, t0.xyzw, s0
0x00000078: mul r0.xyzw, r0.xyzw, cb0[4].xyzw
0x00000098: add o0.xyzw, r0.xyzw, v1.xyxy
0x000000B4: ret 
