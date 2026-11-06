      vs_5_0
      dcl_globalFlags refactoringAllowed
      dcl_constantbuffer CB0[6], dynamicIndexed
      dcl_input v0.xyz
      dcl_input v1.x
      dcl_output_siv o0.xyzw, position
      dcl_temps 2
   0: mov o0.w, l(1.000000)
   1: imul null, r0.x, v1.x, l(3)
   2: mov r1.xyz, v0.xyzx
   3: mov r1.w, l(1.000000)
   4: dp4 o0.x, cb0[r0.x + 0].xyzw, r1.xyzw
   5: imad r0.xy, v1.xxxx, l(3, 3, 0, 0), l(1, 2, 0, 0)
   6: dp4 o0.y, cb0[r0.x + 0].xyzw, r1.xyzw
   7: dp4 o0.z, cb0[r0.y + 0].xyzw, r1.xyzw
   8: ret 
