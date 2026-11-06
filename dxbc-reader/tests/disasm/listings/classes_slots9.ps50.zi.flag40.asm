ps_5_0
dcl_globalFlags refactoringAllowed
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
dcl_function_table ft0 = {fb0, fb9, fb18}
dcl_function_table ft1 = {fb1, fb10, fb19}
dcl_function_table ft2 = {fb2, fb11, fb20}
dcl_function_table ft3 = {fb3, fb12, fb21}
dcl_function_table ft4 = {fb4, fb13, fb22}
dcl_function_table ft5 = {fb5, fb14, fb23}
dcl_function_table ft6 = {fb6, fb15, fb24}
dcl_function_table ft7 = {fb7, fb16, fb25}
dcl_function_table ft8 = {fb8, fb17, fb26}
dcl_function_table ft9 = {fb27, fb36}
dcl_function_table ft10 = {fb28, fb37}
dcl_function_table ft11 = {fb29, fb38}
dcl_function_table ft12 = {fb30, fb39}
dcl_function_table ft13 = {fb31, fb40}
dcl_function_table ft14 = {fb32, fb41}
dcl_function_table ft15 = {fb33, fb42}
dcl_function_table ft16 = {fb34, fb43}
dcl_function_table ft17 = {fb35, fb44}
dcl_function_table ft18 = {fb45}
dcl_function_table ft19 = {fb46}
dcl_function_table ft20 = {fb47}
dcl_function_table ft21 = {fb48}
dcl_function_table ft22 = {fb49}
dcl_function_table ft23 = {fb50}
dcl_function_table ft24 = {fb51}
dcl_function_table ft25 = {fb52}
dcl_function_table ft26 = {fb53}
dcl_function_table ft27 = {fb54, fb63}
dcl_function_table ft28 = {fb55, fb64}
dcl_function_table ft29 = {fb56, fb65}
dcl_function_table ft30 = {fb57, fb66}
dcl_function_table ft31 = {fb58, fb67}
dcl_function_table ft32 = {fb59, fb68}
dcl_function_table ft33 = {fb60, fb69}
dcl_function_table ft34 = {fb61, fb70}
dcl_function_table ft35 = {fb62, fb71}
dcl_interface fp0[3][3] = {ft0, ft1, ft2, ft3, ft4, ft5, ft6, ft7, ft8}
dcl_interface fp3[2][2] = {ft9, ft10, ft11, ft12, ft13, ft14, ft15, ft16, ft17}
dcl_interface fp5[1][1] = {ft18, ft19, ft20, ft21, ft22, ft23, ft24, ft25, ft26}
dcl_interface fp6[2][2] = {ft27, ft28, ft29, ft30, ft31, ft32, ft33, ft34, ft35}
dcl_input_ps linear v0.xyz
dcl_output o0.xyzw
dcl_temps 2
//
// Initial variable locations:
//   v0.x <- n.x; v0.y <- n.y; v0.z <- n.z; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 98 "C:\dx-fixtures\classes_slots.hlsl"
fcall fp0[0][0]
fcall fp0[1][1]
add r0.xyz, r0.xyzx, r1.xyzx
fcall fp0[2][2]
add r0.xyz, r0.xyzx, r1.xyzx
fcall fp3[0][0]
add r0.xyz, r0.xyzx, r1.xyzx
fcall fp3[1][1]
add r0.xyz, r0.xyzx, r1.xyzx
fcall fp5[0][0]
add r0.xyz, r0.xyzx, r1.xyzx
fcall fp6[0][0]
add r0.xyz, r0.xyzx, r1.xyzx
fcall fp6[1][1]
add o0.xyz, r0.xyzx, r1.xyzx
mov o0.w, l(1.000000)
ret 

#line 28 "C:\dx-fixtures\classes_slots.hlsl"
label fb0
mul r0.xyz, v0.xyzx, l(9.000000, 9.000000, 9.000000, 0.000000)
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb1
mul r0.xyz, v0.xyzx, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb2
mul r0.xyz, v0.xyzx, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb3
mul r0.xyz, v0.xyzx, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb4
mul r0.xyz, v0.xyzx, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb5
mul r0.xyz, v0.xyzx, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb6
mul r0.xyz, v0.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb7
add r0.xyz, v0.xyzx, v0.xyzx
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb8
mov r0.xyz, v0.xyzx
ret 

