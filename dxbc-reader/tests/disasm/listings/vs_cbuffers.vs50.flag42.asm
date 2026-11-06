vs_5_0
dcl_globalFlags refactoringAllowed | enableDoublePrecisionFloatOps | enableMinimumPrecision
dcl_constantbuffer CB0[23], dynamicIndexed
dcl_constantbuffer CB3[129], dynamicIndexed
dcl_resource_texture2d (float,float,float,float) t0
dcl_resource_buffer (uint,uint,uint,uint) t1
dcl_resource_buffer (mixed,mixed,mixed,mixed) t2
dcl_input v0.xyz
dcl_input v1.xyz
dcl_input v2.xy
dcl_input v3.xy
dcl_input_sgv v4.x, vertex_id
dcl_input_sgv v5.x, instance_id
dcl_output_siv o0.xyzw, position
dcl_output o1.xyz
dcl_output o2.xy
dcl_output o3.xyzw
dcl_output_siv o4.x, clip_distance
dcl_output o5.x
dcl_temps 4
and r0.x, v4.x, l(15)
ushr r0.y, v4.x, l(4)
mov r0.zw, l(0,0,0,0)
ld_indexable(texture2d)(float,float,float,float) r0.x, r0.xyzw, t0.xyzw
mov r1.xyz, v0.xyzx
mov r1.w, l(1.000000)
ishl r0.yz, v3.xxyx, l(0, 2, 2, 0)
dp4 r2.x, cb3[r0.y + 0].xyzw, r1.xyzw
dp4 r2.y, cb3[r0.y + 1].xyzw, r1.xyzw
dp4 r2.z, cb3[r0.y + 2].xyzw, r1.xyzw
mad r2.xyz, r2.xyzx, cb3[r0.y + 3].xxxx, v0.xyzx
dp4 r3.x, cb3[r0.z + 0].xyzw, r1.xyzw
dp4 r3.y, cb3[r0.z + 1].xyzw, r1.xyzw
dp4 r3.z, cb3[r0.z + 2].xyzw, r1.xyzw
mad r0.yzw, r3.xxyz, cb3[r0.z + 3].xxxx, r2.xxyz
add r0.x, r0.x, r0.z
mul r1.xyzw, r0.xxxx, cb0[5].xyzw
mad r1.xyzw, r0.yyyy, cb0[4].xyzw, r1.xyzw
mad r0.xyzw, r0.wwww, cb0[6].xyzw, r1.xyzw
add r0.xyzw, r0.xyzw, cb0[7].xyzw
dp4 o0.x, r0.xyzw, cb0[0].xyzw
dp4 o0.y, r0.xyzw, cb0[1].xyzw
dp4 o0.z, r0.xyzw, cb0[2].xyzw
dp4 o0.w, r0.xyzw, cb0[3].xyzw
mad r1.xyz, cb0[8].xyzx, cb0[8].wwww, v1.xyzx
dp3 r0.w, r1.xyzx, r1.xyzx
rsq r0.w, r0.w
mul o1.xyz, r0.wwww, r1.xyzx
add o2.xy, v2.xyxx, cb0[9].xyxx
dp3_sat r0.w, v1.xyzx, cb0[11].xyzx
dp3_sat r1.x, v1.xyzx, cb0[14].xyzx
and r1.y, cb0[9].z, l(1)
mul r2.xyzw, r1.xxxx, cb0[r1.y + 15].xyzw
mad r2.xyzw, cb0[r1.y + 12].xyzw, r0.wwww, r2.xyzw
dp3_sat r0.w, v1.xyzx, cb0[17].xyzx
mad r2.xyzw, cb0[r1.y + 18].xyzw, r0.wwww, r2.xyzw
dp3_sat r0.w, v1.xyzx, cb0[20].xyzx
mad r1.xyzw, cb0[r1.y + 21].xyzw, r0.wwww, r2.xyzw
and r0.w, v5.x, l(7)
ld_indexable(buffer)(mixed,mixed,mixed,mixed) r2.xyzw, r0.wwww, t2.xyzw
movc r2.xyzw, cb0[10].xxxx, r2.xyzw, l(1.000000,1.000000,1.000000,1.000000)
mul r1.xyzw, r1.xyzw, r2.xyzw
dtof r0.w, cb3[127].zwzw
mul r0.w, r0.w, cb3[128].x {min16f as def32}
mul o3.xyzw, r0.wwww, r1.xyzw
ld_indexable(buffer)(uint,uint,uint,uint) r1.xyz, v5.xxxx, t1.xyzw
utof r1.xyz, r1.xyzx
dp3 o4.x, r0.xyzx, r1.xyzx
xor o5.x, v4.x, v5.x
ret 
