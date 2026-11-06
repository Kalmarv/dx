      hs_5_0
      hs_decls 
      dcl_input_control_point_count 3
      dcl_output_control_point_count 3
      dcl_tessellator_domain domain_tri
      dcl_tessellator_partitioning partitioning_integer
      dcl_tessellator_output_primitive output_triangle_cw
      dcl_globalFlags refactoringAllowed
   0: hs_fork_phase 
      dcl_hs_fork_phase_instance_count 3
      dcl_input vForkInstanceID
      dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      dcl_temps 1
      dcl_indexrange o0.x 3
   1: mov r0.x, vForkInstanceID.x
   2: mov o[r0.x + 0].x, l(2.000000)
   3: ret 
   4: hs_fork_phase 
      dcl_output_siv o3.x, finalTriInsideTessFactor
   5: mov o3.x, l(2.000000)
   6: ret 
   7: hs_fork_phase 
      dcl_input vicp[3][1].x
      dcl_output o4.x
   8: mov o4.x, vicp[0][1].x
   9: ret 
  10: hs_fork_phase 
      dcl_input vicp[3][1].y
      dcl_output o4.y
  11: mov o4.y, vicp[0][1].y
  12: ret 
  13: hs_fork_phase 
      dcl_input vicp[3][1].z
      dcl_output o4.z
  14: mov o4.z, vicp[0][1].z
  15: ret 
  16: hs_fork_phase 
      dcl_output o4.w
  17: mov o4.w, l(1.000000)
  18: ret 
