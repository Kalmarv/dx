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
   0: hs_control_point_phase 
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
   1: mov r0.x, vOutputControlPointID
   2: mov o0.xyzw, v[r0.x + 0][0].xyzw
   3: ret 
   4: hs_join_phase 
      dcl_input vicp[3][0].x
      dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      dcl_output_siv o3.x, finalTriInsideTessFactor
      dcl_temps 1

#line 11
   5: nop 
   6: mov r0.x, vicp[0][0].x
   7: fcall fp0[0][0]
   8: mov r0.x, r0.x  // r0.x <- c.e[2]
   9: mov r0.x, r0.x  // r0.x <- c.e[1]
  10: mov r0.x, r0.x  // r0.x <- c.e[0]
  11: itof r0.y, l(1)  // r0.y <- c.i
  12: mov o0.x, r0.x
  13: mov o1.x, r0.x
  14: mov o2.x, r0.x
  15: mov o3.x, r0.y
  16: ret 

#line 7 "C:\dx-fixtures\classes_hull.hlsl"
  17: label fb0
  18: nop 
  19: mov r0.x, r0.x
  20: ret 

#line 6 "C:\dx-fixtures\classes_hull.hlsl"
  21: label fb1
  22: nop 
  23: mov r0.y, this[0].y
  24: mov r0.z, this[0].x
  25: mul r0.x, r0.x, cb[r0.z + 0][r0.y + 0].x
  26: ret 
