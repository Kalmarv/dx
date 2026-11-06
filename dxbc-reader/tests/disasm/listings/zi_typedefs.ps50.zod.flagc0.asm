ps_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_input_ps linear v0.xyzw
dcl_output o0.xyzw
dcl_temps 4
//
// Initial variable locations:
//   v0.x <- a.x; v0.y <- a.y; v0.z <- a.z; v0.w <- a.w; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 14 "C:\dx-fixtures\zi_typedefs.hlsl"
itof r0.xy, l(0x00000002, 0x00000002, 0x00000000, 0x00000000)
mul r0.xy, r0.xyxx, v0.xyxx  // r0.x <- v1
// <internal error> unable to get type length from PDB


#line 15
itof r0.zw, l(0x00000000, 0x00000000, 0x00000001, 0x00000001)
add r0.zw, r0.zzzw, v0.zzzw  // r0.z <- v2.x; r0.w <- v2.y

#line 16
mul r1.x, v0.w, v0.x  // r1.x <- v3

#line 17
mul r1.y, v0.z, v0.y  // r1.y <- v4

#line 18
itof r1.zw, l(0x00000000, 0x00000000, 0x00000003, 0x00000003)
mul r1.zw, r1.zzzw, v0.yyyx  // r1.z <- v5.x; r1.w <- v5.y

#line 19
itof r2.xy, l(0x00000004, 0x00000004, 0x00000000, 0x00000000)
mul r2.xy, r2.xyxx, v0.wzww  // r2.x <- v6
// <internal error> unable to get type length from PDB


#line 20
itof r2.zw, l(0x00000000, 0x00000000, 0x00000005, 0x00000005)
mul r2.zw, r2.zzzw, v0.xxxz  // r2.z <- v7
// <internal error> unable to get type length from PDB


#line 21
itof r3.xy, l(0x00000006, 0x00000006, 0x00000000, 0x00000000)
mul r3.xy, r3.xyxx, v0.zxzz  // r3.x <- v8.x; r3.y <- v8.y

#line 22
add o0.x, r0.x, r1.w
add o0.y, r0.w, r2.x
add r0.x, r0.z, r0.y
add o0.z, r2.z, r0.x
add r0.x, r1.y, r1.x
add r0.x, r1.z, r0.x
add r0.x, r2.y, r0.x
add r0.x, r2.w, r0.x
mul r0.y, r3.y, r3.x
add o0.w, r0.y, r0.x
ret 
