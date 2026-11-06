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

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb0
mul r0.xyz, v0.xyzx, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb1
mul r0.xyz, v0.xyzx, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb2
mul r0.xyz, v0.xyzx, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb3
mul r0.xyz, v0.xyzx, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb4
mul r0.xyz, v0.xyzx, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb5
mul r0.xyz, v0.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb6
add r0.xyz, v0.xyzx, v0.xyzx
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb7
mov r0.xyz, v0.xyzx
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb8
mul r1.xyz, v0.xyzx, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb9
mul r1.xyz, v0.xyzx, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb10
mul r1.xyz, v0.xyzx, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb11
mul r1.xyz, v0.xyzx, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb12
mul r1.xyz, v0.xyzx, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb13
mul r1.xyz, v0.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb14
add r1.xyz, v0.xyzx, v0.xyzx
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb15
mov r1.xyz, v0.xyzx
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb16
mul r1.xyz, v0.xyzx, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb17
mul r1.xyz, v0.xyzx, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb18
mul r1.xyz, v0.xyzx, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb19
mul r1.xyz, v0.xyzx, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb20
mul r1.xyz, v0.xyzx, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb21
mul r1.xyz, v0.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb22
add r1.xyz, v0.xyzx, v0.xyzx
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb23
mov r1.xyz, v0.xyzx
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb24
mul r1.xyz, v0.xyzx, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb25
mul r1.xyz, v0.xyzx, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb26
mul r1.xyz, v0.xyzx, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb27
mul r1.xyz, v0.xyzx, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb28
mul r1.xyz, v0.xyzx, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb29
mul r1.xyz, v0.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb30
add r1.xyz, v0.xyzx, v0.xyzx
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb31
mov r1.xyz, v0.xyzx
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb32
mul r1.xyz, v0.yzxy, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb33
mul r1.xyz, v0.yzxy, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb34
mul r1.xyz, v0.yzxy, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb35
mul r1.xyz, v0.yzxy, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb36
mul r1.xyz, v0.yzxy, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb37
mul r1.xyz, v0.yzxy, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb38
add r1.xyz, v0.yzxy, v0.yzxy
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb39
mov r1.xyz, v0.yzxy
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb40
mul r1.xyz, v0.zxyz, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb41
mul r1.xyz, v0.zxyz, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb42
mul r1.xyz, v0.zxyz, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb43
mul r1.xyz, v0.zxyz, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb44
mul r1.xyz, v0.zxyz, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb45
mul r1.xyz, v0.zxyz, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb46
add r1.xyz, v0.zxyz, v0.zxyz
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb47
mov r1.xyz, v0.zxyz
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb48
mul r1.xyz, v0.xyzx, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb49
mul r1.xyz, v0.xyzx, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb50
mul r1.xyz, v0.xyzx, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb51
mul r1.xyz, v0.xyzx, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb52
mul r1.xyz, v0.xyzx, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb53
mul r1.xyz, v0.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb54
add r1.xyz, v0.xyzx, v0.xyzx
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb55
mov r1.xyz, v0.xyzx
ret 

#line 26 "C:\dx-fixtures\classes_slots.hlsl"
label fb56
mul r1.xyz, v0.xyzx, l(8.000000, 8.000000, 8.000000, 0.000000)
ret 

#line 25 "C:\dx-fixtures\classes_slots.hlsl"
label fb57
mul r1.xyz, v0.xyzx, l(7.000000, 7.000000, 7.000000, 0.000000)
ret 

#line 24 "C:\dx-fixtures\classes_slots.hlsl"
label fb58
mul r1.xyz, v0.xyzx, l(6.000000, 6.000000, 6.000000, 0.000000)
ret 

#line 23 "C:\dx-fixtures\classes_slots.hlsl"
label fb59
mul r1.xyz, v0.xyzx, l(5.000000, 5.000000, 5.000000, 0.000000)
ret 

#line 22 "C:\dx-fixtures\classes_slots.hlsl"
label fb60
mul r1.xyz, v0.xyzx, l(4.000000, 4.000000, 4.000000, 0.000000)
ret 

#line 21 "C:\dx-fixtures\classes_slots.hlsl"
label fb61
mul r1.xyz, v0.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
ret 

#line 20 "C:\dx-fixtures\classes_slots.hlsl"
label fb62
add r1.xyz, v0.xyzx, v0.xyzx
ret 

#line 19 "C:\dx-fixtures\classes_slots.hlsl"
label fb63
mov r1.xyz, v0.xyzx
ret 
