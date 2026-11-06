      ps_5_0
      dcl_globalFlags refactoringAllowed
      dcl_constantbuffer CB1[1], immediateIndexed
      dcl_sampler s2, mode_default
      dcl_resource_texture2d (float,float,float,float) t3
      dcl_resource_texture2d (float,float,float,float) t6
      dcl_input_ps linear v1.xy
      dcl_output o0.xyzw
      dcl_temps 2
   0: sample_indexable(texture2d)(float,float,float,float) r0.xyzw, v1.xyxx, t3.xyzw, s2
   1: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t6.xyzw, s2
   2: mad o0.xyzw, r0.xyzw, cb1[0].xyzw, r1.xyzw
   3: ret 
