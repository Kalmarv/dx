ps_4_1
dcl_globalFlags refactoringAllowed
dcl_sampler s0, mode_default
dcl_resource_texture2dms(4) (float,float,float,float) t0
dcl_resource_texturecubearray (float,float,float,float) t1
dcl_input_ps linear v0.xyz
dcl_input_ps_siv linear noperspective v1.xy, position
dcl_input_ps_sgv constant v2.x, sampleIndex
dcl_output o0.xyzw
dcl_temps 2
ftoi r0.xy, v1.xyxx
mov r0.zw, l(0,0,0,0)
ldms r0.xyzw, r0.xyzw, t0.xyzw, v2.x
mov r1.xyz, v0.xyzx
mov r1.w, l(1.000000)
gather4 r1.xyzw, r1.xyzw, t1.xyzw, s0.x
add r0.xyzw, r0.xyzw, r1.xyzw
samplepos r1.xy, t0.xyxx, v2.x
add r0.xyzw, r0.xyzw, r1.xyxy
lod r1.x, v0.xyzx, t1.x, s0
add o0.xyzw, r0.xyzw, r1.xxxx
ret 
