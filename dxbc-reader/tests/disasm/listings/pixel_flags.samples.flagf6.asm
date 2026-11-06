      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_resource_texture2dms(4) (float,float,float,float) t0
      0x0000001C: dcl_output o0.xyzw
      0x00000028: dcl_temps 1
   0  0x00000030: resinfo_indexable(texture2dms)(float,float,float,float)_uint r0.xy, l(0x00000000), t0.xyzw
   1  0x00000054: utof o0.yz, r0.xxyx
   2  0x00000068: sampleinfo o0.x, rasterizer.x
   3  0x00000078: mov o0.w, l(0x40800000)
   4  0x0000008C: ret 
