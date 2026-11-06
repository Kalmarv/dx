0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[10], dynamicIndexed
0x0000001C: dcl_sampler s0, mode_default
0x00000028: dcl_resource_texture2d (float,float,float,float) t0
0x00000038: dcl_input_ps linear v0.xyz
0x00000044: dcl_input_ps linear v1.xy
0x00000050: dcl_output o0.xyzw
0x0000005C: dcl_temps 5
//
// Initial variable locations:
//   v0.x <- nrm.x; v0.y <- nrm.y; v0.z <- nrm.z; 
//   v1.x <- uv.x; v1.y <- uv.y; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 31 "C:\dx-fixtures\zi_scopes.hlsl"
0x00000064: mov r0.xyzw, l(0,0,0,0)  // r0.x <- acc.x; r0.y <- acc.y; r0.z <- acc.z; r0.w <- wsum
0x00000084: mov r1.x, l(0)  // r1.x <- i
0x00000098: loop 
0x0000009C:   ige r1.y, r1.x, cb0[9].y
0x000000BC:   breakc_nz r1.y

#line 13
0x000000C8:   dp3 r1.y, v0.xyzx, cb0[r1.x + 1].xyzx  // r1.y <- d

#line 14
0x000000F0:   lt r1.z, l(0.000000), r1.y
0x0000010C:   mul r1.w, r1.y, cb0[9].x
0x0000012C:   movc r1.y, r1.z, r1.w, -r1.y  // r1.y <- <inner return value>

#line 20
0x00000154:   lt r1.z, l(0.250000), r1.y
0x00000170:   if_nz r1.z

#line 21
0x0000017C:     mul r2.xyz, r1.yyyy, cb0[r1.x + 1].xyzx  // r2.x <- l.c.x; r2.y <- l.c.y; r2.z <- l.c.z
0x000001A4:   else 

#line 23
0x000001A8:     add r1.z, -r1.y, l(1.000000)
0x000001C8:     mul r2.xyz, r1.zzzz, v0.xyzx  // r2.x <- l.c.x; r2.y <- l.c.y; r2.z <- l.c.z
0x000001E4:   endif 

#line 13
0x000001E8:   dp3 r1.z, r2.xyzx, v0.xyzx  // r1.z <- d

#line 14
0x00000204:   lt r1.w, l(0.000000), r1.z
0x00000220:   mul r2.w, r1.z, cb0[9].x
0x00000240:   movc r1.z, r1.w, r2.w, -r1.z  // r1.z <- <inner return value>

#line 24
0x00000268:   add r1.y, r1.z, r1.y  // r1.y <- l.w

#line 34
0x00000284:   mad r0.xyz, r2.xyzx, r1.yyyy, r0.xyzx

#line 35
0x000002A8:   add r0.w, r0.w, r1.y

#line 36
0x000002C4:   iadd r1.x, r1.x, l(1)
0x000002E0: endloop 

#line 37
0x000002E4: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t0.xyzw, s0  // r1.x <- c.x; r1.y <- c.y; r1.z <- c.z; r1.w <- c.w

#line 38
0x00000310: max r0.w, r0.w, l(0.001000)
0x0000032C: div r0.xyz, r0.xyzx, r0.wwww
0x00000348: mov r0.w, l(1.000000)
0x0000035C: mul r0.xyzw, r1.xyzw, r0.xyzw  // r0.x <- <outer return value>.x; r0.y <- <outer return value>.y; r0.z <- <outer return value>.z; r0.w <- <outer return value>.w

#line 13
0x00000378: dp3 r1.x, v0.xyzx, r0.xyzx  // r1.x <- d

#line 14
0x00000394: lt r1.y, l(0.000000), r1.x
0x000003B0: mul r1.z, r1.x, cb0[9].x
0x000003D0: movc r1.x, r1.y, r1.z, -r1.x  // r1.x <- <inner return value>

#line 44
0x000003F8: mul r1.yz, r1.xxxx, v1.xxyx

#line 31
0x00000414: mov r1.w, l(0)  // r1.w <- wsum
0x00000428: mov r2.xyzw, l(0,0,0,0)  // r2.x <- acc.x; r2.y <- acc.y; r2.z <- acc.z; r2.w <- i
0x00000448: loop 
0x0000044C:   ige r3.x, r2.w, cb0[9].y
0x0000046C:   breakc_nz r3.x

#line 13
0x00000478:   dp3 r3.x, -v0.xyzx, cb0[r2.w + 1].xyzx  // r3.x <- d

#line 14
0x000004A4:   lt r3.y, l(0.000000), r3.x
0x000004C0:   mul r3.z, r3.x, cb0[9].x
0x000004E0:   movc r3.x, r3.y, r3.z, -r3.x  // r3.x <- <inner return value>

#line 20
0x00000508:   lt r3.y, l(0.250000), r3.x
0x00000524:   if_nz r3.y

#line 21
0x00000530:     mul r3.yzw, r3.xxxx, cb0[r2.w + 1].xxyz  // r3.y <- l.c.x; r3.z <- l.c.y; r3.w <- l.c.z
0x00000558:   else 

#line 23
0x0000055C:     add r4.x, -r3.x, l(1.000000)
0x0000057C:     mul r3.yzw, r4.xxxx, -v0.xxyz  // r3.y <- l.c.x; r3.z <- l.c.y; r3.w <- l.c.z
0x0000059C:   endif 

#line 13
0x000005A0:   dp3 r4.x, r3.yzwy, -v0.xyzx  // r4.x <- d

#line 14
0x000005C0:   lt r4.y, l(0.000000), r4.x
0x000005DC:   mul r4.z, r4.x, cb0[9].x
0x000005FC:   movc r4.x, r4.y, r4.z, -r4.x  // r4.x <- <inner return value>

#line 24
0x00000624:   add r3.x, r3.x, r4.x  // r3.x <- l.w

#line 34
0x00000640:   mad r2.xyz, r3.yzwy, r3.xxxx, r2.xyzx

#line 35
0x00000664:   add r1.w, r1.w, r3.x

#line 36
0x00000680:   iadd r2.w, r2.w, l(1)
0x0000069C: endloop 

#line 37
0x000006A0: sample_indexable(texture2d)(float,float,float,float) r3.xyzw, r1.yzyy, t0.xyzw, s0  // r3.x <- c.x; r3.y <- c.y; r3.z <- c.z; r3.w <- c.w

#line 38
0x000006CC: max r1.y, r1.w, l(0.001000)
0x000006E8: div r2.xyz, r2.xyzx, r1.yyyy
0x00000704: mov r2.w, l(1.000000)
0x00000718: mul r2.xyzw, r3.xyzw, r2.xyzw  // r2.x <- <outer return value>.x; r2.y <- <outer return value>.y; r2.z <- <outer return value>.z; r2.w <- <outer return value>.w

#line 45
0x00000734: mul r1.xyzw, r1.xxxx, r2.xyzw
0x00000750: mad o0.xyzw, r0.xyzw, cb0[0].xyzw, r1.xyzw
0x00000778: ret 
