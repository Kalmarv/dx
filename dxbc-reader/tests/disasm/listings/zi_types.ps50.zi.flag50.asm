ps_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[2], immediateIndexed
dcl_input_ps linear v0.xyzw
dcl_input_ps linear v1.xyzw
dcl_input_ps linear v2.xyz
dcl_input_ps linear v3.xyzw
dcl_input_ps linear v5.xyz
dcl_input_ps linear v6.xyz
dcl_output o0.xyzw
dcl_temps 2
add r0.xyz, v2.xyzx, v5.xyzx
dp3 r0.w, r0.xyzx, r0.xyzx
rsq r0.w, r0.w
mul r0.xyz, r0.wwww, r0.xyzx
dp3_sat r0.x, r0.xyzx, cb0[0].xyzx
mul r0.xyz, r0.xxxx, cb0[1].xyzx
dp3_sat r0.w, v6.xyzx, cb0[0].xyzx
mul r1.xyz, r0.wwww, cb0[1].xyzx
mad r0.xyz, r0.xyzx, cb0[1].wwww, r1.xyzx
mov r0.w, l(1.000000)
mul r1.xyzw, v0.xyzw, l(8.500000, 8.500000, 8.500000, 8.500000)
mad r0.xyzw, r0.xyzw, v3.xyzw, r1.xyzw
mad o0.xyzw, v1.xyzw, l(4.000000, 4.000000, 4.000000, 4.000000), r0.xyzw
ret 
