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
and r0.xy, v2.xxxx, l(0x00000007, 0x00000001, 0x00000000, 0x00000000)
and r0.z, CB0[2][4].x, l(0x00000003)
mov r0.w, CB1[r0.x + 0][1].x
sample r1.xyzw, v1.xyxx, T1[r0.w + 0].xyzw { nonuniform }, S0[r0.z + 1]
sample r2.xyzw, v1.xyxx, T0[4].xyzw, S0[1]
mad r1.xyzw, r1.xyzw, CB1[r0.x + 0][0].xyzw, r2.xyzw
ftou r2.xyzw, v0.xyyy
ld_uav_typed r3.xyzw, r2.xwww, U0[0].xyzw
mad r3.xyzw, r3.xyzw, l(0x3f000000, 0x3f000000, 0x3f000000, 0x3f000000), r1.xyzw
store_uav_typed U0[0].xyzw, r2.xyzw, r3.xyzw
atomic_iadd U1[r0.y + 1], l(0x00000000, 0x00000000, 0x00000000, 0x00000000), l(0x00000001)
and oStencilRef, l(0x000000ff), CB1[r0.x + 0][1].x
mov o0.xyzw, r1.xyzw
ret 
