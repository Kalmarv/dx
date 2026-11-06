hs_5_0
hs_decls 
dcl_input_control_point_count 3
dcl_output_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_tessellator_partitioning partitioning_integer
dcl_tessellator_output_primitive output_triangle_cw
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[1], immediateIndexed
dcl_function_body fb0
dcl_function_body fb1
dcl_function_table ft0 = {fb0}
dcl_function_table ft1 = {fb1}
dcl_interface fp0[1][1] = {ft0, ft1}
hs_join_phase 
dcl_input vicp[3][0].x
dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
dcl_output_siv o3.x, finalTriInsideTessFactor
dcl_temps 1
fcall fp0[0][0]
mov o0.x, r0.x
mov o1.x, r0.x
mov o2.x, r0.x
mov o3.x, l(0x3f800000)
ret 
label fb0
mov r0.x, vicp[0][0].x
ret 
label fb1
mov r0.yz, this[0].yyxy
mul r0.x, cb[r0.z + 0][r0.y + 0].x, vicp[0][0].x
ret 
