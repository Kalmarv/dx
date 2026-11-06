hs_5_0
hs_decls 
dcl_input_control_point_count 16
dcl_output_control_point_count 4
dcl_tessellator_domain domain_quad
dcl_tessellator_partitioning partitioning_fractional_even
dcl_tessellator_output_primitive output_triangle_ccw
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[1], immediateIndexed
hs_control_point_phase 
dcl_input vOutputControlPointID
dcl_input vPrim
dcl_input v[16][0].xyzw
dcl_input v[16][1].xyz
dcl_output o0.xyzw
dcl_output o1.xyz
dcl_temps 1
ishl r0.x, vOutputControlPointID, l(2)
bfi r0.y, l(30), l(2), vOutputControlPointID, l(3)
utof r0.z, vPrim
mad o0.xyzw, v[r0.y + 0][0].xyzw, r0.zzzz, v[r0.x + 0][0].xyzw
mov r0.x, vOutputControlPointID
mov o1.xyz, v[r0.x + 0][1].xyzx
ret 
hs_fork_phase 
dcl_input vicp[16][0].w
dcl_output_siv o0.x, finalQuadUeq0EdgeTessFactor
add o0.x, cb0[0].x, vicp[0][0].w
ret 
hs_fork_phase 
dcl_input vicp[16][0].w
dcl_output_siv o1.x, finalQuadVeq0EdgeTessFactor
add o1.x, cb0[0].y, vicp[4][0].w
ret 
hs_fork_phase 
dcl_input vicp[16][0].w
dcl_output_siv o2.x, finalQuadUeq1EdgeTessFactor
add o2.x, cb0[0].z, vicp[8][0].w
ret 
hs_fork_phase 
dcl_input vicp[16][0].w
dcl_output_siv o3.x, finalQuadVeq1EdgeTessFactor
add o3.x, cb0[0].w, vicp[12][0].w
ret 
hs_fork_phase 
dcl_output_siv o4.x, finalQuadUInsideTessFactor
mov o4.x, cb0[0].x
ret 
hs_fork_phase 
dcl_output_siv o5.x, finalQuadVInsideTessFactor
mov o5.x, cb0[0].y
ret 
