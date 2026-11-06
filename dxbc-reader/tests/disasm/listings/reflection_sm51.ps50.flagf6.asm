      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB1[1], immediateIndexed
      0x0000001C: dcl_sampler s2, mode_default
      0x00000028: dcl_resource_texture2d (float,float,float,float) t3
      0x00000038: dcl_resource_texture2d (float,float,float,float) t6
      0x00000048: dcl_input_ps linear v1.xy
      0x00000054: dcl_output o0.xyzw
      0x00000060: dcl_temps 2
   0  0x00000068: sample_indexable(texture2d)(float,float,float,float) r0.xyzw, v1.xyxx, t3.xyzw, s2
   1  0x00000094: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t6.xyzw, s2
   2  0x000000C0: mad o0.xyzw, r0.xyzw, cb1[0].xyzw, r1.xyzw
   3  0x000000E8: ret 
