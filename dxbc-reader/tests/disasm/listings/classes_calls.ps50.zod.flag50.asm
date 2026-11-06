ps_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_constantbuffer CB0[1], immediateIndexed
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
dcl_function_table ft0 = {fb0, fb2, fb4, fb6}
dcl_function_table ft1 = {fb1, fb3, fb5, fb7}
dcl_function_table ft2 = {fb8}
dcl_function_table ft3 = {fb9}
dcl_interface_dynamicindexed fp0[3][4] = {ft0, ft1}
dcl_interface fp3[1][1] = {ft2, ft3}
dcl_input_ps linear v0.xyz
dcl_output o0.xyzw
dcl_temps 2
nop 
mov r0.xyz, v0.xyzx
fcall fp0[0][0]
nop 
mov r0.xyz, v0.xyzx
fcall fp0[1][1]
add r0.xyz, r0.xyzx, r1.xyzx
nop 
mov r1.xyz, v0.xyzx
fcall fp0[2][2]
add r0.xyz, r0.xyzx, r1.xyzx
nop 
mov r0.w, v0.x
mov r1.x, cb0[0].x
fcall fp0[r1.x + 0][3]
add r0.xyz, r0.xyzx, r1.yyyy
nop 
mov r0.w, v0.y
fcall fp3[0][0]
add o0.xyz, r0.xyzx, r1.xxxx
itof o0.w, l(1)
ret 
label fb0
nop 
mov r1.xyz, -r0.xyzx
ret 
label fb1
nop 
mov r0.w, this[0].y
mov r1.w, this[0].x
add r1.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xxxx
ret 
label fb2
nop 
mov r0.xyz, r0.xyzx
ret 
label fb3
nop 
mov r0.w, this[1].y
mov r1.w, this[1].x
mul r0.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xxxx
ret 
label fb4
nop 
mov r1.xyz, r1.xyzx
ret 
label fb5
nop 
mov r0.w, this[2].y
mov r1.w, this[2].x
mul r1.xyz, r1.xyzx, cb[r1.w + 0][r0.w + 0].xxxx
ret 
label fb6
nop 
itof r1.z, l(2)
mul r1.y, r0.w, r1.z
ret 
label fb7
nop 
mov r1.z, this[r1.x + 0].y
mov r1.x, this[r1.x + 0].x
mov r1.x, -cb[r1.x + 0][r1.z + 0].x
add r1.y, r0.w, r1.x
ret 
label fb8
nop 
itof r1.y, l(2)
mul r1.x, r0.w, r1.y
ret 
label fb9
nop 
mov r1.y, this[3].y
mov r1.z, this[3].x
mov r1.y, -cb[r1.z + 0][r1.y + 0].x
add r1.x, r0.w, r1.y
ret 
