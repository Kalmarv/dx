ps_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[2], immediateIndexed
dcl_input_ps linear v0.xyzw
dcl_input_ps linear v1.xyzw
dcl_input_ps linear v2.xyz
dcl_input_ps linear v3.xyzw
dcl_input_ps linear v5.xyz
dcl_input_ps linear v6.xyz
dcl_output o0.xyzw
dcl_temps 2
//
// Initial variable locations:
//   v0.x <- input.a.x; v0.y <- input.a.y; v0.z <- input.a.z; v0.w <- input.a.w; 
//   v1.x <- input.b.x; v1.y <- input.b.y; v1.z <- input.b.z; v1.w <- input.b.w; 
//   v2.x <- input.t.x; v2.y <- input.t.y; v2.z <- input.t.z; 
//   v3.x <- input.c.x; v3.y <- input.c.y; v3.z <- input.c.z; v3.w <- input.c.w; 
//   v4.x <- corners[0].x; v4.y <- corners[0].y; v4.z <- corners[0].z; 
//   v5.x <- corners[1].x; v5.y <- corners[1].y; v5.z <- corners[1].z; 
//   v6.x <- corners[2].x; v6.y <- corners[2].y; v6.z <- corners[2].z; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 26 "C:\dx-fixtures\zi_types.hlsl"
add r0.xyz, v2.xyzx, v5.xyzx
dp3 r0.w, r0.xyzx, r0.xyzx
rsq r0.w, r0.w
mul r0.xyz, r0.wwww, r0.xyzx  // r0.x <- n.x; r0.y <- n.y; r0.z <- n.z

#line 12
dp3_sat r0.x, r0.xyzx, cb0[0].xyzx
mul r0.xyz, r0.xxxx, cb0[1].xyzx  // r0.x <- <Light::shade return value>.x; r0.y <- <Light::shade return value>.y; r0.z <- <Light::shade return value>.z
dp3_sat r0.w, v6.xyzx, cb0[0].xyzx
mul r1.xyz, r0.wwww, cb0[1].xyzx  // r1.x <- <Light::shade return value>.x; r1.y <- <Light::shade return value>.y; r1.z <- <Light::shade return value>.z

#line 27
mad r0.xyz, r0.xyzx, cb0[1].wwww, r1.xyzx  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z

#line 28
mov r0.w, l(0x3f800000)
mul r1.xyzw, v0.xyzw, l(0x41080000, 0x41080000, 0x41080000, 0x41080000)
mad r0.xyzw, r0.xyzw, v3.xyzw, r1.xyzw
mad o0.xyzw, v1.xyzw, l(0x40800000, 0x40800000, 0x40800000, 0x40800000), r0.xyzw
ret 
