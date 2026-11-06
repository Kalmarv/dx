      0x00000000: vs_5_1
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[2:2][4], immediateIndexed, space=0
      0x00000028: dcl_constantbuffer CB1[0:7][1], dynamicIndexed, space=1
      0x00000044: dcl_input v0.xyz
      0x00000050: dcl_input_sgv v1.x, instance_id
      0x00000060: dcl_output_siv o0.xyzw, position
      0x00000070: dcl_temps 2
   0  0x00000078: itof r0.w, l(0x00000001)
   1  0x0000008C: mov r1.x, l(0x00000007)
   2  0x000000A0: and r1.x, r1.x, v1.x
   3  0x000000BC: mov r0.xyz, v0.xyzx
   4  0x000000D0: mul r0.xyzw, r0.xyzw, CB1[r1.x + 0][0].xyzw
   5  0x000000F8: dp4 o0.x, r0.xyzw, CB0[2][0].xyzw
   6  0x0000011C: dp4 o0.y, r0.xyzw, CB0[2][1].xyzw
   7  0x00000140: dp4 o0.z, r0.xyzw, CB0[2][2].xyzw
   8  0x00000164: dp4 o0.w, r0.xyzw, CB0[2][3].xyzw
   9  0x00000188: ret 
