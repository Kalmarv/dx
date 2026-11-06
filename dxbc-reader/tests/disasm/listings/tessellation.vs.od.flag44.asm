      vs_5_0
      dcl_globalFlags refactoringAllowed | skipOptimization
      dcl_constantbuffer CB0[5], immediateIndexed
      dcl_input v0.xyz
      dcl_input v1.xyzw
      dcl_output o0.xyz
      dcl_output o1.xyzw
      dcl_temps 2
   0: mul r0.xyz, v0.xyzx, cb0[4].xxxx
   1: mov r1.xyzw, v1.xyzw
   2: mov o1.xyzw, r1.xyzw
   3: mov o0.xyz, r0.xyzx
   4: ret 
