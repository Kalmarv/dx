vs_4_0
dcl_constantbuffer CB0[5], immediateIndexed
dcl_input v0.xyz
dcl_input v1.xy
dcl_output_siv o0.xyzw, position
dcl_output o1.xy
dcl_temps 1
//
// Initial variable locations:
//   v0.x <- p.x; v0.y <- p.y; v0.z <- p.z; 
//   v1.x <- uv.x; v1.y <- uv.y; 
//   o1.x <- uv.x; o1.y <- uv.y; 
//   o0.x <- <vs return value>.x; o0.y <- <vs return value>.y; o0.z <- <vs return value>.z; o0.w <- <vs return value>.w
//
#line 9 "C:\dx-fixtures\level9.hlsl"
mul o1.xy, v1.xyxx, cb0[4].xyxx
itof r0.w, l(1)
mov r0.xyz, v0.xyzx
dp4 o0.x, r0.xyzw, cb0[0].xyzw
dp4 o0.y, r0.xyzw, cb0[1].xyzw
dp4 o0.z, r0.xyzw, cb0[2].xyzw
dp4 o0.w, r0.xyzw, cb0[3].xyzw
ret 
