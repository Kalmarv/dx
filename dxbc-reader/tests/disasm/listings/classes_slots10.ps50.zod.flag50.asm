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
dcl_function_body fb64
dcl_function_body fb65
dcl_function_body fb66
dcl_function_body fb67
dcl_function_body fb68
dcl_function_body fb69
dcl_function_body fb70
dcl_function_body fb71
dcl_function_body fb72
dcl_function_body fb73
dcl_function_body fb74
dcl_function_body fb75
dcl_function_body fb76
dcl_function_body fb77
dcl_function_body fb78
dcl_function_body fb79
dcl_function_table ft0 = {fb0, fb10, fb20}
dcl_function_table ft1 = {fb1, fb11, fb21}
dcl_function_table ft2 = {fb2, fb12, fb22}
dcl_function_table ft3 = {fb3, fb13, fb23}
dcl_function_table ft4 = {fb4, fb14, fb24}
dcl_function_table ft5 = {fb5, fb15, fb25}
dcl_function_table ft6 = {fb6, fb16, fb26}
dcl_function_table ft7 = {fb7, fb17, fb27}
dcl_function_table ft8 = {fb8, fb18, fb28}
dcl_function_table ft9 = {fb9, fb19, fb29}
dcl_function_table ft10 = {fb30, fb40}
dcl_function_table ft11 = {fb31, fb41}
dcl_function_table ft12 = {fb32, fb42}
dcl_function_table ft13 = {fb33, fb43}
dcl_function_table ft14 = {fb34, fb44}
dcl_function_table ft15 = {fb35, fb45}
dcl_function_table ft16 = {fb36, fb46}
dcl_function_table ft17 = {fb37, fb47}
dcl_function_table ft18 = {fb38, fb48}
dcl_function_table ft19 = {fb39, fb49}
dcl_function_table ft20 = {fb50}
dcl_function_table ft21 = {fb51}
dcl_function_table ft22 = {fb52}
dcl_function_table ft23 = {fb53}
dcl_function_table ft24 = {fb54}
dcl_function_table ft25 = {fb55}
dcl_function_table ft26 = {fb56}
dcl_function_table ft27 = {fb57}
dcl_function_table ft28 = {fb58}
dcl_function_table ft29 = {fb59}
dcl_function_table ft30 = {fb60, fb70}
dcl_function_table ft31 = {fb61, fb71}
dcl_function_table ft32 = {fb62, fb72}
dcl_function_table ft33 = {fb63, fb73}
dcl_function_table ft34 = {fb64, fb74}
dcl_function_table ft35 = {fb65, fb75}
dcl_function_table ft36 = {fb66, fb76}
dcl_function_table ft37 = {fb67, fb77}
dcl_function_table ft38 = {fb68, fb78}
dcl_function_table ft39 = {fb69, fb79}
dcl_interface fp0[3][3] = {ft0, ft1, ft2, ft3, ft4, ft5, ft6, ft7, ft8, ft9}
dcl_interface fp3[2][2] = {ft10, ft11, ft12, ft13, ft14, ft15, ft16, ft17, ft18, ft19}
dcl_interface fp5[1][1] = {ft20, ft21, ft22, ft23, ft24, ft25, ft26, ft27, ft28, ft29}
dcl_interface fp6[2][2] = {ft30, ft31, ft32, ft33, ft34, ft35, ft36, ft37, ft38, ft39}
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
itof r2.xyz, l(10, 10, 10, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb1
nop 
itof r2.xyz, l(9, 9, 9, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb2
nop 
itof r2.xyz, l(8, 8, 8, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb3
nop 
itof r2.xyz, l(7, 7, 7, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb4
nop 
itof r2.xyz, l(6, 6, 6, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb5
nop 
itof r2.xyz, l(5, 5, 5, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb6
nop 
itof r2.xyz, l(4, 4, 4, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb7
nop 
itof r2.xyz, l(3, 3, 3, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb8
nop 
itof r2.xyz, l(2, 2, 2, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb9
nop 
itof r2.xyz, l(1, 1, 1, 0)
mul r1.xyz, r0.xyzx, r2.xyzx
ret 
label fb10
nop 
itof r3.xyz, l(10, 10, 10, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb11
nop 
itof r3.xyz, l(9, 9, 9, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb12
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb13
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb14
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb15
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb16
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb17
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb18
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb19
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r0.xyzx, r3.xyzx
ret 
label fb20
nop 
itof r3.xyz, l(10, 10, 10, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb21
nop 
itof r3.xyz, l(9, 9, 9, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb22
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb23
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb24
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb25
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb26
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb27
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb28
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb29
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb30
nop 
itof r3.xyz, l(10, 10, 10, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb31
nop 
itof r3.xyz, l(9, 9, 9, 0)
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
itof r3.xyz, l(10, 10, 10, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb41
nop 
itof r3.xyz, l(9, 9, 9, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb42
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb43
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb44
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb45
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb46
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb47
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb48
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb49
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb50
nop 
itof r3.xyz, l(10, 10, 10, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb51
nop 
itof r3.xyz, l(9, 9, 9, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb52
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb53
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb54
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb55
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb56
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb57
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb58
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb59
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb60
nop 
itof r3.xyz, l(10, 10, 10, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb61
nop 
itof r3.xyz, l(9, 9, 9, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb62
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb63
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb64
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb65
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb66
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb67
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb68
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb69
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb70
nop 
itof r3.xyz, l(10, 10, 10, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb71
nop 
itof r3.xyz, l(9, 9, 9, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb72
nop 
itof r3.xyz, l(8, 8, 8, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb73
nop 
itof r3.xyz, l(7, 7, 7, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb74
nop 
itof r3.xyz, l(6, 6, 6, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb75
nop 
itof r3.xyz, l(5, 5, 5, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb76
nop 
itof r3.xyz, l(4, 4, 4, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb77
nop 
itof r3.xyz, l(3, 3, 3, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb78
nop 
itof r3.xyz, l(2, 2, 2, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
label fb79
nop 
itof r3.xyz, l(1, 1, 1, 0)
mul r2.xyz, r1.xyzx, r3.xyzx
ret 
