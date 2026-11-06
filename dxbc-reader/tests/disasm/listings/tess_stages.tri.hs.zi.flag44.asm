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
   0: hs_control_point_phase 
      dcl_input vOutputControlPointID
      dcl_input v[3][0].xyzw
      dcl_input v[3][1].xyz
      dcl_output o0.xyzw
      dcl_output o1.xyz
      dcl_temps 1
//
// Initial variable locations:
//   vOutputControlPointID.x <- i; 
//   o1.x <- <hs_tri return value>.n.x; o1.y <- <hs_tri return value>.n.y; o1.z <- <hs_tri return value>.n.z; 
//   o0.x <- <hs_tri return value>.p.x; o0.y <- <hs_tri return value>.p.y; o0.z <- <hs_tri return value>.p.z; o0.w <- <hs_tri return value>.p.w; 
//   v[0][0].x <- patch[0].p.x; v[0][0].y <- patch[0].p.y; v[0][0].z <- patch[0].p.z; v[0][0].w <- patch[0].p.w; 
//   v[0][1].x <- patch[0].n.x; v[0][1].y <- patch[0].n.y; v[0][1].z <- patch[0].n.z; 
//   v[1][0].x <- patch[1].p.x; v[1][0].y <- patch[1].p.y; v[1][0].z <- patch[1].p.z; v[1][0].w <- patch[1].p.w; 
//   v[1][1].x <- patch[1].n.x; v[1][1].y <- patch[1].n.y; v[1][1].z <- patch[1].n.z; 
//   v[2][0].x <- patch[2].p.x; v[2][0].y <- patch[2].p.y; v[2][0].z <- patch[2].p.z; v[2][0].w <- patch[2].p.w; 
//   v[2][1].x <- patch[2].n.x; v[2][1].y <- patch[2].n.y; v[2][1].z <- patch[2].n.z
//
#line 42 "C:\dx-fixtures\tess_stages.hlsl"
   1: mov r0.x, vOutputControlPointID
   2: mad o0.xyz, v[r0.x + 0][1].xyzx, cb0[0].xxxx, v[r0.x + 0][0].xyzx

#line 43
   3: mov o0.w, v[r0.x + 0][0].w
   4: mov o1.xyz, v[r0.x + 0][1].xyzx
   5: ret 
   6: hs_fork_phase 
      dcl_input vicp[3][0].xyzw
      dcl_input vocp[3][0].xyzw
      dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      dcl_temps 1

#line 33
   7: add r0.xyzw, -vicp[1][0].xyzw, vocp[0][0].xyzw
   8: dp4 r0.x, r0.xyzw, r0.xyzw
   9: sqrt r0.x, r0.x
  10: mul r0.x, r0.x, cb0[0].x  // r0.x <- o.e[0]

#line 36
  11: min o0.x, r0.x, l(15.000000)  // o0.x <- <tri_pc return value>.e[0]
  12: ret 
  13: hs_fork_phase 
      dcl_input vicp[3][0].xyzw
      dcl_input vocp[3][0].xyzw
      dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      dcl_temps 1

#line 33
  14: add r0.xyzw, -vicp[2][0].xyzw, vocp[1][0].xyzw
  15: dp4 r0.x, r0.xyzw, r0.xyzw
  16: sqrt r0.x, r0.x
  17: mul r0.x, r0.x, cb0[0].y  // r0.x <- o.e[1]

#line 36
  18: min o1.x, r0.x, l(15.000000)  // o1.x <- <tri_pc return value>.e[1]
  19: ret 
  20: hs_fork_phase 
      dcl_input vicp[3][0].xyzw
      dcl_input vocp[3][0].xyzw
      dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      dcl_temps 1

#line 33
  21: add r0.xyzw, -vicp[0][0].xyzw, vocp[2][0].xyzw
  22: dp4 r0.x, r0.xyzw, r0.xyzw
  23: sqrt r0.x, r0.x
  24: mul r0.x, r0.x, cb0[0].z  // r0.x <- o.e[2]

#line 36
  25: min o2.x, r0.x, l(15.000000)  // o2.x <- <tri_pc return value>.e[2]
  26: ret 
  27: hs_fork_phase 
      dcl_input vPrim
      dcl_output_siv o3.x, finalTriInsideTessFactor
      dcl_temps 1

#line 34
  28: utof r0.x, vPrim
  29: add r0.x, r0.x, cb0[0].w  // r0.x <- o.i

#line 36
  30: min o3.x, r0.x, l(15.000000)  // o3.x <- <tri_pc return value>.i
  31: ret 
  32: hs_fork_phase 
      dcl_input vicp[3][0].x
      dcl_output o0.y
      dcl_temps 1

#line 35
  33: add r0.x, vicp[1][0].x, vicp[0][0].x
  34: add r0.x, r0.x, vicp[2][0].x
  35: mul o0.y, r0.x, l(0.333333)  // o0.y <- <tri_pc return value>.b.x

#line 36
  36: ret 
  37: hs_fork_phase 
      dcl_input vicp[3][0].y
      dcl_output o0.z
      dcl_temps 1

#line 35
  38: add r0.x, vicp[1][0].y, vicp[0][0].y
  39: add r0.x, r0.x, vicp[2][0].y
  40: mul o0.z, r0.x, l(0.333333)  // o0.z <- <tri_pc return value>.b.y

#line 36
  41: ret 
  42: hs_fork_phase 
      dcl_input vicp[3][0].z
      dcl_output o0.w
      dcl_temps 1

#line 35
  43: add r0.x, vicp[1][0].z, vicp[0][0].z
  44: add r0.x, r0.x, vicp[2][0].z
  45: mul o0.w, r0.x, l(0.333333)  // o0.w <- <tri_pc return value>.b.z

#line 36
  46: ret 
