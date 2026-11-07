      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB1[12], dynamicIndexed
      0x0000001C: dcl_sampler s3, mode_default
      0x00000028: dcl_resource_texture2d (float,float,float,float) t3
      0x00000038: dcl_resource_raw t5
      0x00000044: dcl_uav_structured u1, 16
      0x00000054: dcl_input_ps_siv linear noperspective v0., position
      0x00000064: dcl_input_ps linear v1.
      0x00000070: dcl_input_ps linear v2.
      0x0000007C: dcl_input_ps linear v3.
      0x00000088: dcl_input_ps_sgv constant v4., is_front_face
      0x00000098: dcl_output o0.
      0x000000A4: dcl_temps 2
      0x000000AC: dcl_indexrange v1. 3
      0x000000BC: dcl_indexableTemp x0[4], 4
   0  0x000000CC: mov x0[0]., v0.xyzw
   1  0x000000E4: mov x0[1]., v1.xyzw
   2  0x000000FC: mov x0[2]., v2.xyzw
   3  0x00000114: mov x0[3]., v3.xyzw
   4  0x0000012C: and r0., cb1[11].x, l(0x00000003)
   5  0x0000014C: mov r1., x0[r0.x + 0].xyzw
   6  0x00000168: mov r0., cb1[11].x
   7  0x00000180: add r1., r1.xyzw, cb1[r0.y + 3].xyzw
   8  0x000001A8: mov x0[r0.x + 0]., r1.xyzw
   9  0x000001C4: iadd r0., cb1[11].x, l(0x00000001)
  10  0x000001E4: and r0., r0.x, l(0x00000003)
  11  0x00000200: mov r0., x0[r0.x + 0].xyzw
  12  0x0000021C: udiv null, r1.x, cb1[11].x, l(0x00000003)
  13  0x00000240: add r0., r0.xyzw, v[r1.x + 1].xyzw
  14  0x00000264: sample_indexable(texture2d)(float,float,float,float) r1., v0.xyxx, t3.xyzw, s3
  15  0x00000290: add r0., r0.xyzw, r1.xyzw
  16  0x000002AC: ishl r1., cb1[11].x, l(0x00000002)
  17  0x000002CC: ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r1., r1.x, t5.xxxx
  18  0x000002F0: add r0., r0.xyzw, r1.xxxx
  19  0x0000030C: store_structured u1., cb1[11].x, l(0x00000000), r0.xyzw
  20  0x00000334: movc o0., v4.xxxx, r0.xyzw, -r0.xyzw
  21  0x0000035C: ret 
