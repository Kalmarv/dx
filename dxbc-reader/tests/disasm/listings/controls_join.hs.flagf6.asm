      0x00000000: hs_5_0
      0x00000008: hs_decls 
      0x0000000C: dcl_input_control_point_count 3
      0x00000010: dcl_output_control_point_count 3
      0x00000014: dcl_tessellator_domain domain_tri
      0x00000018: dcl_tessellator_partitioning ???
      0x0000001C: dcl_tessellator_output_primitive
      0x00000020: dcl_hs_max_tessfactor l(16.000000)
      0x00000028: dcl_globalFlags refactoringAllowed | skipOptimization
   0  0x0000002C: hs_control_point_phase_sat 
      0x00000030: dcl_input vOutputControlPointID
      0x00000038: dcl_input v[3][0].xyz
      0x00000048: dcl_input v[3][1].xyzw
      0x00000058: dcl_output o0.xyz
      0x00000064: dcl_output o1.xyzw
      0x00000070: dcl_temps 3
   1  0x00000078: mov r0.x, vOutputControlPointID
   2  0x00000088: mov r1.xyzw, v[r0.x + 0][1].xyzw
   3  0x000000A4: mov r0.xyz, v[r0.x + 0][0].xyzx
   4  0x000000C0: utof r2.z, vOutputControlPointID
   5  0x000000D0: mov r2.xy, l(0x00000000,0x00000000,0x00000000,0x00000000)
   6  0x000000F0: add r0.xyz, r0.xyzx, r2.xyzx
   7  0x0000010C: mov o1.xyzw, r1.xyzw
   8  0x00000120: mov o0.xyz, r0.xyzx
   9  0x00000134: ret 
  10  0x00000138: hs_join_phase_sat [precise(xz)] 
      0x0000013C: dcl_input vPrim
      0x00000144: dcl_input vicp[3][0].xyz
      0x00000154: dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      0x00000164: dcl_output o0.yzw
      0x00000170: dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      0x00000180: dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      0x00000190: dcl_output_siv o3.x, finalTriInsideTessFactor
      0x000001A0: dcl_temps 2
  11  0x000001A8: mov r0.x, l(0x40000000)
  12  0x000001BC: mov r0.y, l(0x40400000)
  13  0x000001D0: utof r1.x, vPrim
  14  0x000001E0: add r0.z, r1.x, l(0x40800000)
  15  0x000001FC: mov r0.w, l(0x40a00000)
  16  0x00000210: add r1.xyz, vicp[1][0].xyzx, vicp[0][0].xyzx
  17  0x00000234: add r1.xyz, r1.xyzx, vicp[2][0].xyzx
  18  0x00000254: div r1.xyz, r1.xyzx, l(0x40400000, 0x40400000, 0x40400000, 0x00000000)
  19  0x0000027C: mov r0.x, r0.x
  20  0x00000290: mov r0.y, r0.y
  21  0x000002A4: mov r0.z, r0.z
  22  0x000002B8: mov r0.w, r0.w
  23  0x000002CC: mov o0.yzw, r1.xxyz
  24  0x000002E0: min r0.xyzw, r0.xyzw, l(0x41800000, 0x41800000, 0x41800000, 0x41800000)
  25  0x00000308: mov o0.x, r0.x
  26  0x0000031C: mov o1.x, r0.y
  27  0x00000330: mov o2.x, r0.z
  28  0x00000344: mov o3.x, r0.w
  29  0x00000358: ret 