#line 28 "C:\dx-fixtures\classes_slots.hlsl"
label fb9
mul r1.xyz, v0.xyzx, l(9.000000, 9.000000, 9.000000, 0.000000)
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb10
mul r1.xyz, v0.xyzx, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb11
mul r1.xyz, v0.xyzx, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb12
mul r1.xyz, v0.xyzx, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb13
mul r1.xyz, v0.xyzx, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb14
mul r1.xyz, v0.xyzx, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb15
mul r1.xyz, v0.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb16
add r1.xyz, v0.xyzx, v0.xyzx
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb17
mov r1.xyz, v0.xyzx
ret 

#line 28 "C:\dx-fixtures\classes_slots.hlsl"
label fb18
mul r1.xyz, v0.xyzx, l(9.000000, 9.000000, 9.000000, 0.000000)
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb19
mul r1.xyz, v0.xyzx, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb20
mul r1.xyz, v0.xyzx, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb21
mul r1.xyz, v0.xyzx, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb22
mul r1.xyz, v0.xyzx, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb23
mul r1.xyz, v0.xyzx, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb24
mul r1.xyz, v0.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb25
add r1.xyz, v0.xyzx, v0.xyzx
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb26
mov r1.xyz, v0.xyzx
ret 

#line 28 "C:\dx-fixtures\classes_slots.hlsl"
label fb27
mul r1.xyz, v0.xyzx, l(9.000000, 9.000000, 9.000000, 0.000000)
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb28
mul r1.xyz, v0.xyzx, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb29
mul r1.xyz, v0.xyzx, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb30
mul r1.xyz, v0.xyzx, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb31
mul r1.xyz, v0.xyzx, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb32
mul r1.xyz, v0.xyzx, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb33
mul r1.xyz, v0.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb34
add r1.xyz, v0.xyzx, v0.xyzx
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb35
mov r1.xyz, v0.xyzx
ret 

#line 28 "C:\dx-fixtures\classes_slots.hlsl"
label fb36
mul r1.xyz, v0.yzxy, l(9.000000, 9.000000, 9.000000, 0.000000)
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb37
mul r1.xyz, v0.yzxy, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb38
mul r1.xyz, v0.yzxy, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb39
mul r1.xyz, v0.yzxy, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb40
mul r1.xyz, v0.yzxy, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb41
mul r1.xyz, v0.yzxy, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb42
mul r1.xyz, v0.yzxy, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb43
add r1.xyz, v0.yzxy, v0.yzxy
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb44
mov r1.xyz, v0.yzxy
ret 

#line 28 "C:\dx-fixtures\classes_slots.hlsl"
label fb45
mul r1.xyz, v0.zxyz, l(9.000000, 9.000000, 9.000000, 0.000000)
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb46
mul r1.xyz, v0.zxyz, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb47
mul r1.xyz, v0.zxyz, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb48
mul r1.xyz, v0.zxyz, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb49
mul r1.xyz, v0.zxyz, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb50
mul r1.xyz, v0.zxyz, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb51
mul r1.xyz, v0.zxyz, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb52
add r1.xyz, v0.zxyz, v0.zxyz
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb53
mov r1.xyz, v0.zxyz
ret 

#line 28 "C:\dx-fixtures\classes_slots.hlsl"
label fb54
mul r1.xyz, v0.xyzx, l(9.000000, 9.000000, 9.000000, 0.000000)
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb55
mul r1.xyz, v0.xyzx, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb56
mul r1.xyz, v0.xyzx, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb57
mul r1.xyz, v0.xyzx, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb58
mul r1.xyz, v0.xyzx, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb59
mul r1.xyz, v0.xyzx, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb60
mul r1.xyz, v0.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb61
add r1.xyz, v0.xyzx, v0.xyzx
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb62
mov r1.xyz, v0.xyzx
ret 

#line 28 "C:\dx-fixtures\classes_slots.hlsl"
label fb63
mul r1.xyz, v0.xyzx, l(9.000000, 9.000000, 9.000000, 0.000000)
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb64
mul r1.xyz, v0.xyzx, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb65
mul r1.xyz, v0.xyzx, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb66
mul r1.xyz, v0.xyzx, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb67
mul r1.xyz, v0.xyzx, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb68
mul r1.xyz, v0.xyzx, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb69
mul r1.xyz, v0.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb70
add r1.xyz, v0.xyzx, v0.xyzx
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb71
mov r1.xyz, v0.xyzx
ret 
