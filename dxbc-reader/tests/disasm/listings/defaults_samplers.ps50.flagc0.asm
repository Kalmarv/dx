ps_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[2], immediateIndexed
dcl_sampler s0, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_output o0.xyzw
dcl_temps 1
sample_indexable(texture2d)(float,float,float,float) r0.xyzw, cb0[1].xyxx, t0.xyzw, s0
add o0.xyzw, r0.xyzw, cb0[0].xyzw
ret 
