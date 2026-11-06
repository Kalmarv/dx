0x00000000: ds_5_0
0x00000008: dcl_input_control_point_count 3
0x0000000C: dcl_tessellator_domain domain_tri
0x00000010: dcl_globalFlags refactoringAllowed
0x00000014: dcl_constantbuffer CB0[4], immediateIndexed
0x00000024: dcl_input_siv vpc0.x, finalTriUeq0EdgeTessFactor
0x00000034: dcl_input vpc0.yzw
0x00000040: dcl_input_siv vpc3.x, finalTriInsideTessFactor
0x00000050: dcl_input vDomain.xyz
0x00000058: dcl_input vicp[3][0].xyz
0x00000068: dcl_input vicp[3][1].xyzw
0x00000078: dcl_output_siv o0.xyzw, position
0x00000088: dcl_output o1.xyzw
0x00000094: dcl_temps 2
0x0000009C: mul r0.xyz, vDomain.yyyy, vicp[1][0].xyzx
0x000000B8: mad r0.xyz, vicp[0][0].xyzx, vDomain.xxxx, r0.xyzx
0x000000DC: mad r0.xyz, vicp[2][0].xyzx, vDomain.zzzz, r0.xyzx
0x00000100: mul r0.w, vpc0.x, l(0.250000)
0x0000011C: mad r1.xyz, vpc0.yzwy, l(0.500000, 0.500000, 0.500000, 0.000000), r0.wwww
0x0000014C: mad r1.xyz, vpc3.xxxx, l(0.125000, 0.125000, 0.125000, 0.000000), r1.xyzx
0x0000017C: add r0.xyz, r0.xyzx, r1.xyzx
0x00000198: mul r1.xyzw, r0.yyyy, cb0[1].xyzw
0x000001B8: mad r1.xyzw, cb0[0].xyzw, r0.xxxx, r1.xyzw
0x000001E0: mad r0.xyzw, cb0[2].xyzw, r0.zzzz, r1.xyzw
0x00000208: add o0.xyzw, r0.xyzw, cb0[3].xyzw
0x00000228: mul r0.xyzw, vDomain.yyyy, vicp[1][1].xyzw
0x00000244: mad r0.xyzw, vicp[0][1].xyzw, vDomain.xxxx, r0.xyzw
0x00000268: mad o1.xyzw, vicp[2][1].xyzw, vDomain.zzzz, r0.xyzw
0x0000028C: ret 
