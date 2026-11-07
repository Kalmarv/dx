ps_5_0
dcl_globalFlags refactoringAllowed | forceEarlyDepthStencil | enableMinimumPrecision
dcl_constantbuffer CB0[1], immediateIndexed
dcl_resource_structured t0, 16
dcl_input_ps_siv linear noperspective v0.x, position
dcl_output o0.xyzw
dcl_temps 1
ftou r0.x, v0.x
ld_structured_indexable(structured_buffer, stride=16)(mixed,mixed,mixed,mixed) r0.xyzw, r0.x, l(0x00000000), t0.xyzw
mul o0.xyzw, r0.xyzw, cb0[0].xyzw {min16f as def32}
ret 
