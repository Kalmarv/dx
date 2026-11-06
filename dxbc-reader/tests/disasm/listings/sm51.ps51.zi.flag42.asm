ps_5_1
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[2:2][5], immediateIndexed, space=0
dcl_constantbuffer CB1[0:7][2], dynamicIndexed, space=1
dcl_sampler S0[1:4], mode_default, space=3
dcl_resource_texture2d (float,float,float,float) T0[4:4], space=0
dcl_resource_texture2d (float,float,float,float) T1[0:*], space=2
dcl_uav_typed_texture2d_rov (float,float,float,float) U0[0:0], space=0
dcl_uav_structured U1[1:2], 4, space=4
dcl_input_ps_siv linear noperspective v0.xy, position
dcl_input_ps linear v1.xy
dcl_input_ps constant v2.x
dcl_output o0.xyzw
dcl_output oStencilRef
dcl_temps 4
//
// Initial variable locations:
//   v0.x <- p.pos.x; v0.y <- p.pos.y; v0.z <- p.pos.z; v0.w <- p.pos.w; 
//   v1.x <- p.uv.x; v1.y <- p.uv.y; 
//   v2.x <- p.id; 
//   oStencilRef <- <main return value>.stencil; 
//   o0.x <- <main return value>.c.x; o0.y <- <main return value>.c.y; o0.z <- <main return value>.c.z; o0.w <- <main return value>.c.w
//
#line 26 "C:\dx-fixtures\sm51.hlsl"
and r0.xy, v2.xxxx, l(7, 1, 0, 0)

#line 23
and r0.z, CB0[2][4].x, l(3)
mov r0.w, CB1[r0.x + 0][1].x
sample r1.xyzw, v1.xyxx, T1[r0.w + 0].xyzw { nonuniform }, S0[r0.z + 1]

#line 24
sample r2.xyzw, v1.xyxx, T0[4].xyzw, S0[1]
mad r1.xyzw, r1.xyzw, CB1[r0.x + 0][0].xyzw, r2.xyzw  // r1.x <- c.x; r1.y <- c.y; r1.z <- c.z; r1.w <- c.w

#line 25
ftou r2.xyzw, v0.xyyy
ld_uav_typed r3.xyzw, r2.xwww, U0[0].xyzw
mad r3.xyzw, r3.xyzw, l(0.500000, 0.500000, 0.500000, 0.500000), r1.xyzw
store_uav_typed U0[0].xyzw, r2.xyzw, r3.xyzw

#line 26
atomic_iadd U1[r0.y + 1], l(0, 0, 0, 0), l(1)

#line 28
and oStencilRef, l(255), CB1[r0.x + 0][1].x

#line 29
mov o0.xyzw, r1.xyzw
ret 
