0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[2], immediateIndexed
0x0000001C: dcl_sampler s0, mode_default
0x00000028: dcl_resource_texture2d (float,float,float,float) t0
0x00000038: dcl_output o0.xyzw
0x00000044: dcl_temps 1
0x0000004C: sample_indexable(texture2d)(float,float,float,float) r0.xyzw, cb0[1].xyxx, t0.xyzw, s0
0x0000007C: add o0.xyzw, r0.xyzw, cb0[0].xyzw
0x0000009C: ret 
