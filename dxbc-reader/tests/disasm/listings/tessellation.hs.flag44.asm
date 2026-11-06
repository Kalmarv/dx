      hs_5_0
      hs_decls 
      dcl_input_control_point_count 3
      dcl_output_control_point_count 3
      dcl_tessellator_domain domain_tri
      dcl_tessellator_partitioning partitioning_integer
      dcl_tessellator_output_primitive output_triangle_cw
      dcl_hs_max_tessfactor l(16.000000)
      dcl_globalFlags refactoringAllowed
      dcl_immediateConstantBuffer { { 4.000000, 2.000000, 0, 0},
                              { 16.000000, 3.000000, 0, 0} }
   0: hs_control_point_phase 
      dcl_input vOutputControlPointID
      dcl_input v[3][0].xyz
      dcl_input v[3][1].xyzw
      dcl_output o0.xyz
      dcl_output o1.xyzw
      dcl_temps 1
   1: utof r0.z, vOutputControlPointID
   2: mov r0.xy, l(0,0,0,0)
   3: mov r0.w, vOutputControlPointID
   4: add o0.xyz, r0.xyzx, v[r0.w + 0][0].xyzx
   5: mov o1.xyzw, v[r0.w + 0][1].xyzw
   6: ret 
   7: hs_fork_phase 
      dcl_hs_fork_phase_instance_count 2
      dcl_input vForkInstanceID
      dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      dcl_temps 1
      dcl_indexrange o0.x 2
   8: mov r0.x, vForkInstanceID.x
   9: mov o[r0.x + 0].x, icb[r0.x + 0].y
  10: ret 
  11: hs_fork_phase 
      dcl_input vPrim
      dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      dcl_temps 1
  12: utof r0.x, vPrim
  13: add r0.x, r0.x, l(4.000000)
  14: min o2.x, r0.x, l(16.000000)
  15: ret 
  16: hs_fork_phase 
      dcl_output_siv o3.x, finalTriInsideTessFactor
  17: mov o3.x, l(5.000000)
  18: ret 
  19: hs_fork_phase 
      dcl_input vicp[3][0].x
      dcl_output o0.y
      dcl_temps 1
  20: add r0.x, vicp[1][0].x, vicp[0][0].x
  21: add r0.x, r0.x, vicp[2][0].x
  22: mul o0.y, r0.x, l(0.333333)
  23: ret 
  24: hs_fork_phase 
      dcl_input vicp[3][0].y
      dcl_output o0.z
      dcl_temps 1
  25: add r0.x, vicp[1][0].y, vicp[0][0].y
  26: add r0.x, r0.x, vicp[2][0].y
  27: mul o0.z, r0.x, l(0.333333)
  28: ret 
  29: hs_fork_phase 
      dcl_input vicp[3][0].z
      dcl_output o0.w
      dcl_temps 1
  30: add r0.x, vicp[1][0].z, vicp[0][0].z
  31: add r0.x, r0.x, vicp[2][0].z
  32: mul o0.w, r0.x, l(0.333333)
  33: ret 
