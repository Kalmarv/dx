hs_5_0
hs_decls 
dcl_input_control_point_count 3
dcl_output_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_tessellator_partitioning partitioning_integer
dcl_tessellator_output_primitive output_point
dcl_globalFlags refactoringAllowed
hs_control_point_phase 
ret 
hs_fork_phase 
dcl_hs_fork_phase_instance_count 3
dcl_input vForkInstanceID
dcl_input vicp[3][0].x
dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
dcl_temps 1
dcl_indexrange o0.x 3
mov r0.x, vForkInstanceID.x
mov o[r0.x + 0].x, vicp[0][0].x
ret 
hs_fork_phase 
dcl_output_siv o3.x, finalTriInsideTessFactor
mov o3.x, l(0x3f800000)
ret 
hs_fork_phase 
dcl_input vicp[3][0].x
dcl_output o0.y
mov o0.y, vicp[1][0].x
ret 
hs_fork_phase 
dcl_input vicp[3][0].y
dcl_output o0.z
mov o0.z, vicp[1][0].y
ret 
hs_fork_phase 
dcl_input vicp[3][0].z
dcl_output o0.w
mov o0.w, vicp[1][0].z
ret 
