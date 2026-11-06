      0x00000000: ds_5_0
      0x00000008: dcl_input_control_point_count 4
      0x0000000C: dcl_tessellator_domain domain_quad
      0x00000010: dcl_globalFlags refactoringAllowed | skipOptimization
      0x00000014: dcl_constantbuffer CB0[5], immediateIndexed
      0x00000024: dcl_input_siv vpc4.x, finalQuadUInsideTessFactor
      0x00000034: dcl_input_siv vpc5.x, finalQuadVInsideTessFactor
      0x00000044: dcl_input vDomain.xy
      0x0000004C: dcl_input vPrim
      0x00000054: dcl_input vicp[4][0].xyzw
      0x00000064: dcl_input vicp[4][1].xyz
      0x00000074: dcl_output_siv o0.xyzw, position
      0x00000084: dcl_output o1.xyz
      0x00000090: dcl_temps 3
   0  0x00000098: mov r0.xyzw, -vicp[0][0].xyzw
   1  0x000000B4: add r0.xyzw, r0.xyzw, vicp[1][0].xyzw
   2  0x000000D4: mul r0.xyzw, r0.xyzw, vDomain.xxxx
   3  0x000000EC: add r0.xyzw, r0.xyzw, vicp[0][0].xyzw
   4  0x0000010C: mov r1.xyzw, -vicp[3][0].xyzw
   5  0x00000128: add r1.xyzw, r1.xyzw, vicp[2][0].xyzw
   6  0x00000148: mul r1.xyzw, r1.xyzw, vDomain.xxxx
   7  0x00000160: add r1.xyzw, r1.xyzw, vicp[3][0].xyzw
   8  0x00000180: mov r2.xyzw, -r0.xyzw
   9  0x00000198: add r1.xyzw, r1.xyzw, r2.xyzw
  10  0x000001B4: mul r1.xyzw, r1.xyzw, vDomain.yyyy
  11  0x000001CC: add r0.xyzw, r0.xyzw, r1.xyzw
  12  0x000001E8: mov r1.x, l(0x00000001)
  13  0x000001FC: and r1.x, r1.x, vPrim
  14  0x00000214: utof r1.x, r1.x
  15  0x00000228: mov r1.y, -vpc4.x
  16  0x00000240: add r1.y, r1.y, vpc5.x
  17  0x0000025C: mul r1.x, r1.y, r1.x
  18  0x00000278: add r1.x, r1.x, vpc4.x
  19  0x00000294: mul r0.xyzw, r0.xyzw, r1.xxxx
  20  0x000002B0: dp4 r1.x, r0.xyzw, cb0[1].xyzw
  21  0x000002D0: dp4 r1.y, r0.xyzw, cb0[2].xyzw
  22  0x000002F0: dp4 r1.z, r0.xyzw, cb0[3].xyzw
  23  0x00000310: dp4 r1.w, r0.xyzw, cb0[4].xyzw
  24  0x00000330: mov r0.x, l(0x00000001)
  25  0x00000344: and r0.x, r0.x, vPrim
  26  0x0000035C: utof r0.x, r0.x
  27  0x00000370: mov r0.yzw, -vicp[1][1].xxyz
  28  0x0000038C: add r0.yzw, r0.yyzw, vicp[3][1].xxyz
  29  0x000003AC: mul r0.xyz, r0.yzwy, r0.xxxx
  30  0x000003C8: add r0.xyz, r0.xyzx, vicp[1][1].xyzx
  31  0x000003E8: mov o0.xyzw, r1.xyzw
  32  0x000003FC: mov o1.xyz, r0.xyzx
  33  0x00000410: ret 
