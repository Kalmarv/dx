      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB0[2], immediateIndexed
      0x0000001C: dcl_input_ps linear v0.xyzw
      0x00000028: dcl_input_ps linear v1.xyzw
      0x00000034: dcl_input_ps linear v2.xyz
      0x00000040: dcl_input_ps linear v3.xyzw
      0x0000004C: dcl_input_ps linear v5.xyz
      0x00000058: dcl_input_ps linear v6.xyz
      0x00000064: dcl_output o0.xyzw
      0x00000070: dcl_temps 2
   0  0x00000078: add r0.xyz, v2.xyzx, v5.xyzx
   1  0x00000094: dp3 r0.w, r0.xyzx, r0.xyzx
   2  0x000000B0: rsq r0.w, r0.w
   3  0x000000C4: mul r0.xyz, r0.wwww, r0.xyzx
   4  0x000000E0: dp3_sat r0.x, r0.xyzx, cb0[0].xyzx
   5  0x00000100: mul r0.xyz, r0.xxxx, cb0[1].xyzx
   6  0x00000120: dp3_sat r0.w, v6.xyzx, cb0[0].xyzx
   7  0x00000140: mul r1.xyz, r0.wwww, cb0[1].xyzx
   8  0x00000160: mad r0.xyz, r0.xyzx, cb0[1].wwww, r1.xyzx
   9  0x00000188: mov r0.w, l(0x3f800000)
  10  0x0000019C: mul r1.xyzw, v0.xyzw, l(0x41080000, 0x41080000, 0x41080000, 0x41080000)
  11  0x000001C4: mad r0.xyzw, r0.xyzw, v3.xyzw, r1.xyzw
  12  0x000001E8: mad o0.xyzw, v1.xyzw, l(0x40800000, 0x40800000, 0x40800000, 0x40800000), r0.xyzw
  13  0x00000218: ret 
