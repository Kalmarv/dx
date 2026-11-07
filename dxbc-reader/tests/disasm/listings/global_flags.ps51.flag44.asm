      ps_5_1
      dcl_globalFlags refactoringAllowed | forceEarlyDepthStencil | enableMinimumPrecision | allResourcesBound
      dcl_constantbuffer CB0[0:0][1], immediateIndexed, space=0
      dcl_resource_structured T0[0:0], 16, space=0
      dcl_input_ps_siv linear noperspective v0.x, position
      dcl_output o0.xyzw
      dcl_temps 1
   0: ftou r0.x, v0.x
   1: ld_structured r0.xyzw, r0.x, l(0), T0[0].xyzw
   2: mul o0.xyzw, r0.xyzw, CB0[0][0].xyzw {min16f as def32}
   3: ret 
