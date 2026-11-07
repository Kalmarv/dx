ps_4_0
dcl_globalFlags refactoringAllowed | enableMinimumPrecision
dcl_constantbuffer CB0[2], immediateIndexed
dcl_sampler s0, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_input_ps linear v1.xy {min16f}
dcl_input_ps linear v2.xyzw {min16f}
dcl_output o0.xyzw {min16f}
dcl_temps 2
sample r0.xyzw, v1.xyxx {min16f}, t0.xyzw, s0
mul r0.xyzw {min16f}, r0.yxzw {def32 as min16f}, v2.yxzw {min16f}
mul r1.xyzw {min16f}, r0.xyzw {min16f}, cb0[0].yxzw {min16f}
mad r0.xyzw {min16f}, r0.yxzw {min16f}, cb0[0].xyzw {min16f}, cb0[1].xyzw {def32 as min16f}
add o0.xyzw {min16f}, |r1.xyzw {min16f}|, r0.xyzw {min16f}
ret 
