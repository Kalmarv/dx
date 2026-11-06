      0x00000000: hs_5_0
      0x00000008: hs_decls 
      0x0000000C: dcl_input_control_point_count 3
      0x00000010: dcl_output_control_point_count 3
      0x00000014: dcl_tessellator_domain domain_tri
      0x00000018: dcl_tessellator_partitioning partitioning_integer
      0x0000001C: dcl_tessellator_output_primitive output_triangle_cw
      0x00000020: dcl_globalFlags refactoringAllowed | skipOptimization
      0x00000024: dcl_constantbuffer CB0[1], immediateIndexed
      0x00000034: dcl_function_body fb0
      0x0000003C: dcl_function_body fb1
      0x00000044: dcl_function_table ft0 = {fb0}
      0x00000054: dcl_function_table ft1 = {fb1}
      0x00000064: dcl_interface fp0[1][1] = {ft0, ft1}
   0  0x0000007C: hs_control_point_phase 
      0x00000080: dcl_input vOutputControlPointID
      0x00000088: dcl_input v[3][0].xyzw
      0x00000098: dcl_output o0.xyzw
      0x000000A4: dcl_temps 1
   1  0x000000AC: mov r0.x, vOutputControlPointID
   2  0x000000BC: mov o0.xyzw, v[r0.x + 0][0].xyzw
   3  0x000000D8: ret 
   4  0x000000DC: hs_join_phase 
      0x000000E0: dcl_input vicp[3][0].x
      0x000000F0: dcl_output_siv o0.x, finalTriUeq0EdgeTessFactor
      0x00000100: dcl_output_siv o1.x, finalTriVeq0EdgeTessFactor
      0x00000110: dcl_output_siv o2.x, finalTriWeq0EdgeTessFactor
      0x00000120: dcl_output_siv o3.x, finalTriInsideTessFactor
      0x00000130: dcl_temps 1
   5  0x00000138: nop 
   6  0x0000013C: mov r0.x, vicp[0][0].x
   7  0x00000154: fcall fp0[0][0]
   8  0x00000168: mov r0.x, r0.x
   9  0x0000017C: mov r0.x, r0.x
  10  0x00000190: mov r0.x, r0.x
  11  0x000001A4: itof r0.y, l(0x00000001)
  12  0x000001B8: mov o0.x, r0.x
  13  0x000001CC: mov o1.x, r0.x
  14  0x000001E0: mov o2.x, r0.x
  15  0x000001F4: mov o3.x, r0.y
  16  0x00000208: ret 
  17  0x0000020C: label fb0
  18  0x00000218: nop 
  19  0x0000021C: mov r0.x, r0.x
  20  0x00000230: ret 
  21  0x00000234: label fb1
  22  0x00000240: nop 
  23  0x00000244: mov r0.y, this[0].y
  24  0x00000258: mov r0.z, this[0].x
  25  0x0000026C: mul r0.x, r0.x, cb[r0.z + 0][r0.y + 0].x
  26  0x00000294: ret 
