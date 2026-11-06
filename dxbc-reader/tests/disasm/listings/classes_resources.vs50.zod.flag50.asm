vs_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_constantbuffer CB0[2], immediateIndexed
dcl_function_body fb0
dcl_function_body fb1
dcl_function_table ft0 = {fb0}
dcl_function_table ft1 = {fb1}
dcl_interface fp0[1][1] = {ft0, ft1}
dcl_input v0.xyzw
dcl_output_siv o0.xyzw, position
dcl_temps 2
nop 
mov r0.xyzw, v0.wzyx
fcall fp0[0][0]
mov o0.xyzw, r0.xyzw
ret 
label fb0
nop 
mov r0.xyzw, r0.xyzw
ret 
label fb1
nop 
mov r1.x, this[0].y
mov r1.y, this[0].x
mul r0.xyzw, r0.wzyx, cb[r1.y + 0][r1.x + 0].xyzw
ret 
