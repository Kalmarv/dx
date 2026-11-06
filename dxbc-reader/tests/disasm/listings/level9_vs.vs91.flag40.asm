vs_4_0
dcl_constantbuffer CB0[8], immediateIndexed
dcl_constantbuffer CB1[1], immediateIndexed
dcl_input v0.xyz
dcl_input v1.xyz
dcl_input v2.xy
dcl_output_siv o0.xyzw, position
dcl_output o1.xyzw
dcl_output o2.xy
dcl_temps 1
mul r0.xyz, v0.xyzx, cb1[0].xyzx
mov r0.w, l(1.000000)
dp4 o0.x, r0.xyzw, cb0[0].xyzw
dp4 o0.y, r0.xyzw, cb0[1].xyzw
dp4 o0.z, r0.xyzw, cb0[2].xyzw
dp4 o0.w, r0.xyzw, cb0[3].xyzw
dp3_sat r0.x, v1.xyzx, cb0[5].xyzx
mul r0.x, r0.x, cb0[5].w
dp3_sat r0.y, v1.xyzx, cb0[4].xyzx
mad r0.x, r0.y, cb0[4].w, r0.x
dp3_sat r0.y, v1.xyzx, cb0[6].xyzx
mad r0.x, r0.y, cb0[6].w, r0.x
dp3_sat r0.y, v1.xyzx, cb0[7].xyzx
mad o1.xyz, r0.yyyy, cb0[7].wwww, r0.xxxx
mov o1.w, l(1.000000)
mov o2.xy, v2.xyxx
ret 
