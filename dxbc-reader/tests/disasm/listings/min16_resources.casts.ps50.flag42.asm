ps_5_0
dcl_globalFlags refactoringAllowed | enableMinimumPrecision
dcl_sampler s1, mode_comparison
dcl_resource_texture2d (float,float,float,float) t3
dcl_uav_raw u1
dcl_input_ps linear v0.xy
dcl_input_ps linear v0.z {min16f}
dcl_input_ps constant v1.x {min16u}
dcl_input_ps linear v2.xy {min16f}
dcl_output o0.xyzw
dcl_temps 4
mov r0.x, v1.x {min16u as def32}
imm_atomic_iadd r1.x, u1, l(0), r0.x
iadd r2.x {min16u}, v1.x {min16u}, l(1) {def32 as min16u}
mov r2.x, r2.x {min16u as def32}
imm_atomic_cmp_exch r0.x, u1, l(4), r0.x, r2.x
utof r1.y, r1.x
utof r1.z, r0.x
sample_c_indexable(texture2d)(float,float,float,float) r1.x, v0.xyxx, t3.xxxx, s1, v0.z {min16f}
gather4_c_indexable(texture2d)(float,float,float,float) r0.xyzw, v0.xyxx, t3.xyzw, s1.x, v0.z {min16f}
mov r1.w, l(0)
add r0.xyzw, r0.xyzw, r1.xyzw
eval_sample_index r3.xy {min16f}, v2.xyxx {min16f}, l(1)
add r0.xyzw, r0.xyzw, r3.xyxy {min16f as def32}
eval_centroid r3.xy {min16f}, v2.xyxx {min16f}
add o0.xyzw, r0.xyzw, r3.xyxy {min16f as def32}
ret 
