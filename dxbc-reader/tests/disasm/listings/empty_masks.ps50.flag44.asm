      ps_5_0
      dcl_globalFlags refactoringAllowed
      dcl_constantbuffer CB1[12], dynamicIndexed
      dcl_sampler s3, mode_default
      dcl_resource_texture2d (float,float,float,float) t3
      dcl_resource_raw t5
      dcl_uav_structured u1, 16
      dcl_input_ps_siv linear noperspective v0., position
      dcl_input_ps linear v1.
      dcl_input_ps linear v2.
      dcl_input_ps linear v3.
      dcl_input_ps_sgv constant v4., is_front_face
      dcl_output o0.
      dcl_temps 2
      dcl_indexrange v1. 3
      dcl_indexableTemp x0[4], 4
   0: mov x0[0]., v0.xyzw
   1: mov x0[1]., v1.xyzw
   2: mov x0[2]., v2.xyzw
   3: mov x0[3]., v3.xyzw
   4: and r0., cb1[11].x, l(3)
   5: mov r1., x0[r0.x + 0].xyzw
   6: mov r0., cb1[11].x
   7: add r1., r1.xyzw, cb1[r0.y + 3].xyzw
   8: mov x0[r0.x + 0]., r1.xyzw
   9: iadd r0., cb1[11].x, l(1)
  10: and r0., r0.x, l(3)
  11: mov r0., x0[r0.x + 0].xyzw
  12: udiv null, r1.x, cb1[11].x, l(3)
  13: add r0., r0.xyzw, v[r1.x + 1].xyzw
  14: sample_indexable(texture2d)(float,float,float,float) r1., v0.xyxx, t3.xyzw, s3
  15: add r0., r0.xyzw, r1.xyzw
  16: ishl r1., cb1[11].x, l(2)
  17: ld_raw_indexable(raw_buffer)(mixed,mixed,mixed,mixed) r1., r1.x, t5.xxxx
  18: add r0., r0.xyzw, r1.xxxx
  19: store_structured u1., cb1[11].x, l(0), r0.xyzw
  20: movc o0., v4.xxxx, r0.xyzw, -r0.xyzw
  21: ret 
