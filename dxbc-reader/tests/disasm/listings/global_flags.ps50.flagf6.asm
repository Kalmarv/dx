      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | forceEarlyDepthStencil | enableMinimumPrecision
      0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
      0x0000001C: dcl_resource_structured t0, 16
      0x0000002C: dcl_input_ps_siv linear noperspective v0.x, position
      0x0000003C: dcl_output o0.xyzw
      0x00000048: dcl_temps 1
   0  0x00000050: ftou r0.x, v0.x
   1  0x00000064: ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.xyzw, r0.x, l(0x00000000), t0.xyzw
   2  0x00000090: mul o0.xyzw, r0.xyzw, cb0[0].xyzw {min16f as def32}
   3  0x000000B4: ret 
