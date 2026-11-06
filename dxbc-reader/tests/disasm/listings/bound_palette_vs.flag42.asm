vs_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[6], dynamicIndexed
dcl_input v0.xyz
dcl_input v1.x
dcl_output_siv o0.xyzw, position
dcl_temps 2
mov o0.w, l(1.000000)
imul null, r0.x, v1.x, l(3)
mov r1.xyz, v0.xyzx
mov r1.w, l(1.000000)
dp4 o0.x, cb0[r0.x + 0].xyzw, r1.xyzw
imad r0.xy, v1.xxxx, l(3, 3, 0, 0), l(1, 2, 0, 0)
dp4 o0.y, cb0[r0.x + 0].xyzw, r1.xyzw
dp4 o0.z, cb0[r0.y + 0].xyzw, r1.xyzw
ret 
