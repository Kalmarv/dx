      0x00000000: vs_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB0[6], dynamicIndexed
      0x0000001C: dcl_input v0.xyz
      0x00000028: dcl_input v1.x
      0x00000034: dcl_output_siv o0.xyzw, position
      0x00000044: dcl_temps 2
   0  0x0000004C: mov o0.w, l(0x3f800000)
   1  0x00000060: imul null, r0.x, v1.x, l(0x00000003)
   2  0x00000080: mov r1.xyz, v0.xyzx
   3  0x00000094: mov r1.w, l(0x3f800000)
   4  0x000000A8: dp4 o0.x, cb0[r0.x + 0].xyzw, r1.xyzw
   5  0x000000CC: imad r0.xy, v1.xxxx, l(0x00000003, 0x00000003, 0x00000000, 0x00000000), l(0x00000001, 0x00000002, 0x00000000, 0x00000000)
   6  0x00000108: dp4 o0.y, cb0[r0.x + 0].xyzw, r1.xyzw
   7  0x0000012C: dp4 o0.z, cb0[r0.y + 0].xyzw, r1.xyzw
   8  0x00000150: ret 
