vs_4_0
dcl_constantbuffer CB0[5], immediateIndexed
dcl_input v0.xyz
dcl_input v1.xy
dcl_output_siv o0.xyzw, position
dcl_output o1.xy
dcl_temps 1
mul o1.xy, v1.xyxx, cb0[4].xyxx
itof r0.w, l(1)
mov r0.xyz, v0.xyzx
dp4 o0.x, r0.xyzw, cb0[0].xyzw
dp4 o0.y, r0.xyzw, cb0[1].xyzw
dp4 o0.z, r0.xyzw, cb0[2].xyzw
dp4 o0.w, r0.xyzw, cb0[3].xyzw
ret 
