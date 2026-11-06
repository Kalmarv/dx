      0x00000000: hs_5_0
      0x00000008: hs_decls 
      0x0000000C: dcl_input_control_point_count 2
      0x00000010: dcl_output_control_point_count 2
      0x00000014: dcl_tessellator_domain domain_isoline
      0x00000018: dcl_tessellator_partitioning partitioning_pow2
      0x0000001C: dcl_tessellator_output_primitive output_line
      0x00000020: dcl_globalFlags refactoringAllowed
      0x00000024: dcl_immediateConstantBuffer { { 0x41000000, 0x00000000, 0x00000000, 0x00000000},
                              { 0x3f800000, 0x00000000, 0x00000000, 0x00000000} }
   0  0x0000004C: hs_fork_phase 
      0x00000050: dcl_hs_fork_phase_instance_count 2
      0x00000058: dcl_input vForkInstanceID
      0x00000060: dcl_output_siv o0.x, finalLineDensityTessFactor
      0x00000070: dcl_output_siv o1.x, finalLineDetailTessFactor
      0x00000080: dcl_temps 1
      0x00000088: dcl_indexrange o0.x 2
   1  0x00000098: mov r0.x, vForkInstanceID.x
   2  0x000000A8: mov o[r0.x + 0].x, icb[r0.x + 0].x
   3  0x000000C4: ret 
