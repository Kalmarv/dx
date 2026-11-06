ps_4_0
dcl_constantbuffer CB1[3], immediateIndexed
dcl_constantbuffer CB2[3], immediateIndexed
dcl_sampler s0, mode_default
dcl_sampler s2, mode_default
dcl_resource_texture2d (float,float,float,float) t1
dcl_resource_texturecube (float,float,float,float) t3
dcl_input_ps linear v0.xy
dcl_output o0.xyzw
dcl_temps 4
sample r0.xyzw, v0.xyxx, t1.xyzw, s2
itof r1.xyzw, cb1[0].xxxx
mul r0.xyzw, r0.xyzw, r1.xyzw
sample r1.xyzw, v0.xyyx, t3.xyzw, s0
utof r2.xyzw, cb1[1].yyyy
mul r1.xyzw, r1.xyzw, r2.xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
ine r1.x, l(0, 0, 0, 0), cb1[2].x
mul r2.xyzw, r0.xyzw, cb1[2].yyyy
add r2.xyzw, r2.xyzw, cb2[2].xyzw
mov r3.xyzw, -cb2[0].xyzw
add r0.xyzw, r0.xyzw, r3.xyzw
movc o0.xyzw, r1.xxxx, r2.xyzw, r0.xyzw
ret 
