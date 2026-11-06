      ps_5_0
      dcl_globalFlags refactoringAllowed
      dcl_resource_texture2dms(4) (float,float,float,float) t0
      dcl_output o0.xyzw
      dcl_temps 1
   0: resinfo_indexable(texture2dms)(float,float,float,float)_uint r0.xy, l(0), t0.xyzw
   1: utof o0.yz, r0.xxyx
   2: sampleinfo o0.x, rasterizer.x
   3: mov o0.w, l(4.000000)
   4: ret 
