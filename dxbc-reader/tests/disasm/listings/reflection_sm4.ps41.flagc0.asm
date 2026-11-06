ps_4_1
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[17], immediateIndexed
dcl_constantbuffer CB2[2], immediateIndexed
dcl_sampler s0, mode_default
dcl_sampler s4, mode_comparison
dcl_resource_texture2d (float,float,float,float) t0
dcl_resource_texture2darray (float,float,float,float) t3
dcl_input_ps linear v1.xy
dcl_output o0.xyzw
dcl_temps 3
mul r0.xyz, cb0[11].xyzx, cb0[13].xyzx
mad r0.xyz, cb0[5].zzzz, cb0[6].xyzx, r0.xyzx
sample_c_lz r0.w, v1.xyxx, t0.xxxx, s4, cb0[6].z
mad r0.xyz, cb0[16].xxxx, r0.wwww, r0.xyzx
mov r1.xy, v1.xyxx
mov r1.z, l(0x3f800000)
sample r1.xyzw, r1.xyzx, t3.xyzw, s0
sample r2.xyzw, v1.xyxx, t0.xyzw, s0
mad r1.xyzw, r2.xyzw, cb2[0].xyzw, r1.xyzw
add r0.xyz, r0.xyzx, r1.xyzx
mul r2.xyzw, r0.yyyy, cb0[1].xyzw
mad r2.xyzw, cb0[0].xyzw, r0.xxxx, r2.xyzw
mad r0.xyzw, cb0[2].xyzw, r0.zzzz, r2.xyzw
itof r1.x, cb0[7].x
add r1.x, r1.x, cb0[6].w
utof r1.y, cb2[1].x
add r1.x, r1.y, r1.x
add r1.x, r1.x, cb0[8].w
add r1.x, r1.x, r1.w
mad o0.xyzw, cb0[3].xyzw, r1.xxxx, r0.xyzw
ret 
