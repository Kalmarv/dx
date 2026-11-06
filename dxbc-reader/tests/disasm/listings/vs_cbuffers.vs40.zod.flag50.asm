vs_4_0
dcl_immediateConstantBuffer { { -1, 0, 0, 0},
                              { 0, -1, 0, 0},
                              { 0, 0, -1, 0},
                              { 0, 0, 0, -1} }
dcl_constantbuffer CB0[23], dynamicIndexed
dcl_constantbuffer CB3[128], dynamicIndexed
dcl_resource_texture2d (float,float,float,float) t0
dcl_resource_buffer (uint,uint,uint,uint) t1
dcl_resource_buffer (mixed,mixed,mixed,mixed) t2
dcl_input v0.xyz
dcl_input v1.xyz
dcl_input v2.xy
dcl_input v3.xyz
dcl_input_sgv v4.x, vertex_id
dcl_input_sgv v5.x, instance_id
dcl_output_siv o0.xyzw, position
dcl_output o1.xyz
dcl_output o2.xy
dcl_output o3.xyzw
dcl_output_siv o4.x, clip_distance
dcl_output o5.x
dcl_temps 7
mov r0.xyz, v0.xyzx
mov r0.w, l(0)
mov r1.xyz, r0.xyzx
mov r1.w, r0.w
loop 
  mov r2.x, l(2)
  ult r2.x, r1.w, r2.x
  breakc_z r2.x
  and r2.xyz, v3.xyzx, icb[r1.w + 0].xyzx
  mov r2.w, l(0)
  or r2.xy, r2.ywyy, r2.xzxx
  or r2.x, r2.y, r2.x
  imul null, r2.x, r2.x, l(4)
  mov r3.xyzw, cb3[r2.x + 0].xyzw
  mov r4.xyzw, cb3[r2.x + 1].xyzw
  mov r5.xyzw, cb3[r2.x + 2].xyzw
  mov r2.x, cb3[r2.x + 3].x
  itof r6.w, l(1)
  mov r6.xyz, v0.xyzx
  dp4 r3.x, r3.xyzw, r6.xyzw
  dp4 r3.y, r4.xyzw, r6.xyzw
  dp4 r3.z, r5.xyzw, r6.xyzw
  mul r2.xyz, r2.xxxx, r3.xyzx
  add r1.xyz, r1.xyzx, r2.xyzx
  iadd r1.w, r1.w, l(1)
endloop 
mov r0.x, l(15)
and r0.x, r0.x, v4.x
mov r1.w, l(4)
ushr r0.y, v4.x, r1.w
mov r0.zw, l(0,0,0,0)
ld r0.xyzw, r0.xyzw, t0.xyzw
add r0.x, r0.x, r1.y
itof r0.y, l(1)
mul r2.xyzw, r1.xxxx, cb0[4].xyzw
mul r3.xyzw, r0.xxxx, cb0[5].xyzw
add r2.xyzw, r2.xyzw, r3.xyzw
mul r1.xyzw, r1.zzzz, cb0[6].xyzw
add r1.xyzw, r1.xyzw, r2.xyzw
mul r0.xyzw, r0.yyyy, cb0[7].xyzw
add r0.xyzw, r0.xyzw, r1.xyzw
dp4 r1.x, r0.xyzw, cb0[0].xyzw
dp4 r1.y, r0.xyzw, cb0[1].xyzw
dp4 r1.z, r0.xyzw, cb0[2].xyzw
dp4 r1.w, r0.xyzw, cb0[3].xyzw
mul r2.xyz, cb0[8].wwww, cb0[8].xyzx
add r2.xyz, r2.xyzx, v1.xyzx
dp3 r0.w, r2.xyzx, r2.xyzx
rsq r0.w, r0.w
mul r2.xyz, r0.wwww, r2.xyzx
add r3.xy, v2.xyxx, cb0[9].xyxx
itof r4.xyzw, l(0, 0, 0, 0)
mov r0.w, l(1)
and r0.w, r0.w, cb0[9].z
dp3 r2.w, v1.xyzx, cb0[11].xyzx
max r2.w, r2.w, l(0.000000)
min r2.w, r2.w, l(1.000000)
mul r5.xyzw, r2.wwww, cb0[r0.w + 12].xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
mov r0.w, l(1)
and r0.w, r0.w, cb0[9].z
dp3 r2.w, v1.xyzx, cb0[14].xyzx
max r2.w, r2.w, l(0.000000)
min r2.w, r2.w, l(1.000000)
mul r5.xyzw, r2.wwww, cb0[r0.w + 15].xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
mov r0.w, l(1)
and r0.w, r0.w, cb0[9].z
dp3 r2.w, v1.xyzx, cb0[17].xyzx
max r2.w, r2.w, l(0.000000)
min r2.w, r2.w, l(1.000000)
mul r5.xyzw, r2.wwww, cb0[r0.w + 18].xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
mov r0.w, l(1)
and r0.w, r0.w, cb0[9].z
dp3 r2.w, v1.xyzx, cb0[20].xyzx
max r2.w, r2.w, l(0.000000)
min r2.w, r2.w, l(1.000000)
mul r5.xyzw, r2.wwww, cb0[r0.w + 21].xyzw
add r4.xyzw, r4.xyzw, r5.xyzw
ine r0.w, l(0, 0, 0, 0), cb0[10].x
mov r2.w, l(7)
and r2.w, r2.w, v5.x
itof r5.xyzw, l(1, 1, 1, 1)
iadd r2.w, r2.w, l(0)
ld r6.xyzw, r2.wwww, t2.xyzw
movc r5.xyzw, r0.wwww, r6.xyzw, r5.xyzw
mul r4.xyzw, r4.xyzw, r5.xyzw
ld r5.xyzw, v5.xxxx, t1.xyzw
utof r5.xyz, r5.xyzx
dp3 r0.x, r0.xyzx, r5.xyzx
xor r0.y, v4.x, v5.x
mov o0.xyzw, r1.xyzw
mov o3.xyzw, r4.xyzw
mov o1.xyz, r2.xyzx
mov o2.xy, r3.xyxx
mov o4.x, r0.x
mov o5.x, r0.y
ret 
