ps_5_1
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB-1[-2:-2][-13], dynamicIndexed, space=-1
dcl_sampler S4294967295[4294967292:4294967292], mode_default, space=4294967295
dcl_resource_texture2d (float,float,float,float) T4294967295[4294967293:4294967292], space=4294967295
dcl_resource_raw T4294967294[4294967290:4294967290], space=4294967295
dcl_uav_structured U4294967295[4294967294:4294967294], 16, space=4294967295
dcl_input_ps_siv linear noperspective v-1.xyzw, position
dcl_input_ps linear v-2.xyzw
dcl_input_ps linear v-3.xyzw
dcl_input_ps linear v-4.xyzw
dcl_input_ps_sgv constant v-5.x, is_front_face
dcl_output o-1.xyzw
dcl_temps -3
dcl_indexrange v-2.xyzw -4
dcl_indexableTemp x-1[-5], 4
mov x-1[-1].xyzw, v-1.xyzw
mov x-1[-2].xyzw, v-2.xyzw
mov x-1[-3].xyzw, v-3.xyzw
mov x-1[-4].xyzw, v-4.xyzw
and r-1.x, CB-1[-2][-12].x, l(3)
mov r-2.xyzw, x-1[r-1.x + 0].xyzw
mov r-1.y, CB-1[-2][-12].x
add r-2.xyzw, r-2.xyzw, CB-1[-2][r-1.y + -4].xyzw
mov x-1[r-1.x + 0].xyzw, r-2.xyzw
iadd r-1.x, CB-1[-2][-12].x, l(1)
and r-1.x, r-1.x, l(3)
mov r-1.xyzw, x-1[r-1.x + 0].xyzw
udiv null, r-2.x, CB-1[-2][-12].x, l(3)
add r-1.xyzw, r-1.xyzw, v[r-2.x + -2].xyzw
sample r-2.xyzw, v-1.xyxx, T-1[-4].xyzw, S-1[-4]
add r-1.xyzw, r-1.xyzw, r-2.xyzw
ishl r-2.x, CB-1[-2][-12].x, l(2)
ld_raw r-2.x, r-2.x, T-2[-6].xxxx
add r-1.xyzw, r-1.xyzw, r-2.xxxx
store_structured U-1[-2].xyzw, CB-1[-2][-12].x, l(0), r-1.xyzw
movc o-1.xyzw, v-5.xxxx, r-1.xyzw, -r-1.xyzw
ret 
