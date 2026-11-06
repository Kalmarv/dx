ps_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[1], immediateIndexed
dcl_function_table ft0 = {}
dcl_interface fp0[1][0] = {ft0}
dcl_input_ps linear v0.xyz
dcl_input_ps_sgv constant v1.x, sampleIndex
dcl_output o0.xyzw
dcl_temps 1
mov r0.xy, this[0].yxyy
mul r0.xyz, v0.xyzx, cb[r0.y + 0][r0.x + 0].xxxx
utof r0.w, v1.x
mul o0.xyz, r0.wwww, r0.xyzx
mov o0.w, l(0x3f800000)
ret 
