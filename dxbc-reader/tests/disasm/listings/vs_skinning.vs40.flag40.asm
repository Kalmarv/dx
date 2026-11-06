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
dcl_temps 2
mov r0.x, v1.y
mul r0.xyzw, v2.yyyy, cb0[r0.x + 4].xyzw
mov r1.x, v1.x
mad r0.xyzw, cb0[r1.x + 4].xyzw, v2.xxxx, r0.xyzw
mov r1.x, v1.z
mad r0.xyzw, cb0[r1.x + 4].xyzw, v2.zzzz, r0.xyzw
mov r1.x, v1.w
mad r0.xyzw, cb0[r1.x + 4].xyzw, v2.wwww, r0.xyzw
add r0.xyzw, r0.xyzw, v0.xyzw
dp4 o0.x, r0.xyzw, cb0[0].xyzw
dp4 o0.y, r0.xyzw, cb0[1].xyzw
dp4 r1.z, r0.xyzw, cb0[2].xyzw
dp4 r1.w, r0.xyzw, cb0[3].xyzw
mov o0.zw, r1.zzzw
div o2.x, r1.z, r1.w
udiv null, r0.x, v3.x, l(3)
movc r0.x, r0.x, l(0.500000), l(2.000000)
ld r1.xyzw, v3.xxxx, t0.xyzw
mul o1.xyzw, r0.xxxx, r1.xyzw
ret 
