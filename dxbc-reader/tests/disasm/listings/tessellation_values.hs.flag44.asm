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
   1: mov r0.x, vOutputControlPointID
   2: mad o0.xyz, v[r0.x + 0][1].xyzx, cb0[0].xxxx, v[r0.x + 0][0].xyzx
   3: mov o0.w, v[r0.x + 0][0].w
   4: mov o1.xyz, v[r0.x + 0][1].xyzx
   5: ret 
   6: hs_fork_phase 
      dcl_input vicp[3][0].xyzw
      dcl_input vocp[3][0].xyzw
      dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      dcl_temps 1
   7: add r0.xyzw, -vicp[1][0].xyzw, vocp[0][0].xyzw
   8: dp4 r0.x, r0.xyzw, r0.xyzw
   9: sqrt r0.x, r0.x
  10: mul r0.x, r0.x, cb0[0].x
  11: min o0.x, r0.x, l(15.000000)
  12: ret 
  13: hs_fork_phase 
      dcl_input vicp[3][0].xyzw
      dcl_input vocp[3][0].xyzw
      dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      dcl_temps 1
  14: add r0.xyzw, -vicp[2][0].xyzw, vocp[1][0].xyzw
  15: dp4 r0.x, r0.xyzw, r0.xyzw
  16: sqrt r0.x, r0.x
  17: mul r0.x, r0.x, cb0[0].y
  18: min o1.x, r0.x, l(15.000000)
  19: ret 
  20: hs_fork_phase 
      dcl_input vicp[3][0].xyzw
      dcl_input vocp[3][0].xyzw
      dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      dcl_temps 1
  21: add r0.xyzw, -vicp[0][0].xyzw, vocp[2][0].xyzw
  22: dp4 r0.x, r0.xyzw, r0.xyzw
  23: sqrt r0.x, r0.x
  24: mul r0.x, r0.x, cb0[0].z
  25: min o2.x, r0.x, l(15.000000)
  26: ret 
  27: hs_fork_phase 
      dcl_input vPrim
      dcl_output_siv o3.x, finalTriInsideTessFactor
      dcl_temps 1
  28: utof r0.x, vPrim
  29: add r0.x, r0.x, cb0[0].w
  30: min o3.x, r0.x, l(15.000000)
  31: ret 
  32: hs_fork_phase 
      dcl_input vicp[3][0].x
      dcl_output o0.y
      dcl_temps 1
  33: add r0.x, vicp[1][0].x, vicp[0][0].x
  34: add r0.x, r0.x, vicp[2][0].x
  35: mul o0.y, r0.x, l(0.333333)
  36: ret 
  37: hs_fork_phase 
      dcl_input vicp[3][0].y
      dcl_output o0.z
      dcl_temps 1
  38: add r0.x, vicp[1][0].y, vicp[0][0].y
  39: add r0.x, r0.x, vicp[2][0].y
  40: mul o0.z, r0.x, l(0.333333)
  41: ret 
  42: hs_fork_phase 
      dcl_input vicp[3][0].z
      dcl_output o0.w
      dcl_temps 1
  43: add r0.x, vicp[1][0].z, vicp[0][0].z
  44: add r0.x, r0.x, vicp[2][0].z
  45: mul o0.w, r0.x, l(0.333333)
  46: ret 
