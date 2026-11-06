      ps_5_0
      dcl_globalFlags refactoringAllowed
      dcl_constantbuffer CB0[3], immediateIndexed
      dcl_output o0.xyzw
      dcl_output o1.xyzw
      dcl_output o2.xyzw
      dcl_output o3.xyzw
      dcl_output o4.xyzw
   0: min o0.x, cb0[0].y, cb0[0].x
   1: max o0.yw, cb0[0].yyyy, cb0[0].xxxx
   2: mov_sat o0.z, cb0[0].x
   3: udiv o1.xz, null, cb0[1].xxzx, cb0[1].yywy
   4: udiv null, o1.yw, cb0[1].xxxz, cb0[1].yyyw
   5: ftoi o2.xz, cb0[0].xxzx
   6: ftou o2.yw, cb0[0].xxxz
   7: ishl o3.x, cb0[1].x, cb0[1].y
   8: ushr o3.y, cb0[1].x, cb0[1].y
   9: ishr o3.z, cb0[2].x, cb0[2].y
  10: and o3.w, cb0[1].y, cb0[1].x
  11: div o4.x, cb0[0].x, cb0[0].w
  12: sqrt o4.y, cb0[0].z
  13: log o4.z, cb0[0].w
  14: mul o4.w, cb0[0].y, cb0[0].y
  15: ret 
