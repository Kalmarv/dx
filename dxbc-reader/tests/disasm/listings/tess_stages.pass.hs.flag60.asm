0x00000000: hs_5_0
0x00000008: hs_decls 
0x0000000C: dcl_input_control_point_count 3
0x00000010: dcl_output_control_point_count 3
0x00000014: dcl_tessellator_domain domain_tri
0x00000018: dcl_tessellator_partitioning partitioning_integer
0x0000001C: dcl_tessellator_output_primitive output_point
0x00000020: dcl_globalFlags refactoringAllowed
0x00000024: hs_control_point_phase 
0x00000028: ret 
0x0000002C: hs_fork_phase 
0x00000030: dcl_hs_fork_phase_instance_count 3
0x00000038: dcl_input vForkInstanceID
0x00000040: dcl_input vicp[3][0].x
0x00000050: dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
0x00000060: dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
0x00000070: dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
0x00000080: dcl_temps 1
0x00000088: dcl_indexrange o0.x 3
0x00000098: mov r0.x, vForkInstanceID.x
0x000000A8: mov o[r0.x + 0].x, vicp[0][0].x
0x000000C4: ret 
0x000000C8: hs_fork_phase 
0x000000CC: dcl_output_siv o3.x, finalTriInsideTessFactor
0x000000DC: mov o3.x, l(1.000000)
0x000000F0: ret 
0x000000F4: hs_fork_phase 
0x000000F8: dcl_input vicp[3][0].x
0x00000108: dcl_output o0.y
0x00000114: mov o0.y, vicp[1][0].x
0x0000012C: ret 
0x00000130: hs_fork_phase 
0x00000134: dcl_input vicp[3][0].y
0x00000144: dcl_output o0.z
0x00000150: mov o0.z, vicp[1][0].y
0x00000168: ret 
0x0000016C: hs_fork_phase 
0x00000170: dcl_input vicp[3][0].z
0x00000180: dcl_output o0.w
0x0000018C: mov o0.w, vicp[1][0].z
0x000001A4: ret 
