0x00000000: ps_4_0
0x00000008: dcl_constantbuffer CB0[5], immediateIndexed
0x00000018: dcl_sampler s0, mode_default
0x00000024: dcl_sampler s1, mode_default
0x00000030: dcl_resource_texture2d (float,float,float,float) t0
0x00000040: dcl_resource_texture2d (float,float,float,float) t1
0x00000050: dcl_input_ps linear v0.xy
0x0000005C: dcl_input_ps linear v1.xyzw
0x00000068: dcl_output o0.xyzw
0x00000074: dcl_temps 2
//
// Initial variable locations:
//   v0.x <- uv.x; v0.y <- uv.y; 
//   v1.x <- c.x; v1.y <- c.y; v1.z <- c.z; v1.w <- c.w; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 10 "C:\dx-fixtures\level9_ps.hlsl"
0x0000007C: sample r0.xyzw, v0.xyxx, t0.xyzw, s0
0x000000A0: mad r0.xyzw, r0.xyzw, v1.xyzw, cb0[2].xyzw  // r0.x <- x.x; r0.y <- x.y; r0.z <- x.z; r0.w <- x.w

#line 12
0x000000C8: lt r1.x, r0.w, cb0[4].x
0x000000E8: discard_nz r1.x

#line 11
0x000000F4: mul r1.xy, v0.xyxx, cb0[0].xyxx
0x00000114: sample r1.xyzw, r1.xyxx, t1.xyzw, s1  // r1.x <- y.x; r1.y <- y.y; r1.z <- y.z; r1.w <- y.w

#line 13
0x00000138: add r1.xyzw, -r0.xyzw, r1.xyzw
0x00000158: mad r0.xyzw, cb0[3].xxxx, r1.xyzw, r0.xyzw
0x00000180: mad o0.xyzw, cb0[1].xyzw, cb0[0].xyzw, r0.xyzw
0x000001AC: ret 
