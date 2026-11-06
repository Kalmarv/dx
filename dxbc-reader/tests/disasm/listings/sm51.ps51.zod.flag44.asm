      ps_5_1
      dcl_globalFlags refactoringAllowed | skipOptimization
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
#line 22 "C:\dx-fixtures\sm51.hlsl"
   0: mov r0.x, l(7)
   1: and r0.x, r0.x, v2.x
   2: mov r1.xyzw, CB1[r0.x + 0][0].xyzw  // r1.x <- m.color.x; r1.y <- m.color.y; r1.z <- m.color.z; r1.w <- m.color.w
   3: mov r0.x, CB1[r0.x + 0][1].x  // r0.x <- m.tex

#line 23
   4: mov r0.y, l(3)
   5: and r0.y, r0.y, CB0[2][4].x
   6: sample r2.xyzw, v1.xyxx, T1[r0.x + 0].xyzw { nonuniform }, S0[r0.y + 1]
   7: mul r1.xyzw, r1.xyzw, r2.xyzw  // r1.x <- c.x; r1.y <- c.y; r1.z <- c.z; r1.w <- c.w

#line 24
   8: mov r0.y, l(0)
   9: sample r2.xyzw, v1.xyxx, T0[4].xyzw, S0[r0.y + 1]
  10: add r1.xyzw, r1.xyzw, r2.xyzw

#line 25
  11: ftou r2.xyzw, v0.xyyy
  12: ftou r3.xyzw, v0.xyyy
  13: ld_uav_typed r3.xyzw, r3.xyzw, U0[0].xyzw
  14: mul r3.xyzw, r3.xyzw, l(0.500000, 0.500000, 0.500000, 0.500000)
  15: add r3.xyzw, r1.xyzw, r3.xyzw
  16: store_uav_typed U0[0].xyzw, r2.xyzw, r3.xyzw

#line 26
  17: mov r0.y, l(1)
  18: and r0.y, r0.y, v2.x
  19: mov r2.x, l(0)
  20: mov r2.y, l(0)
  21: atomic_iadd U1[r0.y + 1], r2.xyxx, l(1)

#line 27
  22: mov r1.xyzw, r1.xyzw  // r1.x <- o.c.x; r1.y <- o.c.y; r1.z <- o.c.z; r1.w <- o.c.w

#line 28
  23: mov r0.y, l(255)
  24: and r0.x, r0.y, r0.x  // r0.x <- o.stencil

#line 29
  25: mov o0.xyzw, r1.xyzw
  26: mov oStencilRef, r0.x
  27: ret 
