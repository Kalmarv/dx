vs_5_1
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[2:2][4], immediateIndexed, space=0
dcl_constantbuffer CB1[0:7][1], dynamicIndexed, space=1
dcl_input v0.xyz
dcl_input_sgv v1.x, instance_id
dcl_output_siv o0.xyzw, position
dcl_temps 2
and r0.x, v1.x, l(0x00000007)
mov r1.xyz, v0.xyzx
mov r1.w, l(0x3f800000)
mul r0.xyzw, r1.xyzw, CB1[r0.x + 0][0].xyzw
dp4 o0.x, r0.xyzw, CB0[2][0].xyzw
dp4 o0.y, r0.xyzw, CB0[2][1].xyzw
dp4 o0.z, r0.xyzw, CB0[2][2].xyzw
dp4 o0.w, r0.xyzw, CB0[2][3].xyzw
ret 
