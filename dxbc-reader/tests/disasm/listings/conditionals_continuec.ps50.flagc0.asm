ps_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[1], immediateIndexed
dcl_constantbuffer CB1[7], immediateIndexed
dcl_sampler s0, mode_default
dcl_resource_texture2d (float,float,float,float) t2
dcl_function_body fb0
dcl_function_body fb1
dcl_function_body fb2
dcl_function_body fb3
dcl_function_body fb4
dcl_function_body fb5
dcl_function_body fb6
dcl_function_body fb7
dcl_function_table ft0 = {fb0, fb2}
dcl_function_table ft1 = {fb1, fb3}
dcl_function_table ft2 = {fb4, fb6}
dcl_function_table ft3 = {fb5, fb7}
dcl_interface_dynamicindexed fp0[6][2] = {ft0, ft1}
dcl_interface_dynamicindexed fp6[2][2] = {ft2, ft3}
dcl_input_ps linear v0.xyz
dcl_input_ps linear v1.xyz
dcl_input_ps linear v2.xy
dcl_output o0.xyzw
dcl_temps 5
and r0.x, cb0[0].y, l(0x00000001)
mov r1.xyz, l(0x00000000,0x00000000,0x00000000,0x00000000)
mov r0.y, l(0x00000000)
loop 
  ige r0.z, r0.y, cb0[0].x
  continuec_nz l(0x40000000)
  bfi r0.z, l(0x0000001f), l(0x00000001), r0.y, cb0[0].y
  fcall fp0[r0.z + 0][0]
  bfi r0.z, l(0x0000001f), l(0x00000001), r0.y, l(0x00000001)
  fcall fp0[r0.z + 0][1]
  mad r1.xyz, r2.xyzx, r0.wwww, r1.xyzx
  iadd r0.y, r0.y, l(0x00000001)
endloop 
fcall fp6[r0.x + 0][0]
mov r1.w, l(0x3f800000)
fcall fp6[0][1]
mad o0.xyzw, r1.xyzw, r2.xyzw, r0.xyzw
ret 
label fb0
mov r0.w, this[r0.z + 0].y
mov r2.w, this[r0.z + 0].x
add r3.xyz, -v1.xyzx, cb[r2.w + 0][r0.w + 0].xyzx
dp3 r3.w, r3.xyzx, r3.xyzx
rsq r4.x, r3.w
mul r3.xyz, r3.xyzx, r4.xxxx
dp3_sat r3.x, v0.xyzx, r3.xyzx
mul r3.xyz, r3.xxxx, cb[r2.w + 0][r0.w + 1].xyzx
sqrt r3.w, r3.w
div r0.w, r3.w, cb[r2.w + 0][r0.w + 1].w
add_sat r0.w, -r0.w, l(0x3f800000)
mul r2.xyz, r0.wwww, r3.xyzx
ret 
label fb1
mov r0.w, this[r0.z + 0].y
mov r0.z, this[r0.z + 0].x
dp3_sat r2.w, v0.xyzx, cb[r0.z + 0][r0.w + 0].xyzx
mul r2.xyz, r2.wwww, cb[r0.z + 0][r0.w + 1].xyzx
ret 
label fb2
itof r2.w, r0.y
mov r3.x, this[r0.z + 0].y
mov r0.z, this[r0.z + 0].x
div r0.z, r2.w, cb[r0.z + 0][r3.x + 1].w
add_sat r0.w, -r0.z, l(0x3f800000)
ret 
label fb3
mov r0.w, l(0x3f800000)
ret 
label fb4
mov r0.y, this[r0.x + 6].z
sample_indexable(texture2d)(float,float,float,float) r2.xyzw, v2.xyxx, t[r0.y + 0].xyzw, s0
ret 
label fb5
mov r0.y, this[r0.x + 6].y
mov r0.x, this[r0.x + 6].x
mov r2.xyzw, cb[r0.x + 0][r0.y + 0].xyzw
ret 
label fb6
add r3.xy, v2.xyxx, v2.xyxx
mov r3.z, this[6].z
sample_indexable(texture2d)(float,float,float,float) r0.xyzw, r3.xyxx, t[r3.z + 0].xyzw, s0
ret 
label fb7
mov r3.xy, this[6].yxyy
mov r0.xyzw, cb[r3.y + 0][r3.x + 0].xyzw
ret 
