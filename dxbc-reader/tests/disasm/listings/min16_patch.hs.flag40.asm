hs_5_0
hs_decls 
dcl_input_control_point_count 3
dcl_output_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_tessellator_partitioning partitioning_integer
dcl_tessellator_output_primitive output_triangle_cw
dcl_globalFlags refactoringAllowed | enableMinimumPrecision
hs_fork_phase 
dcl_hs_fork_phase_instance_count 3
dcl_input vForkInstanceID
dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
dcl_temps 1
dcl_indexrange o0.x 3
mov r0.x, vForkInstanceID.x
mov o[r0.x + 0].x, l(2.000000)
ret 
hs_fork_phase 
dcl_output_siv o3.x, finalTriInsideTessFactor
mov o3.x, l(2.000000)
ret 
hs_fork_phase 
dcl_input vicp[3][1].x {min16f}
dcl_output o4.x {min16f}
mov o4.x {min16f}, vicp[0][1].x {min16f}
ret 
hs_fork_phase 
dcl_input vicp[3][1].y {min16f}
dcl_output o4.y {min16f}
mov o4.y {min16f}, vicp[0][1].y {min16f}
ret 
hs_fork_phase 
dcl_input vicp[3][1].z {min16f}
dcl_output o4.z {min16f}
mov o4.z {min16f}, vicp[0][1].z {min16f}
ret 
hs_fork_phase 
dcl_output o4.w {min16f}
mov o4.w {min16f}, l(1.000000) {def32 as min16f}
ret 
