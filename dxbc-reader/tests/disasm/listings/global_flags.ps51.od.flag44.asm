      ps_5_1
      dcl_globalFlags refactoringAllowed | forceEarlyDepthStencil | skipOptimization | enableMinimumPrecision | allResourcesBound
      dcl_constantbuffer CB0[0:0][1], immediateIndexed, space=0
      dcl_resource_structured T0[0:0], 16, space=0
      dcl_input_ps_siv linear noperspective v0.x, position
      dcl_output o0.xyzw
      dcl_temps 2
   0: ftou r0.x, v0.x
   1: ld_structured r1.x, r0.x, l(0), T0[0].xxxx
   2: ld_structured r1.y, r0.x, l(4), T0[0].xxxx
   3: ld_structured r1.z, r0.x, l(8), T0[0].xxxx
   4: ld_structured r1.w, r0.x, l(12), T0[0].xxxx
   5: mov r0.xyzw, CB0[0][0].xyzw {min16f as def32}
   6: mul r0.xyzw, r0.xyzw, r1.xyzw
   7: mov o0.xyzw, r0.xyzw
   8: ret 
