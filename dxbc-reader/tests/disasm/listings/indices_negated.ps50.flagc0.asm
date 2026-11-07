ps_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB-2[-13], dynamicIndexed
dcl_sampler s-4, mode_default
dcl_resource_texture2d (float,float,float,float) t-4
dcl_resource_raw t-6
dcl_uav_structured u-2, 16
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
and r-1.x, cb-2[-12].x, l(0x00000003)
mov r-2.xyzw, x-1[r-1.x + 0].xyzw
mov r-1.y, cb-2[-12].x
add r-2.xyzw, r-2.xyzw, cb-2[r-1.y + -4].xyzw
mov x-1[r-1.x + 0].xyzw, r-2.xyzw
iadd r-1.x, cb-2[-12].x, l(0x00000001)
and r-1.x, r-1.x, l(0x00000003)
mov r-1.xyzw, x-1[r-1.x + 0].xyzw
udiv null, r-2.x, cb-2[-12].x, l(0x00000003)
add r-1.xyzw, r-1.xyzw, v[r-2.x + -2].xyzw
sample_indexable(texture2d)(float,float,float,float) r-2.xyzw, v-1.xyxx, t-4.xyzw, s-4
add r-1.xyzw, r-1.xyzw, r-2.xyzw
ishl r-2.x, cb-2[-12].x, l(0x00000002)
ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r-2.x, r-2.x, t-6.xxxx
add r-1.xyzw, r-1.xyzw, r-2.xxxx
store_structured u-2.xyzw, cb-2[-12].x, l(0x00000000), r-1.xyzw
movc o-1.xyzw, v-5.xxxx, r-1.xyzw, -r-1.xyzw
ret 
