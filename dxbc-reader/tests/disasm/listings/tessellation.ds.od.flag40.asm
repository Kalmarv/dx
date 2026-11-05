ds_5_0
dcl_input_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_constantbuffer CB0[4], immediateIndexed
dcl_input_siv vpc0.x, finalTriUeq0EdgeTessFactor
dcl_input vpc0.yzw
dcl_input_siv vpc3.x, finalTriInsideTessFactor
dcl_input vDomain.xyz
dcl_input vicp[3][0].xyz
dcl_input vicp[3][1].xyzw
dcl_output_siv o0.xyzw, position
dcl_output o1.xyzw
dcl_temps 3
mul r0.xyz, vDomain.xxxx, vicp[0][0].xyzx
mul r1.xyz, vDomain.yyyy, vicp[1][0].xyzx
add r0.xyz, r0.xyzx, r1.xyzx
mul r1.xyz, vDomain.zzzz, vicp[2][0].xyzx
add r0.xyz, r0.xyzx, r1.xyzx
mul r1.xyz, vpc0.yzwy, l(0.500000, 0.500000, 0.500000, 0.000000)
mul r0.w, vpc0.x, l(0.250000)
add r1.xyz, r0.wwww, r1.xyzx
mul r0.w, vpc3.x, l(0.125000)
add r1.xyz, r0.wwww, r1.xyzx
add r0.xyz, r0.xyzx, r1.xyzx
mul r1.xyzw, r0.xxxx, cb0[0].xyzw
mul r2.xyzw, r0.yyyy, cb0[1].xyzw
add r1.xyzw, r1.xyzw, r2.xyzw
mul r0.xyzw, r0.zzzz, cb0[2].xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
mul r1.xyzw, cb0[3].xyzw, l(1.000000, 1.000000, 1.000000, 1.000000)
add r0.xyzw, r0.xyzw, r1.xyzw
mul r1.xyzw, vDomain.xxxx, vicp[0][1].xyzw
mul r2.xyzw, vDomain.yyyy, vicp[1][1].xyzw
add r1.xyzw, r1.xyzw, r2.xyzw
mul r2.xyzw, vDomain.zzzz, vicp[2][1].xyzw
add r1.xyzw, r1.xyzw, r2.xyzw
mov o0.xyzw, r0.xyzw
mov o1.xyzw, r1.xyzw
ret 
