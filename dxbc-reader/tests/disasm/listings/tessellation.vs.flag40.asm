vs_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[5], immediateIndexed
dcl_input v0.xyz
dcl_input v1.xyzw
dcl_output o0.xyz
dcl_output o1.xyzw
mul o0.xyz, v0.xyzx, cb0[4].xxxx
mov o1.xyzw, v1.xyzw
ret 
