      0x00000000: hs_5_0
      0x00000008: hs_decls 
      0x0000000C: dcl_input_control_point_count 16
      0x00000010: dcl_output_control_point_count 4
      0x00000014: dcl_tessellator_domain domain_quad
      0x00000018: dcl_tessellator_partitioning partitioning_fractional_even
      0x0000001C: dcl_tessellator_output_primitive output_triangle_ccw
      0x00000020: dcl_globalFlags refactoringAllowed | skipOptimization
      0x00000024: dcl_constantbuffer CB0[1], immediateIndexed
   0  0x00000034: hs_control_point_phase 
      0x00000038: dcl_input vOutputControlPointID
      0x00000040: dcl_input vPrim
      0x00000048: dcl_input v[16][0].xyzw
      0x00000058: dcl_input v[16][1].xyz
      0x00000068: dcl_output o0.xyzw
      0x00000074: dcl_output o1.xyz
      0x00000080: dcl_temps 2
   1  0x00000088: mov r0.x, l(0x00000004)
   2  0x0000009C: imul null, r0.x, r0.x, vOutputControlPointID
   3  0x000000B8: mov r0.y, l(0x00000004)
   4  0x000000CC: imul null, r0.y, r0.y, vOutputControlPointID
   5  0x000000E8: mov r0.z, l(0x00000003)
   6  0x000000FC: iadd r0.y, r0.z, r0.y
   7  0x00000118: utof r1.xyzw, vPrim
   8  0x00000128: mul r1.xyzw, r1.xyzw, v[r0.y + 0][0].xyzw
   9  0x0000014C: add r0.xyzw, r1.xyzw, v[r0.x + 0][0].xyzw
  10  0x00000170: mov r1.x, vOutputControlPointID
  11  0x00000180: mov r1.xyz, v[r1.x + 0][1].xyzx
  12  0x0000019C: mov o0.xyzw, r0.xyzw
  13  0x000001B0: mov o1.xyz, r1.xyzx
  14  0x000001C4: ret 
  15  0x000001C8: hs_join_phase 
      0x000001CC: dcl_input vicp[16][0].w
      0x000001DC: dcl_output_siv o0.x, finalQuadUeq0EdgeTessFactor
      0x000001EC: dcl_output_siv o1.x, finalQuadVeq0EdgeTessFactor
      0x000001FC: dcl_output_siv o2.x, finalQuadUeq1EdgeTessFactor
      0x0000020C: dcl_output_siv o3.x, finalQuadVeq1EdgeTessFactor
      0x0000021C: dcl_output_siv o4.x, finalQuadUInsideTessFactor
      0x0000022C: dcl_output_siv o5.x, finalQuadVInsideTessFactor
      0x0000023C: dcl_temps 2
  16  0x00000244: add r0.x, cb0[0].x, vicp[0][0].w
  17  0x00000268: add r0.y, cb0[0].y, vicp[4][0].w
  18  0x0000028C: add r0.z, cb0[0].z, vicp[8][0].w
  19  0x000002B0: add r0.w, cb0[0].w, vicp[12][0].w
  20  0x000002D4: mov r1.x, cb0[0].x
  21  0x000002EC: mov r1.y, cb0[0].y
  22  0x00000304: mov o0.x, r0.x
  23  0x00000318: mov o1.x, r0.y
  24  0x0000032C: mov o2.x, r0.z
  25  0x00000340: mov o3.x, r0.w
  26  0x00000354: mov o4.x, r1.x
  27  0x00000368: mov o5.x, r1.y
  28  0x0000037C: ret 
