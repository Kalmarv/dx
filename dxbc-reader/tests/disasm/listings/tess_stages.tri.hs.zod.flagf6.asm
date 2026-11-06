      0x00000000: hs_5_0
      0x00000008: hs_decls 
      0x0000000C: dcl_input_control_point_count 3
      0x00000010: dcl_output_control_point_count 3
      0x00000014: dcl_tessellator_domain domain_tri
      0x00000018: dcl_tessellator_partitioning partitioning_fractional_odd
      0x0000001C: dcl_tessellator_output_primitive output_triangle_cw
      0x00000020: dcl_hs_max_tessfactor l(15.000000)
      0x00000028: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000002C: dcl_constantbuffer CB0[1], immediateIndexed
   0  0x0000003C: hs_control_point_phase 
      0x00000040: dcl_input vOutputControlPointID
      0x00000048: dcl_input v[3][0].xyzw
      0x00000058: dcl_input v[3][1].xyz
      0x00000068: dcl_output o0.xyzw
      0x00000074: dcl_output o1.xyz
      0x00000080: dcl_temps 3
   1  0x00000088: mov r0.x, vOutputControlPointID
   2  0x00000098: mov r0.yzw, v[r0.x + 0][0].xxyz
   3  0x000000B4: mov r1.x, v[r0.x + 0][0].w
   4  0x000000D0: mov r1.yzw, v[r0.x + 0][1].xxyz
   5  0x000000EC: mul r2.xyz, r1.yzwy, cb0[0].xxxx
   6  0x0000010C: add r0.xyz, r0.yzwy, r2.xyzx
   7  0x00000128: mov o0.xyz, r0.xyzx
   8  0x0000013C: mov o0.w, r1.x
   9  0x00000150: mov o1.xyz, r1.yzwy
  10  0x00000164: ret 
  11  0x00000168: hs_join_phase 
      0x0000016C: dcl_input vPrim
      0x00000174: dcl_input vicp[3][0].xyzw
      0x00000184: dcl_input vocp[3][0].xyzw
      0x00000194: dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      0x000001A4: dcl_output o0.yzw
      0x000001B0: dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      0x000001C0: dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      0x000001D0: dcl_output_siv o3.x, finalTriInsideTessFactor
      0x000001E0: dcl_temps 3
  12  0x000001E8: mov r0.xyzw, -vicp[1][0].xyzw
  13  0x00000204: add r0.xyzw, r0.xyzw, vocp[0][0].xyzw
  14  0x00000224: dp4 r0.x, r0.xyzw, r0.xyzw
  15  0x00000240: sqrt r0.x, r0.x
  16  0x00000254: mul r0.x, r0.x, cb0[0].x
  17  0x00000274: mov r1.xyzw, -vicp[2][0].xyzw
  18  0x00000290: add r1.xyzw, r1.xyzw, vocp[1][0].xyzw
  19  0x000002B0: dp4 r1.x, r1.xyzw, r1.xyzw
  20  0x000002CC: sqrt r1.x, r1.x
  21  0x000002E0: mul r0.y, r1.x, cb0[0].y
  22  0x00000300: mov r1.xyzw, -vicp[0][0].xyzw
  23  0x0000031C: add r1.xyzw, r1.xyzw, vocp[2][0].xyzw
  24  0x0000033C: dp4 r1.x, r1.xyzw, r1.xyzw
  25  0x00000358: sqrt r1.x, r1.x
  26  0x0000036C: mul r0.z, r1.x, cb0[0].z
  27  0x0000038C: utof r1.x, vPrim
  28  0x0000039C: add r0.w, r1.x, cb0[0].w
  29  0x000003BC: add r1.xyz, vicp[1][0].xyzx, vicp[0][0].xyzx
  30  0x000003E0: add r1.xyz, r1.xyzx, vicp[2][0].xyzx
  31  0x00000400: itof r2.xyz, l(0x00000003, 0x00000003, 0x00000003, 0x00000000)
  32  0x00000420: div r1.xyz, r1.xyzx, r2.xyzx
  33  0x0000043C: mov r0.x, r0.x
  34  0x00000450: mov r0.y, r0.y
  35  0x00000464: mov r0.z, r0.z
  36  0x00000478: mov r0.w, r0.w
  37  0x0000048C: mov o0.yzw, r1.xxyz
  38  0x000004A0: min r0.xyzw, r0.xyzw, l(0x41700000, 0x41700000, 0x41700000, 0x41700000)
  39  0x000004C8: mov o0.x, r0.x
  40  0x000004DC: mov o1.x, r0.y
  41  0x000004F0: mov o2.x, r0.z
  42  0x00000504: mov o3.x, r0.w
  43  0x00000518: ret 
