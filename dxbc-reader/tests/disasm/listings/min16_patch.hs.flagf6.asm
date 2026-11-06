      0x00000000: hs_5_0
      0x00000008: hs_decls 
      0x0000000C: dcl_input_control_point_count 3
      0x00000010: dcl_output_control_point_count 3
      0x00000014: dcl_tessellator_domain domain_tri
      0x00000018: dcl_tessellator_partitioning partitioning_integer
      0x0000001C: dcl_tessellator_output_primitive output_triangle_cw
      0x00000020: dcl_globalFlags refactoringAllowed | enableMinimumPrecision
   0  0x00000024: hs_fork_phase 
      0x00000028: dcl_hs_fork_phase_instance_count 3
      0x00000030: dcl_input vForkInstanceID
      0x00000038: dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      0x00000048: dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      0x00000058: dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      0x00000068: dcl_temps 1
      0x00000070: dcl_indexrange o0.x 3
   1  0x00000080: mov r0.x, vForkInstanceID.x
   2  0x00000090: mov o[r0.x + 0].x, l(0x40000000)
   3  0x000000A8: ret 
   4  0x000000AC: hs_fork_phase 
      0x000000B0: dcl_output_siv o3.x, finalTriInsideTessFactor
   5  0x000000C0: mov o3.x, l(0x40000000)
   6  0x000000D4: ret 
   7  0x000000D8: hs_fork_phase 
      0x000000DC: dcl_input vicp[3][1].x {min16f}
      0x000000F0: dcl_output o4.x {min16f}
   8  0x00000100: mov o4.x {min16f}, vicp[0][1].x {min16f}
   9  0x00000120: ret 
  10  0x00000124: hs_fork_phase 
      0x00000128: dcl_input vicp[3][1].y {min16f}
      0x0000013C: dcl_output o4.y {min16f}
  11  0x0000014C: mov o4.y {min16f}, vicp[0][1].y {min16f}
  12  0x0000016C: ret 
  13  0x00000170: hs_fork_phase 
      0x00000174: dcl_input vicp[3][1].z {min16f}
      0x00000188: dcl_output o4.z {min16f}
  14  0x00000198: mov o4.z {min16f}, vicp[0][1].z {min16f}
  15  0x000001B8: ret 
  16  0x000001BC: hs_fork_phase 
      0x000001C0: dcl_output o4.w {min16f}
  17  0x000001D0: mov o4.w {min16f}, l(0x3f800000) {def32 as min16f}
  18  0x000001E8: ret 
