ps_4_0
dcl_constantbuffer CB0[6], immediateIndexed
dcl_sampler s0, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_input_ps linear v1.xy
dcl_input_ps linear v2.xyz
dcl_output o0.xyzw
dcl_temps 3
mul r0.xyz, v2.xyzx, cb0[5].xxxx
mul r0.xyz, r0.xyzx, l(0.500000, 0.500000, 0.500000, 0.000000)
frc r0.xyz, r0.xyzx
mad r0.xyz, v2.xyzx, cb0[5].xxxx, r0.xyzx
sample r1.xyzw, v1.xyxx, t0.xyzw, s0
lt r0.w, r1.w, l(0.500000)
movc r0.xz, r0.wwww, r0.zzxz, r0.xxzx
mul r1.xyz, r0.xyzx, r1.xyzx
mul r0.xyzw, r1.xyzw, cb0[4].xyzw
mul r1.xyz, -v2.xyzx, cb0[5].xxxx
mul r1.xyz, r1.xyzx, l(0.500000, 0.500000, 0.500000, 0.000000)
frc r1.xyz, r1.xyzx
mad r1.xyz, -v2.xyzx, cb0[5].xxxx, r1.xyzx
add r2.xy, v1.xyxx, v1.xyxx
sample r2.xyzw, r2.xyxx, t0.xyzw, s0
lt r1.w, r2.w, l(0.500000)
movc r1.xz, r1.wwww, r1.zzxz, r1.xxzx
mul r2.xyz, r1.xyzx, r2.xyzx
mad r1.xyzw, r2.xyzw, cb0[4].xyzw, -r0.xyzw
mad o0.xyzw, cb0[5].xxxx, r1.xyzw, r0.xyzw
ret 
