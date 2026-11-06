      ps_5_0
      dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps
      dcl_constantbuffer CB0[1], immediateIndexed
      dcl_resource_structured t0, 16
      dcl_output o0.xyzw
      dcl_temps 1
   0: ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.xyz, cb0[0].x, l(0), t0.xyzx
   1: dtof r0.x, r0.xyxy
   2: add o0.xyzw, r0.xxxx, r0.zzzz
   3: ret 
