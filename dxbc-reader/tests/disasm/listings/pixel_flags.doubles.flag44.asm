      ps_5_0
      dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps
      dcl_constantbuffer CB0[1], immediateIndexed
      dcl_input_ps_siv linear noperspective v0.x, position
      dcl_output o0.xyzw
      dcl_temps 1
   0: dmul r0.xy, cb0[0].xyxy, cb0[0].xyxy
   1: ftod r0.zw, v0.x
   2: dadd r0.xy, r0.zwzw, r0.xyxy
   3: dtof r0.x, r0.xyxy
   4: mov o0.xyzw, r0.xxxx
   5: ret 
