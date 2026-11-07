      0x00000000: ps_5_1
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB-1[-2:-2][-13], dynamicIndexed, space=-1
      0x00000028: dcl_sampler S4294967295[4294967292:4294967292], mode_default, space=4294967295
      0x00000040: dcl_resource_texture2d (float,float,float,float) T4294967295[4294967293:4294967292], space=4294967295
      0x0000005C: dcl_resource_raw T4294967294[4294967290:4294967290], space=4294967295
      0x00000074: dcl_uav_structured U4294967295[4294967294:4294967294], 16, space=4294967295
      0x00000090: dcl_input_ps_siv linear noperspective v-1.xyzw, position
      0x000000A0: dcl_input_ps linear v-2.xyzw
      0x000000AC: dcl_input_ps linear v-3.xyzw
      0x000000B8: dcl_input_ps linear v-4.xyzw
      0x000000C4: dcl_input_ps_sgv constant v-5.x, is_front_face
      0x000000D4: dcl_output o-1.xyzw
      0x000000E0: dcl_temps -3
      0x000000E8: dcl_indexrange v-2.xyzw -4
      0x000000F8: dcl_indexableTemp x-1[-5], 4
   0  0x00000108: mov x-1[-1].xyzw, v-1.xyzw
   1  0x00000120: mov x-1[-2].xyzw, v-2.xyzw
   2  0x00000138: mov x-1[-3].xyzw, v-3.xyzw
   3  0x00000150: mov x-1[-4].xyzw, v-4.xyzw
   4  0x00000168: and r-1.x, CB-1[-2][-12].x, l(0x00000003)
   5  0x0000018C: mov r-2.xyzw, x-1[r-1.x + 0].xyzw
   6  0x000001A8: mov r-1.y, CB-1[-2][-12].x
   7  0x000001C4: add r-2.xyzw, r-2.xyzw, CB-1[-2][r-1.y + -4].xyzw
   8  0x000001F0: mov x-1[r-1.x + 0].xyzw, r-2.xyzw
   9  0x0000020C: iadd r-1.x, CB-1[-2][-12].x, l(0x00000001)
  10  0x00000230: and r-1.x, r-1.x, l(0x00000003)
  11  0x0000024C: mov r-1.xyzw, x-1[r-1.x + 0].xyzw
  12  0x00000268: udiv null, r-2.x, CB-1[-2][-12].x, l(0x00000003)
  13  0x00000290: add r-1.xyzw, r-1.xyzw, v[r-2.x + -2].xyzw
  14  0x000002B4: sample r-2.xyzw, v-1.xyxx, T-1[-4].xyzw, S-1[-4]
  15  0x000002E0: add r-1.xyzw, r-1.xyzw, r-2.xyzw
  16  0x000002FC: ishl r-2.x, CB-1[-2][-12].x, l(0x00000002)
  17  0x00000320: ld_raw r-2.x, r-2.x, T-2[-6].xxxx
  18  0x00000340: add r-1.xyzw, r-1.xyzw, r-2.xxxx
  19  0x0000035C: store_structured U-1[-2].xyzw, CB-1[-2][-12].x, l(0x00000000), r-1.xyzw
  20  0x0000038C: movc o-1.xyzw, v-5.xxxx, r-1.xyzw, -r-1.xyzw
  21  0x000003B4: ret 
