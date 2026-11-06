hs_5_0
hs_decls 
dcl_input_control_point_count 3
dcl_output_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_tessellator_partitioning partitioning_integer
dcl_tessellator_output_primitive output_point
dcl_globalFlags refactoringAllowed | skipOptimization
hs_control_point_phase 
ret 
hs_join_phase 
dcl_input vicp[3][0].xyz
dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
dcl_output o0.yzw
dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
dcl_output_siv o3.x, finalTriInsideTessFactor
dcl_temps 2
mov r0.x, vicp[0][0].x
mov r0.x, r0.x
mov r0.x, r0.x
itof r0.y, l(1)
mov r1.xyz, vicp[1][0].xyzx
mov o0.yzw, r1.xxyz
mov o0.x, r0.x
mov o1.x, r0.x
mov o2.x, r0.x
mov o3.x, r0.y
ret 
