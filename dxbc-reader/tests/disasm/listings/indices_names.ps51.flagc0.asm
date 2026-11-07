ps_5_1
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[1:1][12], dynamicIndexed, space=0
dcl_sampler S0[3:3], mode_default, space=0
dcl_resource_texture2d (<unknown resource return type>,<continued>,<unused>,<unknown resource return type>) T0[2:3], space=0
dcl_resource_raw T1[5:5], space=0
dcl_uav_structured U0[1:1], 16, space=0
dcl_input_ps_siv linear noperspective v0.xyzw, position
dcl_input_ps linear v1.xyzw
dcl_input_ps linear v2.xyzw
dcl_input_ps linear v3.xyzw
dcl_input_ps_sgv constant v4.x, 
dcl_output o0.xyzw
dcl_temps 2
dcl_indexrange v1.xyzw 3
dcl_indexableTemp x0[4], 4
mov x0[0].xyzw, v0.xyzw
mov x0[1].xyzw, v1.xyzw
mov x0[2].xyzw, v2.xyzw
mov x0[3].xyzw, v3.xyzw
and r0.x, CB0[1][11].x, l(0x00000003)
mov r1.xyzw, x0[r0.x + 0].xyzw
mov r0.y, CB0[1][11].x
add r1.xyzw, r1.xyzw, CB0[1][r0.y + 3].xyzw
mov x0[r0.x + 0].xyzw, r1.xyzw
iadd r0.x, CB0[1][11].x, l(0x00000001)
and r0.x, r0.x, l(0x00000003)
mov r0.xyzw, x0[r0.x + 0].xyzw
udiv null, r1.x, CB0[1][11].x, l(0x00000003)
add r0.xyzw, r0.xyzw, v[r1.x + 1].xyzw
sample r1.xyzw, v0.xyxx, T0[3].xyzw, S0[3]
add r0.xyzw, r0.xyzw, r1.xyzw
ishl r1.x, CB0[1][11].x, l(0x00000002)
ld_raw r1.x, r1.x, T1[5].xxxx
add r0.xyzw, r0.xyzw, r1.xxxx
store_structured U0[1].xyzw, CB0[1][11].x, l(0x00000000), r0.xyzw
movc o0.xyzw, v4.xxxx, r0.xyzw, -r0.xyzw
ret 
