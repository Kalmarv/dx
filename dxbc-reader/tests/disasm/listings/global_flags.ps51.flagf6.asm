      0x00000000: ps_5_1
      0x00000008: dcl_globalFlags refactoringAllowed | forceEarlyDepthStencil | enableMinimumPrecision | allResourcesBound
      0x0000000C: dcl_constantbuffer CB0[0:0][1], immediateIndexed, space=0
      0x00000028: dcl_resource_structured T0[0:0], 16, space=0
      0x00000044: dcl_input_ps_siv linear noperspective v0.x, position
      0x00000054: dcl_output o0.xyzw
      0x00000060: dcl_temps 1
   0  0x00000068: ftou r0.x, v0.x
   1  0x0000007C: ld_structured r0.xyzw, r0.x, l(0x00000000), T0[0].xyzw
   2  0x000000A4: mul o0.xyzw, r0.xyzw, CB0[0][0].xyzw {min16f as def32}
   3  0x000000CC: ret 
