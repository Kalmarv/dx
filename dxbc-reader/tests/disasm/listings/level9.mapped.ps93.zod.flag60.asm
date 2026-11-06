0x00000000: ps_4_0
0x00000008: dcl_constantbuffer CB1[3], immediateIndexed
0x00000018: dcl_constantbuffer CB2[3], immediateIndexed
0x00000028: dcl_sampler s0, mode_default
0x00000034: dcl_sampler s2, mode_default
0x00000040: dcl_resource_texture2d (float,float,float,float) t1
0x00000050: dcl_resource_texturecube (float,float,float,float) t3
0x00000060: dcl_input_ps linear v0.xy
0x0000006C: dcl_output o0.xyzw
0x00000078: dcl_temps 4
//
// Initial variable locations:
//   v0.x <- uv.x; v0.y <- uv.y; 
//   o0.x <- <mapped return value>.x; o0.y <- <mapped return value>.y; o0.z <- <mapped return value>.z; o0.w <- <mapped return value>.w
//
#line 22 "C:\dx-fixtures\level9.hlsl"
0x00000080: sample r0.xyzw, v0.xyxx, t1.xyzw, s2
0x000000A4: itof r1.xyzw, cb1[0].xxxx
0x000000BC: mul r0.xyzw, r0.xyzw, r1.xyzw
0x000000D8: sample r1.xyzw, v0.xyyx, t3.xyzw, s0
0x000000FC: utof r2.xyzw, cb1[1].yyyy
0x00000114: mul r1.xyzw, r1.xyzw, r2.xyzw
0x00000130: add r0.xyzw, r0.xyzw, r1.xyzw  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z; r0.w <- c.w

#line 23
0x0000014C: ine r1.x, l(0, 0, 0, 0), cb1[2].x
0x00000178: mul r2.xyzw, r0.xyzw, cb1[2].yyyy
0x00000198: add r2.xyzw, r2.xyzw, cb2[2].xyzw
0x000001B8: mov r3.xyzw, -cb2[0].xyzw
0x000001D4: add r0.xyzw, r0.xyzw, r3.xyzw
0x000001F0: movc o0.xyzw, r1.xxxx, r2.xyzw, r0.xyzw
0x00000214: ret 
