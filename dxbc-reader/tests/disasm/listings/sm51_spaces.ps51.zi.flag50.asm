ps_5_1
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[1:3][2], dynamicIndexed, space=2
dcl_sampler S0[2:5], mode_default, space=3
dcl_resource_texture2d (float,float,float,float) T0[0:*], space=1
dcl_uav_structured U0[0:0], 4, space=4
dcl_input_ps linear v0.xy
dcl_input_ps constant v1.x
dcl_output o0.xyzw
dcl_temps 2
and r0.x, v1.x, l(3)
mov r0.y, v1.x
sample r0.xyzw, v0.xyxx, T0[r0.y + 0].xyzw { nonuniform }, S0[r0.x + 2]
udiv null, r1.x, v1.x, l(3)
mul o0.xyzw, r0.xyzw, CB0[r1.x + 1][0].xyzw
mov r0.x, CB0[1][1].x
mov r0.y, l(0)
atomic_iadd U0[0], r0.xyxx, l(1)
ret 
