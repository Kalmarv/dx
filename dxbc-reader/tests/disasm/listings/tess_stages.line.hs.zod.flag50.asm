hs_5_0
hs_decls 
dcl_input_control_point_count 2
dcl_output_control_point_count 2
dcl_tessellator_domain domain_isoline
dcl_tessellator_partitioning partitioning_pow2
dcl_tessellator_output_primitive output_line
dcl_globalFlags refactoringAllowed | skipOptimization
hs_control_point_phase 
dcl_input vOutputControlPointID
dcl_input v[2][0].xyzw
dcl_input v[2][1].xyz
dcl_output o0.xyzw
dcl_output o1.xyz
dcl_temps 1
mov r0.x, vOutputControlPointID
mov o0.xyzw, v[r0.x + 0][0].xyzw
mov o1.xyz, v[r0.x + 0][1].xyzx
ret 
hs_join_phase 
dcl_output_siv o0.x, finalLineDensityTessFactor
dcl_output_siv o1.x, finalLineDetailTessFactor
dcl_temps 1
itof r0.x, l(8)
itof r0.y, l(1)
mov o0.x, r0.x
mov o1.x, r0.y
ret 
