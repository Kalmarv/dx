ps_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
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
dcl_function_body fb11
dcl_function_body fb12
dcl_function_body fb13
dcl_function_body fb14
dcl_function_body fb15
dcl_function_body fb16
dcl_function_body fb17
dcl_function_body fb18
dcl_function_body fb19
dcl_function_body fb20
dcl_function_body fb21
dcl_function_body fb22
dcl_function_body fb23
dcl_function_body fb24
dcl_function_body fb25
dcl_function_body fb26
dcl_function_body fb27
dcl_function_body fb28
dcl_function_body fb29
dcl_function_body fb30
dcl_function_body fb31
dcl_function_body fb32
dcl_function_body fb33
dcl_function_body fb34
dcl_function_body fb35
dcl_function_body fb36
dcl_function_body fb37
dcl_function_body fb38
dcl_function_body fb39
dcl_function_body fb40
dcl_function_body fb41
dcl_function_body fb42
dcl_function_body fb43
dcl_function_body fb44
dcl_function_body fb45
dcl_function_body fb46
dcl_function_body fb47
dcl_function_body fb48
dcl_function_body fb49
dcl_function_body fb50
dcl_function_body fb51
dcl_function_body fb52
dcl_function_body fb53
dcl_function_body fb54
dcl_function_body fb55
dcl_function_body fb56
dcl_function_body fb57
dcl_function_body fb58
dcl_function_body fb59
dcl_function_body fb60
dcl_function_body fb61
dcl_function_body fb62
dcl_function_body fb63
dcl_function_table ft0 = {fb0, fb8, fb16}
dcl_function_table ft1 = {fb1, fb9, fb17}
dcl_function_table ft2 = {fb2, fb10, fb18}
dcl_function_table ft3 = {fb3, fb11, fb19}
dcl_function_table ft4 = {fb4, fb12, fb20}
dcl_function_table ft5 = {fb5, fb13, fb21}
dcl_function_table ft6 = {fb6, fb14, fb22}
dcl_function_table ft7 = {fb7, fb15, fb23}
dcl_function_table ft8 = {fb24, fb32}
dcl_function_table ft9 = {fb25, fb33}
dcl_function_table ft10 = {fb26, fb34}
dcl_function_table ft11 = {fb27, fb35}
dcl_function_table ft12 = {fb28, fb36}
dcl_function_table ft13 = {fb29, fb37}
dcl_function_table ft14 = {fb30, fb38}
dcl_function_table ft15 = {fb31, fb39}
dcl_function_table ft16 = {fb40}
dcl_function_table ft17 = {fb41}
dcl_function_table ft18 = {fb42}
dcl_function_table ft19 = {fb43}
dcl_function_table ft20 = {fb44}
dcl_function_table ft21 = {fb45}
dcl_function_table ft22 = {fb46}
dcl_function_table ft23 = {fb47}
dcl_function_table ft24 = {fb48, fb56}
dcl_function_table ft25 = {fb49, fb57}
dcl_function_table ft26 = {fb50, fb58}
dcl_function_table ft27 = {fb51, fb59}
dcl_function_table ft28 = {fb52, fb60}
dcl_function_table ft29 = {fb53, fb61}
dcl_function_table ft30 = {fb54, fb62}
dcl_function_table ft31 = {fb55, fb63}
dcl_interface fp0[3][3] = {ft0, ft1, ft2, ft3, ft4, ft5, ft6, ft7}
dcl_interface fp3[2][2] = {ft8, ft9, ft10, ft11, ft12, ft13, ft14, ft15}
dcl_interface fp5[1][1] = {ft16, ft17, ft18, ft19, ft20, ft21, ft22, ft23}
dcl_interface fp6[2][2] = {ft24, ft25, ft26, ft27, ft28, ft29, ft30, ft31}
dcl_input_ps linear v0.xyz
dcl_output o0.xyzw
dcl_temps 4
nop 
mov r0.xyz, v0.xyzx
fcall fp0[0][0]
nop 
mov r0.xyz, v0.xyzx
fcall fp0[1][1]
add r0.xyz, r1.xyzx, r2.xyzx
nop 
mov r1.xyz, v0.xyzx
fcall fp0[2][2]
add r0.xyz, r0.xyzx, r2.xyzx
nop 
mov r1.xyz, v0.xyzx
fcall fp3[0][0]
add r0.xyz, r0.xyzx, r2.xyzx
nop 
mov r1.xyz, v0.yzxy
fcall fp3[1][1]
add r0.xyz, r0.xyzx, r2.xyzx
nop 
mov r1.xyz, v0.zxyz
fcall fp5[0][0]
add r0.xyz, r0.xyzx, r2.xyzx
nop 
mov r1.xyz, v0.xyzx
fcall fp6[0][0]
add r0.xyz, r0.xyzx, r2.xyzx
nop 
mov r1.xyz, v0.xyzx
fcall fp6[1][1]
add o0.xyz, r0.xyzx, r2.xyzx
itof o0.w, l(1)
ret 
label fb0
nop 
itof r2.xyz, l(8, 8, 8, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb1
nop 
itof r2.xyz, l(7, 7, 7, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb2
nop 
itof r2.xyz, l(6, 6, 6, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb3
nop 
itof r2.xyz, l(5, 5, 5, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb4
nop 
itof r2.xyz, l(4, 4, 4, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb5
nop 
itof r2.xyz, l(3, 3, 3, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb6
nop 
itof r2.xyz, l(2, 2, 2, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb7
nop 
itof r2.xyz, l(1, 1, 1, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb8
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb9
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb10
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb11
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb12
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb13
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb14
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb15
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb16
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb17
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb18
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb19
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb20
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb21
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb22
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb23
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb24
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb25
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb26
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb27
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb28
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb29
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb30
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb31
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb32
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb33
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb34
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb35
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb36
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb37
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb38
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb39
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb40
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb41
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb42
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb43
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb44
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb45
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb46
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb47
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb48
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb49
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb50
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb51
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb52
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb53
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb54
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb55
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb56
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb57
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb58
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb59
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb60
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb61
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb62
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb63
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
