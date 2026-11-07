      hs_5_0
      hs_decls 
      dcl_input_control_point_count 3
      dcl_output_control_point_count 3
      dcl_tessellator_domain domain_tri
      dcl_tessellator_partitioning ???
      dcl_tessellator_output_primitive
      dcl_hs_max_tessfactor l(16.000000)
      dcl_globalFlags refactoringAllowed | skipOptimization
   0: hs_control_point_phase_sat 
      dcl_input vOutputControlPointID
      dcl_input v[3][0].xyz
      dcl_input v[3][1].xyzw
      dcl_output o0.xyz
      dcl_output o1.xyzw
      dcl_temps 3
   1: mov r0.x, vOutputControlPointID
   2: mov r1.xyzw, v[r0.x + 0][1].xyzw
   3: mov r0.xyz, v[r0.x + 0][0].xyzx
   4: utof r2.z, vOutputControlPointID
   5: mov r2.xy, l(0,0,0,0)
   6: add r0.xyz, r0.xyzx, r2.xyzx
   7: mov o1.xyzw, r1.xyzw
   8: mov o0.xyz, r0.xyzx
   9: ret 
  10: hs_join_phase_sat [precise(xz)] 
      dcl_input vPrim
      dcl_input vicp[3][0].xyz
      dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      dcl_output o0.yzw
      dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      dcl_output_siv o3.x, finalTriInsideTessFactor
      dcl_temps 2
  11: mov r0.x, l(2.000000)
  12: mov r0.y, l(3.000000)
  13: utof r1.x, vPrim
  14: add r0.z, r1.x, l(4.000000)
  15: mov r0.w, l(5.000000)
  16: add r1.xyz, vicp[1][0].xyzx, vicp[0][0].xyzx
  17: add r1.xyz, r1.xyzx, vicp[2][0].xyzx
  18: div r1.xyz, r1.xyzx, l(3.000000, 3.000000, 3.000000, 0.000000)
  19: mov r0.x, r0.x
  20: mov r0.y, r0.y
  21: mov r0.z, r0.z
  22: mov r0.w, r0.w
  23: mov o0.yzw, r1.xxyz
  24: min r0.xyzw, r0.xyzw, l(16.000000, 16.000000, 16.000000, 16.000000)
  25: mov o0.x, r0.x
  26: mov o1.x, r0.y
  27: mov o2.x, r0.z
  28: mov o3.x, r0.w
  29: ret 
