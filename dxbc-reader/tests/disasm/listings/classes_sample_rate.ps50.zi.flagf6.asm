      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
      0x0000001C: dcl_function_table ft0 = {}
      0x00000028: dcl_interface fp0[1][0] = {ft0}
      0x0000003C: dcl_input_ps linear v0.xyz
      0x00000048: dcl_input_ps_sgv constant v1.x, sampleIndex
      0x00000058: dcl_output o0.xyzw
      0x00000064: dcl_temps 1
   0  0x0000006C: mov r0.xy, this[0].yxyy
   1  0x00000080: mul r0.xyz, v0.xyzx, cb[r0.y + 0][r0.x + 0].xxxx
   2  0x000000A8: utof r0.w, v1.x
   3  0x000000BC: mul o0.xyz, r0.wwww, r0.xyzx
   4  0x000000D8: mov o0.w, l(0x3f800000)
   5  0x000000EC: ret 
