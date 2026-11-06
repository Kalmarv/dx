ps_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_constantbuffer CB0[2], immediateIndexed
dcl_sampler s0, mode_default
dcl_sampler s1, mode_default
dcl_sampler s2, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_resource_texture2d (float,float,float,float) t1
dcl_resource_texture2d (float,float,float,float) t2
dcl_function_body fb0
dcl_function_body fb1
dcl_function_body fb2
dcl_function_body fb3
dcl_function_body fb4
dcl_function_body fb5
dcl_function_body fb6
dcl_function_body fb7
dcl_function_body fb8
dcl_function_body fb9
dcl_function_body fb10
dcl_function_table ft0 = {fb0}
dcl_function_table ft1 = {fb1}
dcl_function_table ft2 = {fb2}
dcl_function_table ft3 = {fb3, fb6}
dcl_function_table ft4 = {fb4, fb7}
dcl_function_table ft5 = {fb5, fb8}
dcl_function_table ft6 = {fb9}
dcl_function_table ft7 = {fb10}
dcl_interface fp0[1][1] = {ft0, ft1, ft2}
dcl_interface fp1[3][2] = {ft3, ft4, ft5}
dcl_interface fp4[1][1] = {ft6, ft7}
dcl_input_ps linear v0.xyz
dcl_output o0.xyzw
dcl_temps 4
nop 
mov r0.xyz, v0.xyzx
fcall fp0[0][0]
nop 
mov r1.xyz, v0.xyzx
fcall fp1[0][0]
add r0.xyz, r0.xyzx, r1.xyzx
nop 
mov r1.xyz, v0.zyxz
fcall fp1[2][1]
add r0.yzw, r0.zzyx, r1.zzyx
nop 
itof r0.x, l(1)
mov r0.yzw, r0.yyzw
fcall fp4[0][0]
mov o0.xyzw, r0.xyzw
ret 
label fb0
nop 
mov r0.xyz, r0.xyzx
ret 
label fb1
nop 
mov r0.w, this[0].z
mov r1.x, this[0].w
sample_indexable(texture2d)(float,float,float,float) r1.yzw, v0.xyxx, t[r0.w + 0].wxyz, s[r1.x + 0]
sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.yzyy, t[r0.w + 1].xyzw, s[r1.x + 1]
mov r0.w, this[0].y
mov r1.x, this[0].x
mul r2.xyz, r2.xyzx, cb[r1.x + 0][r0.w + 0].xyzx
add r0.xyz, r1.yzwy, r2.xyzx
ret 
label fb2
nop 
mov r0.w, this[0].z
mov r1.x, this[0].w
sample_indexable(texture2d)(float,float,float,float) r0.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
mov r0.xyz, r0.xyzx
ret 
label fb3
nop 
mov r1.xyz, r1.xyzx
ret 
label fb4
nop 
mov r0.w, this[1].z
mov r1.w, this[1].w
sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yzyy, t[r0.w + 1].xyzw, s[r1.w + 1]
mov r0.w, this[1].y
mov r1.w, this[1].x
mul r3.xyz, r3.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
add r1.xyz, r2.xyzx, r3.xyzx
ret 
label fb5
nop 
mov r0.w, this[1].z
mov r1.w, this[1].w
sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
mov r1.xyz, r1.xyzx
ret 
label fb6
nop 
mov r1.xyz, r1.xyzx
ret 
label fb7
nop 
mov r0.w, this[3].z
mov r1.w, this[3].w
sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.zyzz, t[r0.w + 0].xyzw, s[r1.w + 0]
sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yxyy, t[r0.w + 1].xyzw, s[r1.w + 1]
mov r0.w, this[3].y
mov r1.w, this[3].x
mul r3.xyz, r3.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
add r1.xyz, r2.xyzx, r3.xyzx
ret 
label fb8
nop 
mov r0.w, this[3].z
mov r1.w, this[3].w
sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.zyzz, t[r0.w + 0].xyzw, s[r1.w + 0]
mov r1.xyz, r1.xyzx
ret 
label fb9
nop 
mov r0.xyzw, r0.xyzw
ret 
label fb10
nop 
mov r1.x, this[4].y
mov r1.y, this[4].x
mul r0.xyzw, r0.wzyx, cb[r1.y + 0][r1.x + 0].xyzw
ret 
