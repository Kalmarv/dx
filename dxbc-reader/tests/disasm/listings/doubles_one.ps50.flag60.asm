0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | enable11_1DoubleExtensions
0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
0x0000001C: dcl_output o0.xyzw
0x00000028: dcl_temps 2
0x00000030: dmul r0.xy, cb0[0].zwzw, d(0.000000)
0x00000050: dadd r0.xy, r0.xyxy, d(0.125000l, 0.000000l)
0x00000078: dtof r0.y, r0.xyxy
0x0000008C: ddiv r1.xy, cb0[0].xyxy, d(3.000000l, 0.000000l)
0x000000B8: dmul r1.zw, r1.xyxy, d(0.000000l, -2.500000l)
0x000000E0: dtof r0.xz, r1.xyzw
0x000000F4: mov r0.w, l(1.000000)
0x00000108: mov o0.xyzw, r0.xyzw
0x0000011C: ret 
