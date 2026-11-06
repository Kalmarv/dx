vs_5_0
dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps
dcl_constantbuffer CB0[3], immediateIndexed
dcl_input v0.xyzw
dcl_output_siv o0.xyzw, position
dcl_temps 1
<unknown> "plain"
<unknown> "float %f int %d", l(0x3fc00000), l(0xfffffff9)
<unknown> "vec %f %f", cb0[0].x, cb0[0].y
errorf "err %d %u", cb0[1].x, l(0x00011170)
printf "quote " lone  tab \t nl \n pct %% back \\ two \\\\"
printf "bs \b cr \r q " x1 . hi . oct A bell . vt . ff . del "
dmul r0.xy, cb0[1].zwzw, d(0x00000000, 0x40000000, 0x00000000, 0x00000000)
dtof r0.x, r0.xyxy
mul r0.xyzw, r0.xxxx, v0.xyzw
mul o0.xyzw, r0.xyzw, cb0[2].xxxx
ret 
