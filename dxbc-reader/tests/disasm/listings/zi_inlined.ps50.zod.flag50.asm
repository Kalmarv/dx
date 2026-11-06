ps_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_constantbuffer CB0[6], immediateIndexed
dcl_sampler s0, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_input_ps linear v1.xy
dcl_input_ps linear v2.xyz
dcl_output o0.xyzw
dcl_temps 4
nop 
mov r0.xyz, v2.xyzx
sample_indexable(texture2d)(float,float,float,float) r1.xyzw, v1.xyxx, t0.xyzw, s0
nop 
mov r0.xyz, r0.xyzx
mov r0.w, cb0[5].x
mul r0.xyz, r0.wwww, r0.xyzx
mul r2.xyz, r0.xyzx, l(0.500000, 0.500000, 0.500000, 0.000000)
frc r2.xyz, r2.xyzx
add r0.xyz, r0.xzyx, r2.xzyx
mov r0.xyz, r0.xyzx
mov r0.xyz, r0.xyzx
lt r0.w, r1.w, l(0.500000)
if_nz r0.w
  mov r0.xy, r0.yxyy
endif 
mul r1.xyz, r0.xzyx, r1.xyzx
mul r0.xyzw, r1.xyzw, cb0[4].xyzw
mov r0.xyzw, r0.xyzw
nop 
itof r1.xy, l(2, 2, 0, 0)
mul r1.xy, r1.xyxx, v1.xyxx
mov r2.xyz, -v2.xyzx
sample_indexable(texture2d)(float,float,float,float) r1.xyzw, r1.xyxx, t0.xyzw, s0
nop 
mov r2.xyz, r2.xyzx
mov r2.w, cb0[5].x
mul r2.xyz, r2.wwww, r2.xyzx
mul r3.xyz, r2.xyzx, l(0.500000, 0.500000, 0.500000, 0.000000)
frc r3.xyz, r3.xyzx
add r2.xyz, r2.xzyx, r3.xzyx
mov r2.xyz, r2.xyzx
mov r2.xyz, r2.xyzx
lt r2.w, r1.w, l(0.500000)
if_nz r2.w
  mov r2.xy, r2.yxyy
endif 
mul r1.xyz, r1.xyzx, r2.xzyx
mul r1.xyzw, r1.xyzw, cb0[4].xyzw
mov r1.xyzw, r1.xyzw
mov r2.xyzw, -r0.xyzw
add r1.xyzw, r1.xyzw, r2.xyzw
mul r1.xyzw, r1.xyzw, cb0[5].xxxx
add o0.xyzw, r0.xyzw, r1.xyzw
ret 
