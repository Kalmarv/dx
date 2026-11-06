vs_4_0
dcl_constantbuffer CB0[68], dynamicIndexed
dcl_resource_buffer (float,float,float,float) t0
dcl_input v0.xyzw
dcl_input v1.xyzw
dcl_input v2.xyzw
dcl_input_sgv v3.x, vertex_id
dcl_output_siv o0.xyzw, position
dcl_output o1.xyzw
dcl_output o2.x
dcl_temps 3
itof r0.xyzw, l(0, 0, 0, 0)
mov r1.x, v1.x
mul r1.xyzw, v2.xxxx, cb0[r1.x + 4].xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
mov r1.x, v1.y
mul r1.xyzw, v2.yyyy, cb0[r1.x + 4].xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
mov r1.x, v1.z
mul r1.xyzw, v2.zzzz, cb0[r1.x + 4].xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
mov r1.x, v1.w
mul r1.xyzw, v2.wwww, cb0[r1.x + 4].xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
add r0.xyzw, r0.xyzw, v0.xyzw
dp4 r1.x, r0.xyzw, cb0[0].xyzw
dp4 r1.y, r0.xyzw, cb0[1].xyzw
dp4 r1.z, r0.xyzw, cb0[2].xyzw
dp4 r1.w, r0.xyzw, cb0[3].xyzw
mov r0.x, v3.x
ld r0.xyzw, r0.xxxx, t0.xyzw
mov r2.x, l(3)
udiv null, r2.x, v3.x, r2.x
mov r2.y, l(0)
ieq r2.x, r2.y, r2.x
itof r2.y, l(2)
movc r2.x, r2.x, r2.y, l(0.500000)
mul r0.xyzw, r0.xyzw, r2.xxxx
div r2.x, r1.z, r1.w
mov o0.xyzw, r1.xyzw
mov o1.xyzw, r0.xyzw
mov o2.x, r2.x
ret 
