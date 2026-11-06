hs_5_0
hs_decls 
dcl_input_control_point_count 3
dcl_output_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_tessellator_partitioning partitioning_integer
dcl_tessellator_output_primitive output_triangle_cw
dcl_hs_max_tessfactor l(16.000000)
dcl_globalFlags refactoringAllowed
dcl_immediateConstantBuffer { { 0x40800000, 0x40000000, 0x00000000, 0x00000000},
                              { 0x41800000, 0x40400000, 0x00000000, 0x00000000} }
hs_control_point_phase 
dcl_input vOutputControlPointID
dcl_input v[3][0].xyz
dcl_input v[3][1].xyzw
dcl_output o0.xyz
dcl_output o1.xyzw
dcl_temps 1
utof r0.z, vOutputControlPointID
mov r0.xy, l(0x00000000,0x00000000,0x00000000,0x00000000)
mov r0.w, vOutputControlPointID
add o0.xyz, r0.xyzx, v[r0.w + 0][0].xyzx
mov o1.xyzw, v[r0.w + 0][1].xyzw
ret 
hs_fork_phase 
dcl_hs_fork_phase_instance_count 2
dcl_input vForkInstanceID
dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
dcl_temps 1
dcl_indexrange o0.x 2
mov r0.x, vForkInstanceID.x
mov o[r0.x + 0].x, icb[r0.x + 0].y
ret 
hs_fork_phase 
dcl_input vPrim
dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
dcl_temps 1
utof r0.x, vPrim
add r0.x, r0.x, l(0x40800000)
min o2.x, r0.x, l(0x41800000)
ret 
hs_fork_phase 
dcl_output_siv o3.x, finalTriInsideTessFactor
mov o3.x, l(0x40a00000)
ret 
hs_fork_phase 
dcl_input vicp[3][0].x
dcl_output o0.y
dcl_temps 1
add r0.x, vicp[1][0].x, vicp[0][0].x
add r0.x, r0.x, vicp[2][0].x
mul o0.y, r0.x, l(0x3eaaaaab)
ret 
hs_fork_phase 
dcl_input vicp[3][0].y
dcl_output o0.z
dcl_temps 1
add r0.x, vicp[1][0].y, vicp[0][0].y
add r0.x, r0.x, vicp[2][0].y
mul o0.z, r0.x, l(0x3eaaaaab)
ret 
hs_fork_phase 
dcl_input vicp[3][0].z
dcl_output o0.w
dcl_temps 1
add r0.x, vicp[1][0].z, vicp[0][0].z
add r0.x, r0.x, vicp[2][0].z
mul o0.w, r0.x, l(0x3eaaaaab)
ret 
