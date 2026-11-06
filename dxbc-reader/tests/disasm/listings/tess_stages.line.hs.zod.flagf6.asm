      0x00000000: hs_5_0
      0x00000008: hs_decls 
      0x0000000C: dcl_input_control_point_count 2
      0x00000010: dcl_output_control_point_count 2
      0x00000014: dcl_tessellator_domain domain_isoline
      0x00000018: dcl_tessellator_partitioning partitioning_pow2
      0x0000001C: dcl_tessellator_output_primitive output_line
      0x00000020: dcl_globalFlags refactoringAllowed | skipOptimization
   0  0x00000024: hs_control_point_phase 
      0x00000028: dcl_input vOutputControlPointID
      0x00000030: dcl_input v[2][0].xyzw
      0x00000040: dcl_input v[2][1].xyz
      0x00000050: dcl_output o0.xyzw
      0x0000005C: dcl_output o1.xyz
      0x00000068: dcl_temps 1
   1  0x00000070: mov r0.x, vOutputControlPointID
   2  0x00000080: mov o0.xyzw, v[r0.x + 0][0].xyzw
   3  0x0000009C: mov o1.xyz, v[r0.x + 0][1].xyzx
   4  0x000000B8: ret 
   5  0x000000BC: hs_join_phase 
      0x000000C0: dcl_output_siv o0.x, finalLineDensityTessFactor
      0x000000D0: dcl_output_siv o1.x, finalLineDetailTessFactor
      0x000000E0: dcl_temps 1
   6  0x000000E8: itof r0.x, l(0x00000008)
   7  0x000000FC: itof r0.y, l(0x00000001)
   8  0x00000110: mov o0.x, r0.x
   9  0x00000124: mov o1.x, r0.y
  10  0x00000138: ret 
