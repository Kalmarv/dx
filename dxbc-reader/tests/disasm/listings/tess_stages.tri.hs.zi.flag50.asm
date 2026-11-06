hs_5_0
hs_decls 
dcl_input_control_point_count 3
dcl_output_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_tessellator_partitioning partitioning_fractional_odd
dcl_tessellator_output_primitive output_triangle_cw
dcl_hs_max_tessfactor l(15.000000)
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[1], immediateIndexed
hs_control_point_phase 
dcl_input vOutputControlPointID
dcl_input v[3][0].xyzw
dcl_input v[3][1].xyz
dcl_output o0.xyzw
dcl_output o1.xyz
dcl_temps 1
mov r0.x, vOutputControlPointID
mad o0.xyz, v[r0.x + 0][1].xyzx, cb0[0].xxxx, v[r0.x + 0][0].xyzx
mov o0.w, v[r0.x + 0][0].w
mov o1.xyz, v[r0.x + 0][1].xyzx
ret 
hs_fork_phase 
dcl_input vicp[3][0].xyzw
dcl_input vocp[3][0].xyzw
dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
dcl_temps 1
add r0.xyzw, -vicp[1][0].xyzw, vocp[0][0].xyzw
dp4 r0.x, r0.xyzw, r0.xyzw
sqrt r0.x, r0.x
mul r0.x, r0.x, cb0[0].x
min o0.x, r0.x, l(15.000000)
ret 
hs_fork_phase 
dcl_input vicp[3][0].xyzw
dcl_input vocp[3][0].xyzw
dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
dcl_temps 1
add r0.xyzw, -vicp[2][0].xyzw, vocp[1][0].xyzw
dp4 r0.x, r0.xyzw, r0.xyzw
sqrt r0.x, r0.x
mul r0.x, r0.x, cb0[0].y
min o1.x, r0.x, l(15.000000)
ret 
hs_fork_phase 
dcl_input vicp[3][0].xyzw
dcl_input vocp[3][0].xyzw
dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
dcl_temps 1
add r0.xyzw, -vicp[0][0].xyzw, vocp[2][0].xyzw
dp4 r0.x, r0.xyzw, r0.xyzw
sqrt r0.x, r0.x
mul r0.x, r0.x, cb0[0].z
min o2.x, r0.x, l(15.000000)
ret 
hs_fork_phase 
dcl_input vPrim
dcl_output_siv o3.x, finalTriInsideTessFactor
dcl_temps 1
utof r0.x, vPrim
add r0.x, r0.x, cb0[0].w
min o3.x, r0.x, l(15.000000)
ret 
hs_fork_phase 
dcl_input vicp[3][0].x
dcl_output o0.y
dcl_temps 1
add r0.x, vicp[1][0].x, vicp[0][0].x
add r0.x, r0.x, vicp[2][0].x
mul o0.y, r0.x, l(0.333333)
ret 
hs_fork_phase 
dcl_input vicp[3][0].y
dcl_output o0.z
dcl_temps 1
add r0.x, vicp[1][0].y, vicp[0][0].y
add r0.x, r0.x, vicp[2][0].y
mul o0.z, r0.x, l(0.333333)
ret 
hs_fork_phase 
dcl_input vicp[3][0].z
dcl_output o0.w
dcl_temps 1
add r0.x, vicp[1][0].z, vicp[0][0].z
add r0.x, r0.x, vicp[2][0].z
mul o0.w, r0.x, l(0.333333)
ret 
