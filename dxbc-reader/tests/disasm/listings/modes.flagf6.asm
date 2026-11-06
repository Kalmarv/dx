      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB0[3], immediateIndexed
      0x0000001C: dcl_output o0.xyzw
      0x00000028: dcl_output o1.xyzw
      0x00000034: dcl_output o2.xyzw
      0x00000040: dcl_output o3.xyzw
      0x0000004C: dcl_output o4.xyzw
   0  0x00000058: min o0.x, cb0[0].y, cb0[0].x
   1  0x0000007C: max o0.yw, cb0[0].yyyy, cb0[0].xxxx
   2  0x000000A0: mov_sat o0.z, cb0[0].x
   3  0x000000B8: udiv o1.xz, null, cb0[1].xxzx, cb0[1].yywy
   4  0x000000E0: udiv null, o1.yw, cb0[1].xxxz, cb0[1].yyyw
   5  0x00000108: ftoi o2.xz, cb0[0].xxzx
   6  0x00000120: ftou o2.yw, cb0[0].xxxz
   7  0x00000138: ishl o3.x, cb0[1].x, cb0[1].y
   8  0x0000015C: ushr o3.y, cb0[1].x, cb0[1].y
   9  0x00000180: ishr o3.z, cb0[2].x, cb0[2].y
  10  0x000001A4: and o3.w, cb0[1].y, cb0[1].x
  11  0x000001C8: div o4.x, cb0[0].x, cb0[0].w
  12  0x000001EC: sqrt o4.y, cb0[0].z
  13  0x00000204: log o4.z, cb0[0].w
  14  0x0000021C: mul o4.w, cb0[0].y, cb0[0].y
  15  0x00000240: ret 
