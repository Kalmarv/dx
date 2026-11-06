ps_5_0
dcl_globalFlags refactoringAllowed
dcl_resource_texture2dms(4) (float,float,float,float) t0
dcl_output o0.xyzw
dcl_temps 1
resinfo_indexable(texture2dms)(float,float,float,float)_uint r0.xy, l(0x00000000), t0.xyzw
utof o0.yz, r0.xxyx
sampleinfo o0.x, rasterizer.x
mov o0.w, l(0x40800000)
ret 
