      0x00000000: ds_5_0
      0x00000008: dcl_input_control_point_count 4
      0x0000000C: dcl_tessellator_domain domain_quad
      0x00000010: dcl_globalFlags refactoringAllowed
      0x00000014: dcl_constantbuffer CB0[5], immediateIndexed
      0x00000024: dcl_input_siv vpc4.x, finalQuadUInsideTessFactor
      0x00000034: dcl_input_siv vpc5.x, finalQuadVInsideTessFactor
      0x00000044: dcl_input vDomain.xy
      0x0000004C: dcl_input vPrim
      0x00000054: dcl_input vicp[4][0].xyzw
      0x00000064: dcl_input vicp[4][1].xyz
      0x00000074: dcl_output_siv o0.xyzw, position
      0x00000084: dcl_output o1.xyz
      0x00000090: dcl_temps 2
   0  0x00000098: add r0.xyzw, -vicp[3][0].xyzw, vicp[2][0].xyzw
   1  0x000000C0: mad r0.xyzw, vDomain.xxxx, r0.xyzw, vicp[3][0].xyzw
   2  0x000000E4: add r1.xyzw, -vicp[0][0].xyzw, vicp[1][0].xyzw
   3  0x0000010C: mad r1.xyzw, vDomain.xxxx, r1.xyzw, vicp[0][0].xyzw
   4  0x00000130: add r0.xyzw, r0.xyzw, -r1.xyzw
   5  0x00000150: mad r0.xyzw, vDomain.yyyy, r0.xyzw, r1.xyzw
   6  0x00000170: add r1.x, -vpc4.x, vpc5.x
   7  0x00000190: and r1.y, vPrim, l(0x00000001)
   8  0x000001A8: utof r1.y, r1.y
   9  0x000001BC: mad r1.x, r1.y, r1.x, vpc4.x
  10  0x000001E0: mul r0.xyzw, r0.xyzw, r1.xxxx
  11  0x000001FC: dp4 o0.x, r0.xyzw, cb0[1].xyzw
  12  0x0000021C: dp4 o0.y, r0.xyzw, cb0[2].xyzw
  13  0x0000023C: dp4 o0.z, r0.xyzw, cb0[3].xyzw
  14  0x0000025C: dp4 o0.w, r0.xyzw, cb0[4].xyzw
  15  0x0000027C: add r0.xyz, -vicp[1][1].xyzx, vicp[3][1].xyzx
  16  0x000002A4: mad o1.xyz, r1.yyyy, r0.xyzx, vicp[1][1].xyzx
  17  0x000002CC: ret 
