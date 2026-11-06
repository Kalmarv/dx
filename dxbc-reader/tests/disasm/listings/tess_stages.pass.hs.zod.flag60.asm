0x00000000: hs_5_0
0x00000008: hs_decls 
0x0000000C: dcl_input_control_point_count 3
0x00000010: dcl_output_control_point_count 3
0x00000014: dcl_tessellator_domain domain_tri
0x00000018: dcl_tessellator_partitioning partitioning_integer
0x0000001C: dcl_tessellator_output_primitive output_point
0x00000020: dcl_globalFlags refactoringAllowed | skipOptimization
0x00000024: hs_control_point_phase 
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
0x00000028: ret 
0x0000002C: hs_join_phase 
0x00000030: dcl_input vicp[3][0].xyz
0x00000040: dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
0x00000050: dcl_output o0.yzw
0x0000005C: dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
0x0000006C: dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
0x0000007C: dcl_output_siv o3.x, finalTriInsideTessFactor
0x0000008C: dcl_temps 2

#line 77
0x00000094: mov r0.x, vicp[0][0].x  // r0.x <- o.e[2]
0x000000AC: mov r0.x, r0.x  // r0.x <- o.e[1]
0x000000C0: mov r0.x, r0.x  // r0.x <- o.e[0]

#line 78
0x000000D4: itof r0.y, l(1)  // r0.y <- o.i

#line 79
0x000000E8: mov r1.xyz, vicp[1][0].xyzx  // r1.x <- o.b.x; r1.y <- o.b.y; r1.z <- o.b.z

#line 80
0x00000100: mov o0.yzw, r1.xxyz
0x00000114: mov o0.x, r0.x
0x00000128: mov o1.x, r0.x
0x0000013C: mov o2.x, r0.x
0x00000150: mov o3.x, r0.y
0x00000164: ret 
