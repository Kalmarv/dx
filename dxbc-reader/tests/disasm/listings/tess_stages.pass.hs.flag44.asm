      hs_5_0
      hs_decls 
      dcl_input_control_point_count 3
      dcl_output_control_point_count 3
      dcl_tessellator_domain domain_tri
      dcl_tessellator_partitioning partitioning_integer
      dcl_tessellator_output_primitive output_point
      dcl_globalFlags refactoringAllowed
   0: hs_control_point_phase 
   1: ret 
   2: hs_fork_phase 
      dcl_hs_fork_phase_instance_count 3
      dcl_input vForkInstanceID
      dcl_input vicp[3][0].x
      dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      dcl_temps 1
      dcl_indexrange o0.x 3
   3: mov r0.x, vForkInstanceID.x
   4: mov o[r0.x + 0].x, vicp[0][0].x
   5: ret 
   6: hs_fork_phase 
      dcl_output_siv o3.x, finalTriInsideTessFactor
   7: mov o3.x, l(1.000000)
   8: ret 
   9: hs_fork_phase 
      dcl_input vicp[3][0].x
      dcl_output o0.y
  10: mov o0.y, vicp[1][0].x
  11: ret 
  12: hs_fork_phase 
      dcl_input vicp[3][0].y
      dcl_output o0.z
  13: mov o0.z, vicp[1][0].y
  14: ret 
  15: hs_fork_phase 
      dcl_input vicp[3][0].z
      dcl_output o0.w
  16: mov o0.w, vicp[1][0].z
  17: ret 
