      vs_4_0
      dcl_constantbuffer CB0[68], dynamicIndexed
      dcl_resource_buffer (float,float,float,float) t0
      dcl_input v0.xyzw
      dcl_input v1.xyzw
      dcl_input v2.xyzw
      dcl_input_sgv v3.x, vertex_id
      dcl_output_siv o0.xyzw, position
      dcl_output o1.xyzw
      dcl_output o2.x
      dcl_temps 2
   0: mov r0.x, v1.y
   1: mul r0.xyzw, v2.yyyy, cb0[r0.x + 4].xyzw
   2: mov r1.x, v1.x
   3: mad r0.xyzw, cb0[r1.x + 4].xyzw, v2.xxxx, r0.xyzw
   4: mov r1.x, v1.z
   5: mad r0.xyzw, cb0[r1.x + 4].xyzw, v2.zzzz, r0.xyzw
   6: mov r1.x, v1.w
   7: mad r0.xyzw, cb0[r1.x + 4].xyzw, v2.wwww, r0.xyzw
   8: add r0.xyzw, r0.xyzw, v0.xyzw
   9: dp4 o0.x, r0.xyzw, cb0[0].xyzw
  10: dp4 o0.y, r0.xyzw, cb0[1].xyzw
  11: dp4 r1.z, r0.xyzw, cb0[2].xyzw
  12: dp4 r1.w, r0.xyzw, cb0[3].xyzw
  13: mov o0.zw, r1.zzzw
  14: div o2.x, r1.z, r1.w
  15: udiv null, r0.x, v3.x, l(3)
  16: movc r0.x, r0.x, l(0.500000), l(2.000000)
  17: ld r1.xyzw, v3.xxxx, t0.xyzw
  18: mul o1.xyzw, r0.xxxx, r1.xyzw
  19: ret 
