ds_5_0
dcl_input_control_point_count 4
dcl_tessellator_domain domain_quad
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[5], immediateIndexed
dcl_input_siv vpc4.x, finalQuadUInsideTessFactor
dcl_input_siv vpc5.x, finalQuadVInsideTessFactor
dcl_input vDomain.xy
dcl_input vPrim
dcl_input vicp[4][0].xyzw
dcl_input vicp[4][1].xyz
dcl_output_siv o0.xyzw, position
dcl_output o1.xyz
dcl_temps 2
add r0.xyzw, -vicp[3][0].xyzw, vicp[2][0].xyzw
mad r0.xyzw, vDomain.xxxx, r0.xyzw, vicp[3][0].xyzw
add r1.xyzw, -vicp[0][0].xyzw, vicp[1][0].xyzw
mad r1.xyzw, vDomain.xxxx, r1.xyzw, vicp[0][0].xyzw
add r0.xyzw, r0.xyzw, -r1.xyzw
mad r0.xyzw, vDomain.yyyy, r0.xyzw, r1.xyzw
add r1.x, -vpc4.x, vpc5.x
and r1.y, vPrim, l(0x00000001)
utof r1.y, r1.y
mad r1.x, r1.y, r1.x, vpc4.x
mul r0.xyzw, r0.xyzw, r1.xxxx
dp4 o0.x, r0.xyzw, cb0[1].xyzw
dp4 o0.y, r0.xyzw, cb0[2].xyzw
dp4 o0.z, r0.xyzw, cb0[3].xyzw
dp4 o0.w, r0.xyzw, cb0[4].xyzw
add r0.xyz, -vicp[1][1].xyzx, vicp[3][1].xyzx
mad o1.xyz, r1.yyyy, r0.xyzx, vicp[1][1].xyzx
ret 
