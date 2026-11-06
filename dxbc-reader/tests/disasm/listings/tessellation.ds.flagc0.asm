ds_5_0
dcl_input_control_point_count 3
dcl_tessellator_domain domain_tri
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[4], immediateIndexed
dcl_input_siv vpc0.x, finalTriUeq0EdgeTessFactor
dcl_input vpc0.yzw
dcl_input_siv vpc3.x, finalTriInsideTessFactor
dcl_input vDomain.xyz
dcl_input vicp[3][0].xyz
dcl_input vicp[3][1].xyzw
dcl_output_siv o0.xyzw, position
dcl_output o1.xyzw
dcl_temps 2
mul r0.xyz, vDomain.yyyy, vicp[1][0].xyzx
mad r0.xyz, vicp[0][0].xyzx, vDomain.xxxx, r0.xyzx
mad r0.xyz, vicp[2][0].xyzx, vDomain.zzzz, r0.xyzx
mul r0.w, vpc0.x, l(0x3e800000)
mad r1.xyz, vpc0.yzwy, l(0x3f000000, 0x3f000000, 0x3f000000, 0x00000000), r0.wwww
mad r1.xyz, vpc3.xxxx, l(0x3e000000, 0x3e000000, 0x3e000000, 0x00000000), r1.xyzx
add r0.xyz, r0.xyzx, r1.xyzx
mul r1.xyzw, r0.yyyy, cb0[1].xyzw
mad r1.xyzw, cb0[0].xyzw, r0.xxxx, r1.xyzw
mad r0.xyzw, cb0[2].xyzw, r0.zzzz, r1.xyzw
add o0.xyzw, r0.xyzw, cb0[3].xyzw
mul r0.xyzw, vDomain.yyyy, vicp[1][1].xyzw
mad r0.xyzw, vicp[0][1].xyzw, vDomain.xxxx, r0.xyzw
mad o1.xyzw, vicp[2][1].xyzw, vDomain.zzzz, r0.xyzw
ret 
