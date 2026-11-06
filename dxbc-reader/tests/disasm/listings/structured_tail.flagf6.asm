      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps
      0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
      0x0000001C: dcl_resource_structured t0, 16
      0x0000002C: dcl_output o0.xyzw
      0x00000038: dcl_temps 1
   0  0x00000040: ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.xyz, cb0[0].x, l(0x00000000), t0.xyzx
   1  0x00000070: dtof r0.x, r0.xyxy
   2  0x00000084: add o0.xyzw, r0.xxxx, r0.zzzz
   3  0x000000A0: ret 
