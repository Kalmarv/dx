0x00000000: vs_4_0
0x00000008: dcl_constantbuffer CB0[8], immediateIndexed
0x00000018: dcl_constantbuffer CB1[1], immediateIndexed
0x00000028: dcl_input v0.xyz
0x00000034: dcl_input v1.xyz
0x00000040: dcl_input v2.xy
0x0000004C: dcl_output_siv o0.xyzw, position
0x0000005C: dcl_output o1.xyzw
0x00000068: dcl_output o2.xy
0x00000074: dcl_temps 1
0x0000007C: mul r0.xyz, v0.xyzx, cb1[0].xyzx
0x0000009C: mov r0.w, l(1.000000)
0x000000B0: dp4 o0.x, r0.xyzw, cb0[0].xyzw
0x000000D0: dp4 o0.y, r0.xyzw, cb0[1].xyzw
0x000000F0: dp4 o0.z, r0.xyzw, cb0[2].xyzw
0x00000110: dp4 o0.w, r0.xyzw, cb0[3].xyzw
0x00000130: dp3_sat r0.x, v1.xyzx, cb0[5].xyzx
0x00000150: mul r0.x, r0.x, cb0[5].w
0x00000170: dp3_sat r0.y, v1.xyzx, cb0[4].xyzx
0x00000190: mad r0.x, r0.y, cb0[4].w, r0.x
0x000001B8: dp3_sat r0.y, v1.xyzx, cb0[6].xyzx
0x000001D8: mad r0.x, r0.y, cb0[6].w, r0.x
0x00000200: dp3_sat r0.y, v1.xyzx, cb0[7].xyzx
0x00000220: mad o1.xyz, r0.yyyy, cb0[7].wwww, r0.xxxx
0x00000248: mov o1.w, l(1.000000)
0x0000025C: mov o2.xy, v2.xyxx
0x00000270: ret 
