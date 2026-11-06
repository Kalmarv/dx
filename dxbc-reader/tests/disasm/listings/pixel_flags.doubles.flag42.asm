ps_5_0
dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps
dcl_constantbuffer CB0[1], immediateIndexed
dcl_input_ps_siv linear noperspective v0.x, position
dcl_output o0.xyzw
dcl_temps 1
dmul r0.xy, cb0[0].xyxy, cb0[0].xyxy
ftod r0.zw, v0.x
dadd r0.xy, r0.zwzw, r0.xyxy
dtof r0.x, r0.xyxy
mov o0.xyzw, r0.xxxx
ret 
