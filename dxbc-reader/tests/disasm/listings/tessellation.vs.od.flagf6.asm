      0x00000000: vs_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[5], immediateIndexed
      0x0000001C: dcl_input v0.xyz
      0x00000028: dcl_input v1.xyzw
      0x00000034: dcl_output o0.xyz
      0x00000040: dcl_output o1.xyzw
      0x0000004C: dcl_temps 2
   0  0x00000054: mul r0.xyz, v0.xyzx, cb0[4].xxxx
   1  0x00000074: mov r1.xyzw, v1.xyzw
   2  0x00000088: mov o1.xyzw, r1.xyzw
   3  0x0000009C: mov o0.xyz, r0.xyzx
   4  0x000000B0: ret 
