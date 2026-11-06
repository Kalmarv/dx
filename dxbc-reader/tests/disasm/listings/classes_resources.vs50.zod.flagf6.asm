      0x00000000: vs_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[2], immediateIndexed
      0x0000001C: dcl_function_body fb0
      0x00000024: dcl_function_body fb1
      0x0000002C: dcl_function_table ft0 = {fb0}
      0x0000003C: dcl_function_table ft1 = {fb1}
      0x0000004C: dcl_interface fp0[1][1] = {ft0, ft1}
      0x00000064: dcl_input v0.xyzw
      0x00000070: dcl_output_siv o0.xyzw, position
      0x00000080: dcl_temps 2
   0  0x00000088: nop 
   1  0x0000008C: mov r0.xyzw, v0.wzyx
   2  0x000000A0: fcall fp0[0][0]
   3  0x000000B4: mov o0.xyzw, r0.xyzw
   4  0x000000C8: ret 
   5  0x000000CC: label fb0
   6  0x000000D8: nop 
   7  0x000000DC: mov r0.xyzw, r0.xyzw
   8  0x000000F0: ret 
   9  0x000000F4: label fb1
  10  0x00000100: nop 
  11  0x00000104: mov r1.x, this[0].y
  12  0x00000118: mov r1.y, this[0].x
  13  0x0000012C: mul r0.xyzw, r0.wzyx, cb[r1.y + 0][r1.x + 0].xyzw
  14  0x00000154: ret 
