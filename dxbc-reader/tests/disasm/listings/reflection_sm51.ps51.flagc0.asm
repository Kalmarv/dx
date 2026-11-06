ps_5_1
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[1:1][3], immediateIndexed, space=2
dcl_sampler S0[2:2], mode_default, space=3
dcl_resource_texture2d (float,float,float,float) T0[3:3], space=1
dcl_resource_texture2d (float,float,float,float) T1[4:7], space=1
dcl_input_ps linear v1.xy
dcl_output o0.xyzw
dcl_temps 2
sample r0.xyzw, v1.xyxx, T0[3].xyzw, S0[2]
and r1.x, CB0[1][2].x, l(0x00000003)
sample r1.xyzw, v1.xyxx, T1[r1.x + 4].xyzw, S0[2]
mad o0.xyzw, r0.xyzw, CB0[1][0].xyzw, r1.xyzw
ret 
