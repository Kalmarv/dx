ps_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_constantbuffer CB0[6], immediateIndexed
dcl_sampler s0, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_input_ps linear v1.xy
dcl_input_ps linear v2.xyz
dcl_output o0.xyzw
dcl_temps 4
//
// Initial variable locations:
//   v0.x <- v.pos.x; v0.y <- v.pos.y; v0.z <- v.pos.z; v0.w <- v.pos.w; 
//   v1.x <- v.uv.x; v1.y <- v.uv.y; 
//   v2.x <- v.n.x; v2.y <- v.n.y; v2.z <- v.n.z; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 23 "C:\dx-fixtures\zi_inlined.hlsl"
nop 
mov r0.xyz, v2.xyzx

#line 15
sample_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t0.xyzw, s0  // r1.x <- c.x; r1.y <- c.y; r1.z <- c.z; r1.w <- c.w

#line 16
nop 
mov r0.xyz, r0.xyzx
mov r0.w, cb0[5].x

#line 4 "C:\dx-fixtures\zi_inlined.hlsli"
mul r0.xyz, r0.wwww, r0.xyzx  // r0.x <- r.x; r0.y <- r.y; r0.z <- r.z

#line 5
mul r2.xyz, r0.xyzx, l(0x3f000000, 0x3f000000, 0x3f000000, 0x00000000)
frc r2.xyz, r2.xyzx
add r0.xyz, r0.xzyx, r2.xzyx  // r0.y <- r.z; r0.z <- r.y

#line 6
mov r0.xyz, r0.xyzx  // r0.x <- <fold return value>.x; r0.y <- <fold return value>.z; r0.z <- <fold return value>.y

#line 16 "C:\dx-fixtures\zi_inlined.hlsl"
mov r0.xyz, r0.xyzx  // r0.x <- f.x; r0.y <- f.z; r0.z <- f.y

#line 17
lt r0.w, r1.w, l(0x3f000000)
if_nz r0.w

#line 18
  mov r0.xy, r0.yxyy
endif 

#line 19
mul r1.xyz, r0.xzyx, r1.xyzx
mul r0.xyzw, r1.xyzw, cb0[4].xyzw  // r0.x <- <helper return value>.x; r0.y <- <helper return value>.y; r0.z <- <helper return value>.z; r0.w <- <helper return value>.w

#line 23
mov r0.xyzw, r0.xyzw  // r0.x <- a.x; r0.y <- a.y; r0.z <- a.z; r0.w <- a.w

#line 24
nop 
itof r1.xy, l(0x00000002, 0x00000002, 0x00000000, 0x00000000)
mul r1.xy, r1.xyxx, v1.xyxx
mov r2.xyz, -v2.xyzx

#line 15
sample_indexable(texture2d)(float,float,float,float) r1.xyzw, r1.xyxx, t0.xyzw, s0  // r1.x <- c.x; r1.y <- c.y; r1.z <- c.z; r1.w <- c.w

#line 16
nop 
mov r2.xyz, r2.xyzx
mov r2.w, cb0[5].x

#line 4 "C:\dx-fixtures\zi_inlined.hlsli"
mul r2.xyz, r2.wwww, r2.xyzx  // r2.x <- r.x; r2.y <- r.y; r2.z <- r.z

#line 5
mul r3.xyz, r2.xyzx, l(0x3f000000, 0x3f000000, 0x3f000000, 0x00000000)
frc r3.xyz, r3.xyzx
add r2.xyz, r2.xzyx, r3.xzyx  // r2.y <- r.z; r2.z <- r.y

#line 6
mov r2.xyz, r2.xyzx  // r2.x <- <fold return value>.x; r2.y <- <fold return value>.z; r2.z <- <fold return value>.y

#line 16 "C:\dx-fixtures\zi_inlined.hlsl"
mov r2.xyz, r2.xyzx  // r2.x <- f.x; r2.y <- f.z; r2.z <- f.y

#line 17
lt r2.w, r1.w, l(0x3f000000)
if_nz r2.w

#line 18
  mov r2.xy, r2.yxyy
endif 

#line 19
mul r1.xyz, r1.xyzx, r2.xzyx
mul r1.xyzw, r1.xyzw, cb0[4].xyzw  // r1.x <- <helper return value>.x; r1.y <- <helper return value>.y; r1.z <- <helper return value>.z; r1.w <- <helper return value>.w

#line 24
mov r1.xyzw, r1.xyzw  // r1.x <- b.x; r1.y <- b.y; r1.z <- b.z; r1.w <- b.w

#line 25
mov r2.xyzw, -r0.xyzw
add r1.xyzw, r1.xyzw, r2.xyzw
mul r1.xyzw, r1.xyzw, cb0[5].xxxx
add o0.xyzw, r0.xyzw, r1.xyzw
ret 
