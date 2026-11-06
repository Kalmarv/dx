ds_5_0
dcl_input_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_constantbuffer CB0[5], immediateIndexed
dcl_input vpc0.yzw
dcl_input_siv vpc1.x, finalTriVeq0EdgeTessFactor
dcl_input_siv vpc3.x, finalTriInsideTessFactor
dcl_input vDomain.xyz
dcl_input vicp[3][0].xyzw
dcl_input vicp[3][1].xyz
dcl_output_siv o0.xyzw, position
dcl_output o1.xyz
dcl_temps 3
mul r0.xyzw, vDomain.xxxx, vicp[0][0].xyzw
mul r1.xyzw, vDomain.yyyy, vicp[1][0].xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
mul r1.xyzw, vDomain.zzzz, vicp[2][0].xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
itof r1.w, l(0)
mov r1.xyz, vpc0.yzwy
mul r1.xyzw, r1.xyzw, vpc1.xxxx
add r0.xyzw, r0.xyzw, r1.xyzw
dp4 r1.x, r0.xyzw, cb0[1].xyzw
dp4 r1.y, r0.xyzw, cb0[2].xyzw
dp4 r1.z, r0.xyzw, cb0[3].xyzw
dp4 r1.w, r0.xyzw, cb0[4].xyzw
mul r0.xyz, vDomain.xxxx, vicp[0][1].xyzx
mul r2.xyz, vDomain.yyyy, vicp[1][1].xyzx
add r0.xyz, r0.xyzx, r2.xyzx
mul r2.xyz, vDomain.zzzz, vicp[2][1].xyzx
add r0.xyz, r0.xyzx, r2.xyzx
dp3 r0.w, r0.xyzx, r0.xyzx
rsq r0.w, r0.w
mul r0.xyz, r0.wwww, r0.xyzx
mul r0.xyz, r0.xyzx, vpc3.xxxx
mov o0.xyzw, r1.xyzw
mov o1.xyz, r0.xyzx
ret 
