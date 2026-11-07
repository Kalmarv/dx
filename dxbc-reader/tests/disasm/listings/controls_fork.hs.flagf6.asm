      0x00000000: hs_5_0
      0x00000008: hs_decls 
      0x0000000C: dcl_input_control_point_count 3
      0x00000010: dcl_output_control_point_count 3
      0x00000014: dcl_tessellator_domain ???
      0x00000018: dcl_tessellator_partitioning ???
      0x0000001C: dcl_tessellator_output_primitive
      0x00000020: dcl_hs_max_tessfactor l(16.000000)
      0x00000028: dcl_globalFlags refactoringAllowed
      0x0000002C: dcl_immediateConstantBuffer { { 0x40800000, 0x40000000, 0x00000000, 0x00000000},
                              { 0x41800000, 0x40400000, 0x00000000, 0x00000000} }
   0  0x00000054: hs_control_point_phase 
      0x00000058: dcl_input vOutputControlPointID
      0x00000060: dcl_input v[3][0].xyz
      0x00000070: dcl_input v[3][1].xyzw
      0x00000080: dcl_output o0.xyz
      0x0000008C: dcl_output o1.xyzw
      0x00000098: dcl_temps 1
   1  0x000000A0: utof r0.z, vOutputControlPointID
   2  0x000000B0: mov r0.xy, l(0x00000000,0x00000000,0x00000000,0x00000000)
   3  0x000000D0: mov r0.w, vOutputControlPointID
   4  0x000000E0: add o0.xyz, r0.xyzx, v[r0.w + 0][0].xyzx
   5  0x00000104: mov o1.xyzw, v[r0.w + 0][1].xyzw
   6  0x00000120: ret 
   7  0x00000124: hs_fork_phase_sat [precise(w)] 
      0x00000128: dcl_hs_fork_phase_instance_count 2
      0x00000130: dcl_input vForkInstanceID
      0x00000138: dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      0x00000148: dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      0x00000158: dcl_temps 1
      0x00000160: dcl_indexrange o0.x 2
   8  0x00000170: mov r0.x, vForkInstanceID.x
   9  0x00000180: mov o[r0.x + 0].x, icb[r0.x + 0].y
  10  0x0000019C: ret 
  11  0x000001A0: hs_fork_phase 
      0x000001A4: dcl_input vPrim
      0x000001AC: dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      0x000001BC: dcl_temps 1
  12  0x000001C4: utof r0.x, vPrim
  13  0x000001D4: add r0.x, r0.x, l(0x40800000)
  14  0x000001F0: min o2.x, r0.x, l(0x41800000)
  15  0x0000020C: ret 
  16  0x00000210: hs_fork_phase 
      0x00000214: dcl_output_siv o3.x, finalTriInsideTessFactor
  17  0x00000224: mov o3.x, l(0x40a00000)
  18  0x00000238: ret 
  19  0x0000023C: hs_fork_phase 
      0x00000240: dcl_input vicp[3][0].x
      0x00000250: dcl_output o0.y
      0x0000025C: dcl_temps 1
  20  0x00000264: add r0.x, vicp[1][0].x, vicp[0][0].x
  21  0x00000288: add r0.x, r0.x, vicp[2][0].x
  22  0x000002A8: mul o0.y, r0.x, l(0x3eaaaaab)
  23  0x000002C4: ret 
  24  0x000002C8: hs_fork_phase 
      0x000002CC: dcl_input vicp[3][0].y
      0x000002DC: dcl_output o0.z
      0x000002E8: dcl_temps 1
  25  0x000002F0: add r0.x, vicp[1][0].y, vicp[0][0].y
  26  0x00000314: add r0.x, r0.x, vicp[2][0].y
  27  0x00000334: mul o0.z, r0.x, l(0x3eaaaaab)
  28  0x00000350: ret 
  29  0x00000354: hs_fork_phase 
      0x00000358: dcl_input vicp[3][0].z
      0x00000368: dcl_output o0.w
      0x00000374: dcl_temps 1
  30  0x0000037C: add r0.x, vicp[1][0].z, vicp[0][0].z
  31  0x000003A0: add r0.x, r0.x, vicp[2][0].z
  32  0x000003C0: mul o0.w, r0.x, l(0x3eaaaaab)
  33  0x000003DC: ret 
