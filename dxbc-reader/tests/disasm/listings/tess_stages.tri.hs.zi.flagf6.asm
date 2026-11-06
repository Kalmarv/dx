      0x00000000: hs_5_0
      0x00000008: hs_decls 
      0x0000000C: dcl_input_control_point_count 3
      0x00000010: dcl_output_control_point_count 3
      0x00000014: dcl_tessellator_domain domain_tri
      0x00000018: dcl_tessellator_partitioning partitioning_fractional_odd
      0x0000001C: dcl_tessellator_output_primitive output_triangle_cw
      0x00000020: dcl_hs_max_tessfactor l(15.000000)
      0x00000028: dcl_globalFlags refactoringAllowed
      0x0000002C: dcl_constantbuffer CB0[1], immediateIndexed
   0  0x0000003C: hs_control_point_phase 
      0x00000040: dcl_input vOutputControlPointID
      0x00000048: dcl_input v[3][0].xyzw
      0x00000058: dcl_input v[3][1].xyz
      0x00000068: dcl_output o0.xyzw
      0x00000074: dcl_output o1.xyz
      0x00000080: dcl_temps 1
   1  0x00000088: mov r0.x, vOutputControlPointID
   2  0x00000098: mad o0.xyz, v[r0.x + 0][1].xyzx, cb0[0].xxxx, v[r0.x + 0][0].xyzx
   3  0x000000D0: mov o0.w, v[r0.x + 0][0].w
   4  0x000000EC: mov o1.xyz, v[r0.x + 0][1].xyzx
   5  0x00000108: ret 
   6  0x0000010C: hs_fork_phase 
      0x00000110: dcl_input vicp[3][0].xyzw
      0x00000120: dcl_input vocp[3][0].xyzw
      0x00000130: dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      0x00000140: dcl_temps 1
   7  0x00000148: add r0.xyzw, -vicp[1][0].xyzw, vocp[0][0].xyzw
   8  0x00000170: dp4 r0.x, r0.xyzw, r0.xyzw
   9  0x0000018C: sqrt r0.x, r0.x
  10  0x000001A0: mul r0.x, r0.x, cb0[0].x
  11  0x000001C0: min o0.x, r0.x, l(0x41700000)
  12  0x000001DC: ret 
  13  0x000001E0: hs_fork_phase 
      0x000001E4: dcl_input vicp[3][0].xyzw
      0x000001F4: dcl_input vocp[3][0].xyzw
      0x00000204: dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      0x00000214: dcl_temps 1
  14  0x0000021C: add r0.xyzw, -vicp[2][0].xyzw, vocp[1][0].xyzw
  15  0x00000244: dp4 r0.x, r0.xyzw, r0.xyzw
  16  0x00000260: sqrt r0.x, r0.x
  17  0x00000274: mul r0.x, r0.x, cb0[0].y
  18  0x00000294: min o1.x, r0.x, l(0x41700000)
  19  0x000002B0: ret 
  20  0x000002B4: hs_fork_phase 
      0x000002B8: dcl_input vicp[3][0].xyzw
      0x000002C8: dcl_input vocp[3][0].xyzw
      0x000002D8: dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      0x000002E8: dcl_temps 1
  21  0x000002F0: add r0.xyzw, -vicp[0][0].xyzw, vocp[2][0].xyzw
  22  0x00000318: dp4 r0.x, r0.xyzw, r0.xyzw
  23  0x00000334: sqrt r0.x, r0.x
  24  0x00000348: mul r0.x, r0.x, cb0[0].z
  25  0x00000368: min o2.x, r0.x, l(0x41700000)
  26  0x00000384: ret 
  27  0x00000388: hs_fork_phase 
      0x0000038C: dcl_input vPrim
      0x00000394: dcl_output_siv o3.x, finalTriInsideTessFactor
      0x000003A4: dcl_temps 1
  28  0x000003AC: utof r0.x, vPrim
  29  0x000003BC: add r0.x, r0.x, cb0[0].w
  30  0x000003DC: min o3.x, r0.x, l(0x41700000)
  31  0x000003F8: ret 
  32  0x000003FC: hs_fork_phase 
      0x00000400: dcl_input vicp[3][0].x
      0x00000410: dcl_output o0.y
      0x0000041C: dcl_temps 1
  33  0x00000424: add r0.x, vicp[1][0].x, vicp[0][0].x
  34  0x00000448: add r0.x, r0.x, vicp[2][0].x
  35  0x00000468: mul o0.y, r0.x, l(0x3eaaaaab)
  36  0x00000484: ret 
  37  0x00000488: hs_fork_phase 
      0x0000048C: dcl_input vicp[3][0].y
      0x0000049C: dcl_output o0.z
      0x000004A8: dcl_temps 1
  38  0x000004B0: add r0.x, vicp[1][0].y, vicp[0][0].y
  39  0x000004D4: add r0.x, r0.x, vicp[2][0].y
  40  0x000004F4: mul o0.z, r0.x, l(0x3eaaaaab)
  41  0x00000510: ret 
  42  0x00000514: hs_fork_phase 
      0x00000518: dcl_input vicp[3][0].z
      0x00000528: dcl_output o0.w
      0x00000534: dcl_temps 1
  43  0x0000053C: add r0.x, vicp[1][0].z, vicp[0][0].z
  44  0x00000560: add r0.x, r0.x, vicp[2][0].z
  45  0x00000580: mul o0.w, r0.x, l(0x3eaaaaab)
  46  0x0000059C: ret 
