0x00000000: ps_5_0
0x00000008: dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps
0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
0x0000001C: dcl_input_ps_siv linear noperspective v0.x, position
0x0000002C: dcl_output o0.xyzw
0x00000038: dcl_temps 1
0x00000040: dmul r0.xy, cb0[0].xyxy, cb0[0].xyxy
0x00000064: ftod r0.zw, v0.x
0x00000078: dadd r0.xy, r0.zwzw, r0.xyxy
0x00000094: dtof r0.x, r0.xyxy
0x000000A8: mov o0.xyzw, r0.xxxx
0x000000BC: ret 
