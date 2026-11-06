    vs_3_0
      0x000002E4:     dcl_position v0
      0x000002F0:     dcl_position o0
   0  0x000002FC:     mov r0, c0
   1  0x00000308:     mad r1, v0.yzwx, r0.yzwx, c3
   2  0x0000031C:     mov r2, c2
   3  0x00000328:     mad r1, r1, r2.zwxy, c1.yzwx
   4  0x0000033C:     mad r0, r1, c1.zwxy, -r0.wxyz
   5  0x00000350:     mul r0, r0.wxyz, r0
   6  0x00000360:     mad o0, r0, r2, c3

// approximately 7 instruction slots used
