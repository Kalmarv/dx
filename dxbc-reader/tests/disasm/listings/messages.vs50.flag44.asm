      vs_5_0
      dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps
      dcl_constantbuffer CB0[3], immediateIndexed
      dcl_input v0.xyzw
      dcl_output_siv o0.xyzw, position
      dcl_temps 1
   0: printf "plain"
   1: printf "float %f int %d", l(1.500000), l(-7)
   2: printf "vec %f %f", cb0[0].x, cb0[0].y
   3: errorf "err %d %u", cb0[1].x, l(0x00011170)
   4: printf "quote " lone  tab \t nl \n pct %% back \\ two \\\\"
   5: printf "bs \b cr \r q " x1 . hi . oct A bell . vt . ff . del "
   6: dmul r0.xy, cb0[1].zwzw, d(2.000000l, 0.000000l)
   7: dtof r0.x, r0.xyxy
   8: mul r0.xyzw, r0.xxxx, v0.xyzw
   9: mul o0.xyzw, r0.xyzw, cb0[2].xxxx
  10: ret 
