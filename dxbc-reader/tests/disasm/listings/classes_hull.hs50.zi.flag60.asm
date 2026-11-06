0x00000000: hs_5_0
0x00000008: hs_decls 
0x0000000C: dcl_input_control_point_count 3
0x00000010: dcl_output_control_point_count 3
0x00000014: dcl_tessellator_domain domain_tri
0x00000018: dcl_tessellator_partitioning partitioning_integer
0x0000001C: dcl_tessellator_output_primitive output_triangle_cw
0x00000020: dcl_globalFlags refactoringAllowed
0x00000024: dcl_constantbuffer CB0[1], immediateIndexed
0x00000034: dcl_function_body fb0
0x0000003C: dcl_function_body fb1
0x00000044: dcl_function_table ft0 = {fb0}
0x00000054: dcl_function_table ft1 = {fb1}
0x00000064: dcl_interface fp0[1][1] = {ft0, ft1}
0x0000007C: hs_join_phase 
0x00000080: dcl_input vicp[3][0].x
0x00000090: dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
0x000000A0: dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
0x000000B0: dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
0x000000C0: dcl_output_siv o3.x, finalTriInsideTessFactor
0x000000D0: dcl_temps 1
//
// Initial variable locations:
//   o3.x <- <pc return value>.i; 
//   o2.x <- <pc return value>.e[2]; 
//   o1.x <- <pc return value>.e[1]; 
//   o0.x <- <pc return value>.e[0]; 
//   vicp[0][0].x <- ip[0].p.x; vicp[0][0].y <- ip[0].p.y; vicp[0][0].z <- ip[0].p.z; vicp[0][0].w <- ip[0].p.w; 
//   vicp[1][0].x <- ip[1].p.x; vicp[1][0].y <- ip[1].p.y; vicp[1][0].z <- ip[1].p.z; vicp[1][0].w <- ip[1].p.w; 
//   vicp[2][0].x <- ip[2].p.x; vicp[2][0].y <- ip[2].p.y; vicp[2][0].z <- ip[2].p.z; vicp[2][0].w <- ip[2].p.w; 
//   vOutputControlPointID.x <- id; 
//   o0.x <- <main return value>.p.x; o0.y <- <main return value>.p.y; o0.z <- <main return value>.p.z; o0.w <- <main return value>.p.w; 
//   v[0][0].x <- ip[0].p.x; v[0][0].y <- ip[0].p.y; v[0][0].z <- ip[0].p.z; v[0][0].w <- ip[0].p.w; 
//   v[1][0].x <- ip[1].p.x; v[1][0].y <- ip[1].p.y; v[1][0].z <- ip[1].p.z; v[1][0].w <- ip[1].p.w; 
//   v[2][0].x <- ip[2].p.x; v[2][0].y <- ip[2].p.y; v[2][0].z <- ip[2].p.z; v[2][0].w <- ip[2].p.w
//
#line 11 "C:\dx-fixtures\classes_hull.hlsl"
0x000000D8: fcall fp0[0][0]
0x000000EC: mov o0.x, r0.x
0x00000100: mov o1.x, r0.x
0x00000114: mov o2.x, r0.x
0x00000128: mov o3.x, l(1.000000)
0x0000013C: ret 

#line 7 "C:\dx-fixtures\classes_hull.hlsl"
0x00000140: label fb0
0x0000014C: mov r0.x, vicp[0][0].x
0x00000164: ret 

#line 6 "C:\dx-fixtures\classes_hull.hlsl"
0x00000168: label fb1
0x00000174: mov r0.yz, this[0].yyxy
0x00000188: mul r0.x, cb[r0.z + 0][r0.y + 0].x, vicp[0][0].x
0x000001B4: ret 
