ps_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
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
dcl_temps 7
//
// Initial variable locations:
//   v0.x <- n.x; v0.y <- n.y; v0.z <- n.z; 
//   v1.x <- p.x; v1.y <- p.y; v1.z <- p.z; 
//   v2.x <- uv.x; v2.y <- uv.y; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 24 "C:\dx-fixtures\classes_arrays2d.hlsl"
itof r0.xyz, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)  // r0.x <- acc.x; r0.y <- acc.y; r0.z <- acc.z

#line 25
mov r0.w, l(0x00000000)  // r0.w <- i
mov r1.xyz, r0.xyzx  // r1.x <- acc.x; r1.y <- acc.y; r1.z <- acc.z
mov r2.x, r0.w  // r2.x <- i
loop 
  ilt r2.y, r2.x, cb0[0].x
  breakc_z r2.y
  nop 
  imul null, r2.y, r2.x, l(0x00000002)
  mov r2.z, l(0x00000001)
  and r2.z, r2.z, cb0[0].y
  iadd r2.y, r2.z, r2.y
  mov r3.xyz, v0.xyzx
  mov r4.xyz, v1.xyzx
  fcall fp0[r2.y + 0][0]
  nop 
  imul null, r2.y, r2.x, l(0x00000002)
  iadd r2.y, r2.y, l(0x00000001)
  itof r2.z, r2.x
  fcall fp0[r2.y + 0][1]
  mul r2.yzw, r2.wwww, r5.xxyz
  add r1.xyz, r1.xyzx, r2.yzwy
  iadd r2.x, r2.x, l(0x00000001)
endloop 

#line 26
itof r1.w, l(0x00000001)
nop 
mov r0.x, l(0x00000001)
and r0.x, r0.x, cb0[0].y
fcall fp6[r0.x + 0][0]
mul r0.xyzw, r1.xyzw, r2.xyzw
nop 
itof r1.xy, l(0x00000002, 0x00000002, 0x00000000, 0x00000000)
mul r1.xy, r1.xyxx, v2.xyxx
fcall fp6[0][1]
add o0.xyzw, r0.xyzw, r2.xyzw
ret   // r1.x <- acc.x; r1.y <- acc.y; r1.z <- acc.z; r2.x <- i

#line 15 "C:\dx-fixtures\classes_arrays2d.hlsl"
label fb0
nop 
mov r4.xyz, -r4.xyzx
mov r2.z, this[r2.y + 0].y
mov r2.w, this[r2.y + 0].x
add r4.xyz, r4.xyzx, cb[r2.w + 0][r2.z + 0].xyzx  // r4.x <- l.x; r4.y <- l.y; r4.z <- l.z
dp3 r3.w, r4.xyzx, r4.xyzx
rsq r3.w, r3.w
mul r6.xyz, r3.wwww, r4.xyzx
dp3 r3.w, r3.xyzx, r6.xyzx
max r3.w, r3.w, l(0x00000000)
min r3.w, r3.w, l(0x3f800000)
mul r6.xyz, r3.wwww, cb[r2.w + 0][r2.z + 1].xyzx
nop 
dp3 r3.w, r4.xyzx, r4.xyzx
sqrt r3.w, r3.w

#line 16
itof r4.x, l(0x00000001)
div r2.z, r3.w, cb[r2.w + 0][r2.z + 1].w
mov r2.z, -r2.z
add r2.z, r2.z, r4.x
max r2.z, r2.z, l(0x00000000)
min r2.z, r2.z, l(0x3f800000)  // r2.z <- <Point::Atten return value>

#line 15
mul r5.xyz, r2.zzzz, r6.xyzx
ret 

#line 12 "C:\dx-fixtures\classes_arrays2d.hlsl"
label fb1
nop 
mov r2.z, this[r2.y + 0].y
mov r2.y, this[r2.y + 0].x
dp3 r2.w, r3.xyzx, cb[r2.y + 0][r2.z + 0].xyzx
max r2.w, r2.w, l(0x00000000)
min r2.w, r2.w, l(0x3f800000)
mul r5.xyz, r2.wwww, cb[r2.y + 0][r2.z + 1].xyzx
ret 

#line 16 "C:\dx-fixtures\classes_arrays2d.hlsl"
label fb2
nop 
itof r3.x, l(0x00000001)
mov r3.y, this[r2.y + 0].y
mov r3.z, this[r2.y + 0].x
div r2.z, r2.z, cb[r3.z + 0][r3.y + 1].w
mov r2.z, -r2.z
add r2.z, r2.z, r3.x
max r2.z, r2.z, l(0x00000000)
min r2.w, r2.z, l(0x3f800000)
ret 

#line 13 "C:\dx-fixtures\classes_arrays2d.hlsl"
label fb3
nop 
itof r2.w, l(0x00000001)
ret 

#line 18 "C:\dx-fixtures\classes_arrays2d.hlsl"
label fb4
nop 
mov r0.y, this[r0.x + 6].z
sample_indexable(texture2d)(float,float,float,float) r2.xyzw, v2.xyxx, t[r0.y + 0].xyzw, s0
ret 

#line 17 "C:\dx-fixtures\classes_arrays2d.hlsl"
label fb5  // r2.x <- i
nop 
mov r0.y, this[r0.x + 6].y
mov r0.x, this[r0.x + 6].x
mov r2.xyzw, cb[r0.x + 0][r0.y + 0].xyzw
ret 

#line 18 "C:\dx-fixtures\classes_arrays2d.hlsl"
label fb6
nop   // this[6].x <- this.x; this[6].y <- this.y; this[6].z <- this.z; this[6].w <- this.w
mov r1.z, this[6].z
sample_indexable(texture2d)(float,float,float,float) r2.xyzw, r1.xyxx, t[r1.z + 0].xyzw, s0
ret 

#line 17 "C:\dx-fixtures\classes_arrays2d.hlsl"
label fb7  // r1.z <- acc.z
nop   // this[6].x <- this.x; this[6].y <- this.y; this[6].z <- this.z; this[6].w <- this.w
mov r1.x, this[6].y
mov r1.y, this[6].x
mov r2.xyzw, cb[r1.y + 0][r1.x + 0].xyzw
ret 
