0x00000000: vs_4_0
0x00000008: dcl_constantbuffer CB0[5], immediateIndexed
0x00000018: dcl_input v0.xyz
0x00000024: dcl_input v1.xy
0x00000030: dcl_output_siv o0.xyzw, position
0x00000040: dcl_output o1.xy
0x0000004C: dcl_temps 1
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; 
//   v1.x <- uv.x; v1.y <- uv.y; 
//   o1.x <- uv.x; o1.y <- uv.y; 
//   o0.x <- <vs return value>.x; o0.y <- <vs return value>.y; o0.z <- <vs return value>.z; o0.w <- <vs return value>.w
//
#line 9 "C:\dx-fixtures\level9.hlsl"
0x00000054: mul o1.xy, v1.xyxx, cb0[4].xyxx
0x00000074: itof r0.w, l(1)
0x00000088: mov r0.xyz, v0.xyzx
0x0000009C: dp4 o0.x, r0.xyzw, cb0[0].xyzw
0x000000BC: dp4 o0.y, r0.xyzw, cb0[1].xyzw
0x000000DC: dp4 o0.z, r0.xyzw, cb0[2].xyzw
0x000000FC: dp4 o0.w, r0.xyzw, cb0[3].xyzw
0x0000011C: ret 
