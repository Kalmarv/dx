      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB-2[-13], dynamicIndexed
      0x0000001C: dcl_sampler s-4, mode_default
      0x00000028: dcl_resource_texture2d (float,float,float,float) t-4
      0x00000038: dcl_resource_raw t-6
      0x00000044: dcl_uav_structured u-2, 16
      0x00000054: dcl_input_ps_siv linear noperspective v-1.xyzw, position
      0x00000064: dcl_input_ps linear v-2.xyzw
      0x00000070: dcl_input_ps linear v-3.xyzw
      0x0000007C: dcl_input_ps linear v-4.xyzw
      0x00000088: dcl_input_ps_sgv constant v-5.x, is_front_face
      0x00000098: dcl_output o-1.xyzw
      0x000000A4: dcl_temps -3
      0x000000AC: dcl_indexrange v-2.xyzw -4
      0x000000BC: dcl_indexableTemp x-1[-5], 4
   0  0x000000CC: mov x-1[-1].xyzw, v-1.xyzw
   1  0x000000E4: mov x-1[-2].xyzw, v-2.xyzw
   2  0x000000FC: mov x-1[-3].xyzw, v-3.xyzw
   3  0x00000114: mov x-1[-4].xyzw, v-4.xyzw
   4  0x0000012C: and r-1.x, cb-2[-12].x, l(0x00000003)
   5  0x0000014C: mov r-2.xyzw, x-1[r-1.x + 0].xyzw
   6  0x00000168: mov r-1.y, cb-2[-12].x
   7  0x00000180: add r-2.xyzw, r-2.xyzw, cb-2[r-1.y + -4].xyzw
   8  0x000001A8: mov x-1[r-1.x + 0].xyzw, r-2.xyzw
   9  0x000001C4: iadd r-1.x, cb-2[-12].x, l(0x00000001)
  10  0x000001E4: and r-1.x, r-1.x, l(0x00000003)
  11  0x00000200: mov r-1.xyzw, x-1[r-1.x + 0].xyzw
  12  0x0000021C: udiv null, r-2.x, cb-2[-12].x, l(0x00000003)
  13  0x00000240: add r-1.xyzw, r-1.xyzw, v[r-2.x + -2].xyzw
  14  0x00000264: sample_indexable(texture2d)(float,float,float,float) r-2.xyzw, v-1.xyxx, t-4.xyzw, s-4
  15  0x00000290: add r-1.xyzw, r-1.xyzw, r-2.xyzw
  16  0x000002AC: ishl r-2.x, cb-2[-12].x, l(0x00000002)
  17  0x000002CC: ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r-2.x, r-2.x, t-6.xxxx
  18  0x000002F0: add r-1.xyzw, r-1.xyzw, r-2.xxxx
  19  0x0000030C: store_structured u-2.xyzw, cb-2[-12].x, l(0x00000000), r-1.xyzw
  20  0x00000334: movc o-1.xyzw, v-5.xxxx, r-1.xyzw, -r-1.xyzw
  21  0x0000035C: ret 
