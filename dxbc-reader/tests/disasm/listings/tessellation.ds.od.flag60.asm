0x00000000: ds_5_0
0x00000008: dcl_input_control_point_count 3
0x0000000C: dcl_tessellator_domain domain_tri
0x00000010: dcl_globalFlags refactoringAllowed | skipOptimization
0x00000014: dcl_constantbuffer CB0[4], immediateIndexed
0x00000024: dcl_input_siv vpc0.x, finalTriUeq0EdgeTessFactor
0x00000034: dcl_input vpc0.yzw
0x00000040: dcl_input_siv vpc3.x, finalTriInsideTessFactor
0x00000050: dcl_input vDomain.xyz
0x00000058: dcl_input vicp[3][0].xyz
0x00000068: dcl_input vicp[3][1].xyzw
0x00000078: dcl_output_siv o0.xyzw, position
0x00000088: dcl_output o1.xyzw
0x00000094: dcl_temps 3
0x0000009C: mul r0.xyz, vDomain.xxxx, vicp[0][0].xyzx
0x000000B8: mul r1.xyz, vDomain.yyyy, vicp[1][0].xyzx
0x000000D4: add r0.xyz, r0.xyzx, r1.xyzx
0x000000F0: mul r1.xyz, vDomain.zzzz, vicp[2][0].xyzx
0x0000010C: add r0.xyz, r0.xyzx, r1.xyzx
0x00000128: mul r1.xyz, vpc0.yzwy, l(0.500000, 0.500000, 0.500000, 0.000000)
0x00000150: mul r0.w, vpc0.x, l(0.250000)
0x0000016C: add r1.xyz, r0.wwww, r1.xyzx
0x00000188: mul r0.w, vpc3.x, l(0.125000)
0x000001A4: add r1.xyz, r0.wwww, r1.xyzx
0x000001C0: add r0.xyz, r0.xyzx, r1.xyzx
0x000001DC: mul r1.xyzw, r0.xxxx, cb0[0].xyzw
0x000001FC: mul r2.xyzw, r0.yyyy, cb0[1].xyzw
0x0000021C: add r1.xyzw, r1.xyzw, r2.xyzw
0x00000238: mul r0.xyzw, r0.zzzz, cb0[2].xyzw
0x00000258: add r0.xyzw, r0.xyzw, r1.xyzw
0x00000274: mul r1.xyzw, cb0[3].xyzw, l(1.000000, 1.000000, 1.000000, 1.000000)
0x000002A0: add r0.xyzw, r0.xyzw, r1.xyzw
0x000002BC: mul r1.xyzw, vDomain.xxxx, vicp[0][1].xyzw
0x000002D8: mul r2.xyzw, vDomain.yyyy, vicp[1][1].xyzw
0x000002F4: add r1.xyzw, r1.xyzw, r2.xyzw
0x00000310: mul r2.xyzw, vDomain.zzzz, vicp[2][1].xyzw
0x0000032C: add r1.xyzw, r1.xyzw, r2.xyzw
0x00000348: mov o0.xyzw, r0.xyzw
0x0000035C: mov o1.xyzw, r1.xyzw
0x00000370: ret 
