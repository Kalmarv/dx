      ps_5_0
      dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | forceEarlyDepthStencil | enableMinimumPrecision
      dcl_constantbuffer CB0[2], immediateIndexed
      dcl_resource_structured t0, 16
      dcl_input_ps_siv linear noperspective v0.x, position
      dcl_output o0.xyzw
      dcl_temps 2
   0: ftou r0.x, v0.x
   1: ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.xyzw, r0.x, l(0), t0.xyzw
   2: mul r0.xyzw, r0.xyzw, cb0[0].xyzw {min16f as def32}
   3: ftod r1.xy, r0.x
   4: dmul r1.xy, r1.xyxy, cb0[1].xyxy
   5: dtof r0.x, r1.xyxy
   6: mov o0.xyzw, r0.xyzw
   7: ret 
