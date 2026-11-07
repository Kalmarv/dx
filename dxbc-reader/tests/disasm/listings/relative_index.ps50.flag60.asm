0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_constantbuffer CB1[12], dynamicIndexed
0x0000001C: dcl_sampler s3, mode_default
0x00000028: dcl_resource_texture2d (float,float,float,float) t3
0x00000038: dcl_resource_raw t5
0x00000044: dcl_uav_structured u1, 16
0x00000054: dcl_input_ps_siv linear noperspective v0.xyzw, position
0x00000064: dcl_input_ps linear v1.xyzw
0x00000070: dcl_input_ps linear v2.xyzw
0x0000007C: dcl_input_ps linear v3.xyzw
0x00000088: dcl_input_ps_sgv constant v4.x, is_front_face
0x00000098: dcl_output o0.xyzw
0x000000A4: dcl_temps 2
0x000000AC: dcl_indexrange v1.xyzw 3
0x000000BC: dcl_indexableTemp x0[4], 4
0x000000CC: mov x0[0].xyzw, v0.xyzw
0x000000E4: mov x0[1].xyzw, v1.xyzw
0x000000FC: mov x0[2].xyzw, v2.xyzw
0x00000114: mov x0[3].xyzw, v3.xyzw
0x0000012C: and r0.x, cb1[11].x, l(3)
0x0000014C: mov r1.xyzw, x0[r0.w + 0].xyzw
0x00000168: mov r0.y, cb1[11].x
0x00000180: add r1.xyzw, r1.xyzw, cb1[r0.x + 3].xyzw
0x000001A8: mov x0[r0.x + 0].xyzw, r1.xyzw
0x000001C4: iadd r0.x, cb1[11].x, l(1)
0x000001E4: and r0.x, r0.x, l(3)
0x00000200: mov r0.xyzw, x0[r0.x + 0].xyzw
0x0000021C: udiv null, r1.x, cb1[11].x, l(3)
0x00000240: add r0.xyzw, r0.xyzw, v[r1.x + 1].xyzw
0x00000264: sample_indexable(texture2d)(float,float,float,float) r1.xyzw, v0.xyxx, t3.xyzw, s3
0x00000290: add r0.xyzw, r0.xyzw, r1.xyzw
0x000002AC: ishl r1.x, cb1[11].x, l(2)
0x000002CC: ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r1.x, r1.x, t5.xxxx
0x000002F0: add r0.xyzw, r0.xyzw, r1.xxxx
0x0000030C: store_structured u1.xyzw, cb1[11].x, l(0), r0.xyzw
0x00000334: movc o0.xyzw, v4.xxxx, r0.xyzw, -r0.xyzw
0x0000035C: ret 
