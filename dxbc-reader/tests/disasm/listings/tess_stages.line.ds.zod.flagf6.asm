      0x00000000: ds_5_0
      0x00000008: dcl_input_control_point_count 2
      0x0000000C: dcl_tessellator_domain domain_isoline
      0x00000010: dcl_globalFlags refactoringAllowed | skipOptimization
      0x00000014: dcl_input_siv vpc0.x, finalLineDensityTessFactor
      0x00000024: dcl_input vDomain.x
      0x0000002C: dcl_input vicp[2][0].xyzw
      0x0000003C: dcl_input vicp[2][1].xyz
      0x0000004C: dcl_output_siv o0.xyzw, position
      0x0000005C: dcl_output o1.xyz
      0x00000068: dcl_temps 2
   0  0x00000070: mov r0.xyzw, -vicp[0][0].xyzw
   1  0x0000008C: add r0.xyzw, r0.xyzw, vicp[1][0].xyzw
   2  0x000000AC: mul r0.xyzw, r0.xyzw, vDomain.xxxx
   3  0x000000C4: add r0.xyzw, r0.xyzw, vicp[0][0].xyzw
   4  0x000000E4: mul r0.xyzw, r0.xyzw, vpc0.xxxx
   5  0x00000100: mov r1.xyz, vicp[0][1].xyzx
   6  0x00000118: mov o0.xyzw, r0.xyzw
   7  0x0000012C: mov o1.xyz, r1.xyzx
   8  0x00000140: ret 
