hs_5_0
hs_decls 
dcl_input_control_point_count 3
dcl_output_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_tessellator_partitioning partitioning_integer
dcl_tessellator_output_primitive output_triangle_cw
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_constantbuffer CB0[1], immediateIndexed
dcl_function_body fb0
dcl_function_body fb1
dcl_function_table ft0 = {fb0}
dcl_function_table ft1 = {fb1}
dcl_interface fp0[1][1] = {ft0, ft1}
hs_control_point_phase 
dcl_input vOutputControlPointID
dcl_input v[3][0].xyzw
dcl_output o0.xyzw
dcl_temps 1
//
// Initial variable locations:
//   vOutputControlPointID.x <- id; 
//   o0.x <- <main return value>.p.x; o0.y <- <main return value>.p.y; o0.z <- <main return value>.p.z; o0.w <- <main return value>.p.w; 
//   v[0][0].x <- ip[0].p.x; v[0][0].y <- ip[0].p.y; v[0][0].z <- ip[0].p.z; v[0][0].w <- ip[0].p.w; 
//   v[1][0].x <- ip[1].p.x; v[1][0].y <- ip[1].p.y; v[1][0].z <- ip[1].p.z; v[1][0].w <- ip[1].p.w; 
//   v[2][0].x <- ip[2].p.x; v[2][0].y <- ip[2].p.y; v[2][0].z <- ip[2].p.z; v[2][0].w <- ip[2].p.w
//
#line 13 "C:\dx-fixtures\classes_hull.hlsl"
mov r0.x, vOutputControlPointID
mov o0.xyzw, v[r0.x + 0][0].xyzw
ret 
hs_join_phase 
dcl_input vicp[3][0].x
dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
dcl_output_siv o3.x, finalTriInsideTessFactor
dcl_temps 1

#line 11
nop 
mov r0.x, vicp[0][0].x
fcall fp0[0][0]
mov r0.x, r0.x  // r0.x <- c.e[2]
mov r0.x, r0.x  // r0.x <- c.e[1]
mov r0.x, r0.x  // r0.x <- c.e[0]
itof r0.y, l(0x00000001)  // r0.y <- c.i
mov o0.x, r0.x
mov o1.x, r0.x
mov o2.x, r0.x
mov o3.x, r0.y
ret 

#line 7 "C:\dx-fixtures\classes_hull.hlsl"
label fb0
nop 
mov r0.x, r0.x
ret 

#line 6 "C:\dx-fixtures\classes_hull.hlsl"
label fb1
nop 
mov r0.y, this[0].y
mov r0.z, this[0].x
mul r0.x, r0.x, cb[r0.z + 0][r0.y + 0].x
ret 
