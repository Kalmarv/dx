0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[6], immediateIndexed
0x0000001C: dcl_sampler s0, mode_default
0x00000028: dcl_resource_texture2d (float,float,float,float) t0
0x00000038: dcl_input_ps linear v1.xy
0x00000044: dcl_input_ps linear v2.xyz
0x00000050: dcl_output o0.xyzw
0x0000005C: dcl_temps 3
//
// Initial variable locations:
//   v0.x <- v.pos.x; v0.y <- v.pos.y; v0.z <- v.pos.z; v0.w <- v.pos.w; 
//   v1.x <- v.uv.x; v1.y <- v.uv.y; 
//   v2.x <- v.n.x; v2.y <- v.n.y; v2.z <- v.n.z; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 4 "C:\dx-fixtures\zi_inlined.hlsli"
0x00000064: mul r0.xyz, v2.xyzx, cb0[5].xxxx  // r0.x <- r.x; r0.y <- r.y; r0.z <- r.z

#line 5
0x00000084: mul r0.xyz, r0.xyzx, l(0.500000, 0.500000, 0.500000, 0.000000)
0x000000AC: frc r0.xyz, r0.xyzx
0x000000C0: mad r0.xyz, v2.xyzx, cb0[5].xxxx, r0.xyzx  // r0.x <- r.x; r0.y <- r.y; r0.z <- r.z

#line 15 "C:\dx-fixtures\zi_inlined.hlsl"
0x000000E8: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t0.xyzw, s0  // r1.x <- c.x; r1.y <- c.y; r1.z <- c.z; r1.w <- c.w

#line 17
0x00000114: lt r0.w, r1.w, l(0.500000)

#line 18
0x00000130: movc r0.xz, r0.wwww, r0.zzxz, r0.xxzx  // r0.x <- f.x; r0.z <- f.z

#line 19
0x00000154: mul r1.xyz, r0.xyzx, r1.xyzx
0x00000170: mul r0.xyzw, r1.xyzw, cb0[4].xyzw  // r0.x <- <helper return value>.x; r0.y <- <helper return value>.y; r0.z <- <helper return value>.z; r0.w <- <helper return value>.w

#line 4 "C:\dx-fixtures\zi_inlined.hlsli"
0x00000190: mul r1.xyz, -v2.xyzx, cb0[5].xxxx  // r1.x <- r.x; r1.y <- r.y; r1.z <- r.z

#line 5
0x000001B4: mul r1.xyz, r1.xyzx, l(0.500000, 0.500000, 0.500000, 0.000000)
0x000001DC: frc r1.xyz, r1.xyzx
0x000001F0: mad r1.xyz, -v2.xyzx, cb0[5].xxxx, r1.xyzx  // r1.x <- r.x; r1.y <- r.y; r1.z <- r.z

#line 24 "C:\dx-fixtures\zi_inlined.hlsl"
0x0000021C: add r2.xy, v1.xyxx, v1.xyxx  // r2.x <- uv.x; r2.y <- uv.y

#line 15
0x00000238: sample_indexable(texture2d)(float,float,float,float) r2.xyzw, r2.xyxx, t0.xyzw, s0  // r2.x <- c.x; r2.y <- c.y; r2.z <- c.z; r2.w <- c.w

#line 17
0x00000264: lt r1.w, r2.w, l(0.500000)

#line 18
0x00000280: movc r1.xz, r1.wwww, r1.zzxz, r1.xxzx  // r1.x <- f.x; r1.z <- f.z

#line 19
0x000002A4: mul r2.xyz, r1.xyzx, r2.xyzx

#line 25
0x000002C0: mad r1.xyzw, r2.xyzw, cb0[4].xyzw, -r0.xyzw
0x000002EC: mad o0.xyzw, cb0[5].xxxx, r1.xyzw, r0.xyzw
0x00000314: ret 
