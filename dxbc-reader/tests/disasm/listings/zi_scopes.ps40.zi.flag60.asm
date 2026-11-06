0x00000000: ps_4_0
0x00000008: dcl_constantbuffer CB0[10], dynamicIndexed
0x00000018: dcl_sampler s0, mode_default
0x00000024: dcl_resource_texture2d (float,float,float,float) t0
0x00000034: dcl_input_ps linear v0.xyz
0x00000040: dcl_input_ps linear v1.xy
0x0000004C: dcl_output o0.xyzw
0x00000058: dcl_temps 5
//
// Initial variable locations:
//   v0.x <- nrm.x; v0.y <- nrm.y; v0.z <- nrm.z; 
//   v1.x <- uv.x; v1.y <- uv.y; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 31 "C:\dx-fixtures\zi_scopes.hlsl"
0x00000060: mov r0.xyzw, l(0,0,0,0)  // r0.x <- acc.x; r0.y <- acc.y; r0.z <- acc.z; r0.w <- wsum
0x00000080: mov r1.x, l(0)  // r1.x <- i
0x00000094: loop 
0x00000098:   ige r1.y, r1.x, cb0[9].y
0x000000B8:   breakc_nz r1.y

#line 13
0x000000C4:   dp3 r1.y, v0.xyzx, cb0[r1.x + 1].xyzx  // r1.y <- d

#line 14
0x000000EC:   lt r1.z, l(0.000000), r1.y
0x00000108:   mul r1.w, r1.y, cb0[9].x
0x00000128:   movc r1.y, r1.z, r1.w, -r1.y  // r1.y <- <inner return value>

#line 20
0x00000150:   lt r1.z, l(0.250000), r1.y
0x0000016C:   if_nz r1.z

#line 21
0x00000178:     mul r2.xyz, r1.yyyy, cb0[r1.x + 1].xyzx  // r2.x <- l.c.x; r2.y <- l.c.y; r2.z <- l.c.z
0x000001A0:   else 

#line 23
0x000001A4:     add r1.z, -r1.y, l(1.000000)
0x000001C4:     mul r2.xyz, r1.zzzz, v0.xyzx  // r2.x <- l.c.x; r2.y <- l.c.y; r2.z <- l.c.z
0x000001E0:   endif 

#line 13
0x000001E4:   dp3 r1.z, r2.xyzx, v0.xyzx  // r1.z <- d

#line 14
0x00000200:   lt r1.w, l(0.000000), r1.z
0x0000021C:   mul r2.w, r1.z, cb0[9].x
0x0000023C:   movc r1.z, r1.w, r2.w, -r1.z  // r1.z <- <inner return value>

#line 24
0x00000264:   add r1.y, r1.z, r1.y  // r1.y <- l.w

#line 34
0x00000280:   mad r0.xyz, r2.xyzx, r1.yyyy, r0.xyzx

#line 35
0x000002A4:   add r0.w, r0.w, r1.y

#line 36
0x000002C0:   iadd r1.x, r1.x, l(1)
0x000002DC: endloop 

#line 37
0x000002E0: sample r1.xyzw, v1.xyxx, t0.xyzw, s0  // r1.x <- c.x; r1.y <- c.y; r1.z <- c.z; r1.w <- c.w

#line 38
0x00000304: max r0.w, r0.w, l(0.001000)
0x00000320: div r0.xyz, r0.xyzx, r0.wwww
0x0000033C: mov r0.w, l(1.000000)
0x00000350: mul r0.xyzw, r1.xyzw, r0.xyzw  // r0.x <- <outer return value>.x; r0.y <- <outer return value>.y; r0.z <- <outer return value>.z; r0.w <- <outer return value>.w

#line 13
0x0000036C: dp3 r1.x, v0.xyzx, r0.xyzx  // r1.x <- d

#line 14
0x00000388: lt r1.y, l(0.000000), r1.x
0x000003A4: mul r1.z, r1.x, cb0[9].x
0x000003C4: movc r1.x, r1.y, r1.z, -r1.x  // r1.x <- <inner return value>

#line 44
0x000003EC: mul r1.yz, r1.xxxx, v1.xxyx

#line 31
0x00000408: mov r1.w, l(0)  // r1.w <- wsum
0x0000041C: mov r2.xyzw, l(0,0,0,0)  // r2.x <- acc.x; r2.y <- acc.y; r2.z <- acc.z; r2.w <- i
0x0000043C: loop 
0x00000440:   ige r3.x, r2.w, cb0[9].y
0x00000460:   breakc_nz r3.x

#line 13
0x0000046C:   dp3 r3.x, -v0.xyzx, cb0[r2.w + 1].xyzx  // r3.x <- d

#line 14
0x00000498:   lt r3.y, l(0.000000), r3.x
0x000004B4:   mul r3.z, r3.x, cb0[9].x
0x000004D4:   movc r3.x, r3.y, r3.z, -r3.x  // r3.x <- <inner return value>

#line 20
0x000004FC:   lt r3.y, l(0.250000), r3.x
0x00000518:   if_nz r3.y

#line 21
0x00000524:     mul r3.yzw, r3.xxxx, cb0[r2.w + 1].xxyz  // r3.y <- l.c.x; r3.z <- l.c.y; r3.w <- l.c.z
0x0000054C:   else 

#line 23
0x00000550:     add r4.x, -r3.x, l(1.000000)
0x00000570:     mul r3.yzw, r4.xxxx, -v0.xxyz  // r3.y <- l.c.x; r3.z <- l.c.y; r3.w <- l.c.z
0x00000590:   endif 

#line 13
0x00000594:   dp3 r4.x, r3.yzwy, -v0.xyzx  // r4.x <- d

#line 14
0x000005B4:   lt r4.y, l(0.000000), r4.x
0x000005D0:   mul r4.z, r4.x, cb0[9].x
0x000005F0:   movc r4.x, r4.y, r4.z, -r4.x  // r4.x <- <inner return value>

#line 24
0x00000618:   add r3.x, r3.x, r4.x  // r3.x <- l.w

#line 34
0x00000634:   mad r2.xyz, r3.yzwy, r3.xxxx, r2.xyzx

#line 35
0x00000658:   add r1.w, r1.w, r3.x

#line 36
0x00000674:   iadd r2.w, r2.w, l(1)
0x00000690: endloop 

#line 37
0x00000694: sample r3.xyzw, r1.yzyy, t0.xyzw, s0  // r3.x <- c.x; r3.y <- c.y; r3.z <- c.z; r3.w <- c.w

#line 38
0x000006B8: max r1.y, r1.w, l(0.001000)
0x000006D4: div r2.xyz, r2.xyzx, r1.yyyy
0x000006F0: mov r2.w, l(1.000000)
0x00000704: mul r2.xyzw, r3.xyzw, r2.xyzw  // r2.x <- <outer return value>.x; r2.y <- <outer return value>.y; r2.z <- <outer return value>.z; r2.w <- <outer return value>.w

#line 45
0x00000720: mul r1.xyzw, r1.xxxx, r2.xyzw
0x0000073C: mad o0.xyzw, r0.xyzw, cb0[0].xyzw, r1.xyzw
0x00000764: ret 
