      vs_4_0
      dcl_constantbuffer CB0[8], immediateIndexed
      dcl_constantbuffer CB1[1], immediateIndexed
      dcl_input v0.xyz
      dcl_input v1.xyz
      dcl_input v2.xy
      dcl_output_siv o0.xyzw, position
      dcl_output o1.xyzw
      dcl_output o2.xy
      dcl_temps 1
   0: mul r0.xyz, v0.xyzx, cb1[0].xyzx
   1: mov r0.w, l(1.000000)
   2: dp4 o0.x, r0.xyzw, cb0[0].xyzw
   3: dp4 o0.y, r0.xyzw, cb0[1].xyzw
   4: dp4 o0.z, r0.xyzw, cb0[2].xyzw
   5: dp4 o0.w, r0.xyzw, cb0[3].xyzw
   6: dp3_sat r0.x, v1.xyzx, cb0[5].xyzx
   7: mul r0.x, r0.x, cb0[5].w
   8: dp3_sat r0.y, v1.xyzx, cb0[4].xyzx
   9: mad r0.x, r0.y, cb0[4].w, r0.x
  10: dp3_sat r0.y, v1.xyzx, cb0[6].xyzx
  11: mad r0.x, r0.y, cb0[6].w, r0.x
  12: dp3_sat r0.y, v1.xyzx, cb0[7].xyzx
  13: mad o1.xyz, r0.yyyy, cb0[7].wwww, r0.xxxx
  14: mov o1.w, l(1.000000)
  15: mov o2.xy, v2.xyxx
  16: ret 
