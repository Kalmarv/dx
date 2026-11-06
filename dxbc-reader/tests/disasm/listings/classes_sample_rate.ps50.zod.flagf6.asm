      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
      0x0000001C: dcl_function_body fb0
      0x00000024: dcl_function_table ft0 = {fb0}
      0x00000034: dcl_interface fp0[1][1] = {ft0}
      0x00000048: dcl_input_ps linear v0.xyz
      0x00000054: dcl_input_ps_sgv constant v1.x, sampleIndex
      0x00000064: dcl_output o0.xyzw
      0x00000070: dcl_temps 2
   0  0x00000078: nop 
   1  0x0000007C: mov r0.xyz, v0.xyzx
   2  0x00000090: fcall fp0[0][0]
   3  0x000000A4: utof r0.xyz, v1.xxxx
   4  0x000000B8: mul o0.xyz, r0.xyzx, r1.xyzx
   5  0x000000D4: itof o0.w, l(0x00000001)
   6  0x000000E8: ret 
   7  0x000000EC: label fb0
   8  0x000000F8: nop 
   9  0x000000FC: mov r0.w, this[0].y
  10  0x00000110: mov r1.w, this[0].x
  11  0x00000124: mul r1.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xxxx
  12  0x0000014C: ret 
