0x00000000: ps_5_1
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB0[1:1][12], dynamicIndexed, space=0
0x00000028: dcl_sampler S0[3:3], mode_default, space=0
0x00000040: dcl_resource_texture2d (float,float,float,float) T0[2:3], space=0
0x0000005C: dcl_resource_raw T1[5:5], space=0
0x00000074: dcl_uav_structured U0[1:1], 16, space=0
0x00000090: dcl_input_ps_siv linear noperspective v0.xyzw, position
0x000000A0: dcl_input_ps linear v1.xyzw
0x000000AC: dcl_input_ps linear v2.xyzw
0x000000B8: dcl_input_ps linear v3.xyzw
0x000000C4: dcl_input_ps_sgv constant v4.x, is_front_face
0x000000D4: dcl_output o0.xyzw
0x000000E0: dcl_temps 2
0x000000E8: dcl_indexrange v1.xyzw 3
0x000000F8: dcl_indexableTemp x0[4], 4
0x00000108: mov x0[0].xyzw, v0.xyzw
0x00000120: mov x0[1].xyzw, v1.xyzw
0x00000138: mov x0[2].xyzw, v2.xyzw
0x00000150: mov x0[3].xyzw, v3.xyzw
0x00000168: and r0.x, CB0[1][11].x, l(3)
0x0000018C: mov r1.xyzw, x0[r0.x + 0].xyzw
0x000001A8: mov r0.y, CB0[1][11].x
0x000001C4: add r1.xyzw, r1.xyzw, CB0[1][r0.y + 3].xyzw
0x000001F0: mov x0[r0.x + 0].xyzw, r1.xyzw
0x0000020C: iadd r0.x, CB0[1][11].x, l(1)
0x00000230: and r0.x, r0.x, l(3)
0x0000024C: mov r0.xyzw, x0[r0.x + 0].xyzw
0x00000268: udiv null, r1.x, CB0[1][11].x, l(3)
0x00000290: add r0.xyzw, r0.xyzw, v[r1.x + 1].xyzw
0x000002B4: sample r1.xyzw, v0.xyxx, T0[3].xyzw, S0[3]
0x000002E0: add r0.xyzw, r0.xyzw, r1.xyzw
0x000002FC: ishl r1.x, CB0[1][11].x, l(2)
0x00000320: ld_raw r1.x, r1.x, T1[5].xxxx
0x00000340: add r0.xyzw, r0.xyzw, r1.xxxx
0x0000035C: store_structured U0[1].xyzw, CB0[1][11].x, l(0), r0.xyzw
0x0000038C: movc o0.xyzw, v4.xxxx, r0.xyzw, -r0.xyzw
0x000003B4: ret 
