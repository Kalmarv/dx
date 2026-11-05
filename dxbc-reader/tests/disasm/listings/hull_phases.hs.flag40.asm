hs_5_0
hs_decls 
dcl_input_control_point_count 3
dcl_output_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_tessellator_partitioning partitioning_integer
dcl_tessellator_output_primitive output_triangle_cw
dcl_hs_max_tessfactor l(64.000000)
dcl_globalFlags refactoringAllowed
dcl_immediateConstantBuffer { { 5.000000, 2.000000, 0, 0},
                              { 0, 3.000000, 0, 0},
                              { 0, 4.000000, 0, 0} }
hs_control_point_phase 
dcl_input vOutputControlPointID
dcl_input v[3][0].xyzw
dcl_output o0.xyzw
dcl_temps 2
mov r0.zw, l(0,0,0.250000,0)
mov r1.x, vOutputControlPointID
utof r0.x, vOutputControlPointID
mul r0.y, r0.x, l(0.500000)
add o0.xyzw, r0.xyzw, v[r1.x + 0][0].xyzw
ret 
hs_fork_phase 
dcl_hs_fork_phase_instance_count 3
dcl_input vForkInstanceID
dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
dcl_temps 1
dcl_indexrange o0.x 3
mov r0.x, vForkInstanceID.x
mov o[r0.x + 0].x, icb[r0.x + 0].y
ret 
hs_fork_phase 
dcl_output_siv o3.x, finalTriInsideTessFactor
mov o3.x, l(5.000000)
ret 
hs_fork_phase 
dcl_input vPrim
dcl_input vicp[3][0].x
dcl_output o4.x
dcl_temps 1
add r0.x, vicp[2][0].x, vicp[0][0].x
utof r0.y, vPrim
add o4.x, r0.y, r0.x
ret 
hs_fork_phase 
dcl_input vicp[3][0].y
dcl_output o4.y
add o4.y, vicp[2][0].y, vicp[0][0].y
ret 
hs_fork_phase 
dcl_input vicp[3][0].z
dcl_output o4.z
add o4.z, vicp[2][0].z, vicp[0][0].z
ret 
hs_fork_phase 
dcl_input vicp[3][0].w
dcl_output o4.w
add o4.w, vicp[2][0].w, vicp[0][0].w
ret 
