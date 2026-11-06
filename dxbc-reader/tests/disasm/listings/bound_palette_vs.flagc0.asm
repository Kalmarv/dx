vs_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[6], dynamicIndexed
dcl_input v0.xyz
dcl_input v1.x
dcl_output_siv o0.xyzw, position
dcl_temps 2
mov o0.w, l(0x3f800000)
imul null, r0.x, v1.x, l(0x00000003)
mov r1.xyz, v0.xyzx
mov r1.w, l(0x3f800000)
dp4 o0.x, cb0[r0.x + 0].xyzw, r1.xyzw
imad r0.xy, v1.xxxx, l(0x00000003, 0x00000003, 0x00000000, 0x00000000), l(0x00000001, 0x00000002, 0x00000000, 0x00000000)
dp4 o0.y, cb0[r0.x + 0].xyzw, r1.xyzw
dp4 o0.z, cb0[r0.y + 0].xyzw, r1.xyzw
ret 
