      ps_5_0
      dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | enable11_1DoubleExtensions
      dcl_constantbuffer CB0[1], immediateIndexed
      dcl_output o0.xyzw
      dcl_temps 2
   0: dmul r0.xy, cb0[0].zwzw, d(0.000000)
   1: dadd r0.xy, r0.xyxy, d(0.125000l, 0.000000l)
   2: dtof r0.y, r0.xyxy
   3: ddiv r1.xy, cb0[0].xyxy, d(3.000000l, 0.000000l)
   4: dmul r1.zw, r1.xyxy, d(0.000000l, -2.500000l)
   5: dtof r0.xz, r1.xyzw
   6: mov r0.w, l(1.000000)
   7: mov o0.xyzw, r0.xyzw
   8: ret 
