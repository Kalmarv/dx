0x00000000: vs_5_0
0x00000008: dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps
0x0000000C: dcl_constantbuffer CB0[3], immediateIndexed
0x0000001C: dcl_input v0.xyzw
0x00000028: dcl_output_siv o0.xyzw, position
0x00000038: dcl_temps 1
0x00000040: <unknown> "plain"
0x00000064: <unknown> "float %f int %d", l(1.500000), l(-7)
0x000000A0: <unknown> "vec %f %f", cb0[0].x, cb0[0].y
0x000000E0: errorf "err %d %u", cb0[1].x, l(0x00011170)
0x0000011C: printf "quote " lone  tab \t nl \n pct %% back \\ two \\\\"
0x00000168: printf "bs \b cr \r q " x1 . hi . oct A bell . vt . ff . del "
0x000001BC: dmul r0.xy, cb0[1].zwzw, d(2.000000l, 0.000000l)
0x000001E8: dtof r0.x, r0.xyxy
0x000001FC: mul r0.xyzw, r0.xxxx, v0.xyzw
0x00000218: mul o0.xyzw, r0.xyzw, cb0[2].xxxx
0x00000238: ret 
