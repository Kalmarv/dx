      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | enable11_1DoubleExtensions
      0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
      0x0000001C: dcl_output o0.xyzw
      0x00000028: dcl_temps 2
   0  0x00000030: dmul r0.xy, cb0[0].zwzw, d(0x00000000, 0x40590000, 0x00000000, 0x00000000)
   1  0x0000005C: dadd r0.xy, r0.xyxy, d(0x00000000, 0x3fc00000, 0x00000000, 0x00000000)
   2  0x00000084: dtof r0.y, r0.xyxy
   3  0x00000098: ddiv r1.xy, cb0[0].xyxy, d(0x00000000, 0x40080000, 0x00000000, 0x00000000)
   4  0x000000C4: dmul r1.zw, r1.xyxy, d(0x00000000, 0x00000000, 0x00000000, 0xc0040000)
   5  0x000000EC: dtof r0.xz, r1.xyzw
   6  0x00000100: mov r0.w, l(0x3f800000)
   7  0x00000114: mov o0.xyzw, r0.xyzw
   8  0x00000128: ret 
