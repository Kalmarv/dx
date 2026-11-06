hs_5_0
hs_decls 
dcl_input_control_point_count 3
dcl_output_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_tessellator_partitioning partitioning_integer
dcl_tessellator_output_primitive output_point
dcl_globalFlags refactoringAllowed
hs_control_point_phase 
//
// Initial variable locations:
//   v[0][0].x <- patch[0].p.x; v[0][0].y <- patch[0].p.y; v[0][0].z <- patch[0].p.z; v[0][0].w <- patch[0].p.w; 
//   v[0][1].x <- patch[0].n.x; v[0][1].y <- patch[0].n.y; v[0][1].z <- patch[0].n.z; 
//   v[1][0].x <- patch[1].p.x; v[1][0].y <- patch[1].p.y; v[1][0].z <- patch[1].p.z; v[1][0].w <- patch[1].p.w; 
//   v[1][1].x <- patch[1].n.x; v[1][1].y <- patch[1].n.y; v[1][1].z <- patch[1].n.z; 
//   v[2][0].x <- patch[2].p.x; v[2][0].y <- patch[2].p.y; v[2][0].z <- patch[2].p.z; v[2][0].w <- patch[2].p.w; 
//   v[2][1].x <- patch[2].n.x; v[2][1].y <- patch[2].n.y; v[2][1].z <- patch[2].n.z
//
#line 74 "C:\dx-fixtures\tess_stages.hlsl"
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

#line 80
mov r0.x, vForkInstanceID.x
mov o[r0.x + 0].x, vicp[0][0].x
ret 
hs_fork_phase 
dcl_output_siv o3.x, finalTriInsideTessFactor
mov o3.x, l(1.000000)  // o3.x <- <tri_pc_pass return value>.i
ret 
hs_fork_phase 
dcl_input vicp[3][0].x
dcl_output o0.y
mov o0.y, vicp[1][0].x  // o0.y <- <tri_pc_pass return value>.b.x
ret 
hs_fork_phase 
dcl_input vicp[3][0].y
dcl_output o0.z
mov o0.z, vicp[1][0].y  // o0.z <- <tri_pc_pass return value>.b.y
ret 
hs_fork_phase 
dcl_input vicp[3][0].z
dcl_output o0.w
mov o0.w, vicp[1][0].z  // o0.w <- <tri_pc_pass return value>.b.z
ret 
