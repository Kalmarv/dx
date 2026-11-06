ds_5_0
dcl_input_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[5], immediateIndexed
dcl_input vpc0.yzw
dcl_input_siv vpc1.x, finalTriVeq0EdgeTessFactor
dcl_input_siv vpc3.x, finalTriInsideTessFactor
dcl_input vDomain.xyz
dcl_input vicp[3][0].xyzw
dcl_input vicp[3][1].xyz
dcl_output_siv o0.xyzw, position
dcl_output o1.xyz
dcl_temps 2
mul r0.xyzw, vDomain.yyyy, vicp[1][0].xyzw
mad r0.xyzw, vicp[0][0].xyzw, vDomain.xxxx, r0.xyzw
mad r0.xyzw, vicp[2][0].xyzw, vDomain.zzzz, r0.xyzw
mov r1.xyz, vpc0.yzwy
mov r1.w, l(0)
mad r0.xyzw, r1.xyzw, vpc1.xxxx, r0.xyzw
dp4 o0.x, r0.xyzw, cb0[1].xyzw
dp4 o0.y, r0.xyzw, cb0[2].xyzw
dp4 o0.z, r0.xyzw, cb0[3].xyzw
dp4 o0.w, r0.xyzw, cb0[4].xyzw
mul r0.xyz, vDomain.yyyy, vicp[1][1].xyzx
mad r0.xyz, vicp[0][1].xyzx, vDomain.xxxx, r0.xyzx
mad r0.xyz, vicp[2][1].xyzx, vDomain.zzzz, r0.xyzx
dp3 r0.w, r0.xyzx, r0.xyzx
rsq r0.w, r0.w
mul r0.xyz, r0.wwww, r0.xyzx
mul o1.xyz, r0.xyzx, vpc3.xxxx
ret 
