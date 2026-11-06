ps_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[3], immediateIndexed
dcl_sampler s0, mode_default
dcl_sampler s1, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_resource_texture2d (float,float,float,float) t1
dcl_function_body fb0
dcl_function_body fb1
dcl_function_table ft0 = {fb0}
dcl_function_table ft1 = {fb1}
dcl_interface fp0[1][1] = {ft0, ft1}
dcl_input_ps linear v0.xyz
dcl_output o0.xyzw
dcl_temps 2
fcall fp0[0][0]
mov o0.xyz, r0.xyzx
mov o0.w, l(1.000000)
ret 
label fb0
mov r0.w, this[0].z
mov r1.x, this[0].w
sample_indexable(texture2d)(float,float,float,float) r0.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
ret 
label fb1
mov r0.w, this[0].y
mov r1.x, this[0].x
mul r0.xyz, v0.xyzx, cb[r1.x + 0][r0.w + 0].xyzx
ret 
