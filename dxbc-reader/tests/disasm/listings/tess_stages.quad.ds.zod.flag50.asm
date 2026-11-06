ds_5_0
dcl_input_control_point_count 4
dcl_tessellator_domain domain_quad
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_constantbuffer CB0[5], immediateIndexed
dcl_input_siv vpc4.x, finalQuadUInsideTessFactor
dcl_input_siv vpc5.x, finalQuadVInsideTessFactor
dcl_input vDomain.xy
dcl_input vPrim
dcl_input vicp[4][0].xyzw
dcl_input vicp[4][1].xyz
dcl_output_siv o0.xyzw, position
dcl_output o1.xyz
dcl_temps 3
mov r0.xyzw, -vicp[0][0].xyzw
add r0.xyzw, r0.xyzw, vicp[1][0].xyzw
mul r0.xyzw, r0.xyzw, vDomain.xxxx
add r0.xyzw, r0.xyzw, vicp[0][0].xyzw
mov r1.xyzw, -vicp[3][0].xyzw
add r1.xyzw, r1.xyzw, vicp[2][0].xyzw
mul r1.xyzw, r1.xyzw, vDomain.xxxx
add r1.xyzw, r1.xyzw, vicp[3][0].xyzw
mov r2.xyzw, -r0.xyzw
add r1.xyzw, r1.xyzw, r2.xyzw
mul r1.xyzw, r1.xyzw, vDomain.yyyy
add r0.xyzw, r0.xyzw, r1.xyzw
mov r1.x, l(1)
and r1.x, r1.x, vPrim
utof r1.x, r1.x
mov r1.y, -vpc4.x
add r1.y, r1.y, vpc5.x
mul r1.x, r1.y, r1.x
add r1.x, r1.x, vpc4.x
mul r0.xyzw, r0.xyzw, r1.xxxx
dp4 r1.x, r0.xyzw, cb0[1].xyzw
dp4 r1.y, r0.xyzw, cb0[2].xyzw
dp4 r1.z, r0.xyzw, cb0[3].xyzw
dp4 r1.w, r0.xyzw, cb0[4].xyzw
mov r0.x, l(1)
and r0.x, r0.x, vPrim
utof r0.x, r0.x
mov r0.yzw, -vicp[1][1].xxyz
add r0.yzw, r0.yyzw, vicp[3][1].xxyz
mul r0.xyz, r0.yzwy, r0.xxxx
add r0.xyz, r0.xyzx, vicp[1][1].xyzx
mov o0.xyzw, r1.xyzw
mov o1.xyz, r0.xyzx
ret 
