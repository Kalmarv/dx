ps_4_0
dcl_constantbuffer CB1[3], immediateIndexed
dcl_constantbuffer CB2[3], immediateIndexed
dcl_sampler s0, mode_default
dcl_sampler s2, mode_default
dcl_resource_texture2d (float,float,float,float) t1
dcl_resource_texturecube (float,float,float,float) t3
dcl_input_ps linear v0.xy
dcl_output o0.xyzw
dcl_temps 3
sample r0.xyzw, v0.xyyx, t3.xyzw, s0
utof r1.x, cb1[1].y
mul r0.xyzw, r0.xyzw, r1.xxxx
sample r1.xyzw, v0.xyxx, t1.xyzw, s2
itof r2.x, cb1[0].x
mad r0.xyzw, r1.xyzw, r2.xxxx, r0.xyzw
mad r1.xyzw, r0.xyzw, cb1[2].yyyy, cb2[2].xyzw
add r0.xyzw, r0.xyzw, -cb2[0].xyzw
movc o0.xyzw, cb1[2].xxxx, r1.xyzw, r0.xyzw
ret 
