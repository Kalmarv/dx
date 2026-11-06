      0x00000000: hs_5_0
      0x00000008: hs_decls 
      0x0000000C: dcl_input_control_point_count 3
      0x00000010: dcl_output_control_point_count 3
      0x00000014: dcl_tessellator_domain domain_tri
      0x00000018: dcl_tessellator_partitioning partitioning_integer
      0x0000001C: dcl_tessellator_output_primitive output_point
      0x00000020: dcl_globalFlags refactoringAllowed | skipOptimization
   0  0x00000024: hs_control_point_phase 
   1  0x00000028: ret 
   2  0x0000002C: hs_join_phase 
      0x00000030: dcl_input vicp[3][0].xyz
      0x00000040: dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      0x00000050: dcl_output o0.yzw
      0x0000005C: dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      0x0000006C: dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      0x0000007C: dcl_output_siv o3.x, finalTriInsideTessFactor
      0x0000008C: dcl_temps 2
   3  0x00000094: mov r0.x, vicp[0][0].x
   4  0x000000AC: mov r0.x, r0.x
   5  0x000000C0: mov r0.x, r0.x
   6  0x000000D4: itof r0.y, l(0x00000001)
   7  0x000000E8: mov r1.xyz, vicp[1][0].xyzx
   8  0x00000100: mov o0.yzw, r1.xxyz
   9  0x00000114: mov o0.x, r0.x
  10  0x00000128: mov o1.x, r0.x
  11  0x0000013C: mov o2.x, r0.x
  12  0x00000150: mov o3.x, r0.y
  13  0x00000164: ret 
