hs_5_0
hs_decls 
dcl_input_control_point_count 3
dcl_output_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_tessellator_partitioning partitioning_integer
dcl_tessellator_output_primitive output_point
dcl_globalFlags refactoringAllowed | skipOptimization
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
hs_join_phase 
dcl_input vicp[3][0].xyz
dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
dcl_output o0.yzw
dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
dcl_output_siv o3.x, finalTriInsideTessFactor
dcl_temps 2

#line 77
mov r0.x, vicp[0][0].x  // r0.x <- o.e[2]
mov r0.x, r0.x  // r0.x <- o.e[1]
mov r0.x, r0.x  // r0.x <- o.e[0]

#line 78
itof r0.y, l(0x00000001)  // r0.y <- o.i

#line 79
mov r1.xyz, vicp[1][0].xyzx  // r1.x <- o.b.x; r1.y <- o.b.y; r1.z <- o.b.z

#line 80
mov o0.yzw, r1.xxyz
mov o0.x, r0.x
mov o1.x, r0.x
mov o2.x, r0.x
mov o3.x, r0.y
ret 
