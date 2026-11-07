ps_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[2], immediateIndexed
dcl_sampler s0, mode_default
dcl_sampler s1, mode_default
dcl_sampler s2, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_resource_texture2d (float,float,float,float) t1
dcl_resource_texture2d (float,float,float,float) t2
dcl_function_body fb0
dcl_function_body fb1
dcl_function_body fb2
dcl_function_body fb3
dcl_function_body fb4
dcl_function_body fb5
dcl_function_body fb6
dcl_function_body fb7
dcl_function_body fb8
dcl_function_body fb9
dcl_function_body fb10
dcl_function_table ft0 = {fb0}
dcl_function_table ft1 = {fb1}
dcl_function_table ft2 = {fb2}
dcl_function_table ft3 = {fb3, fb6}
dcl_function_table ft4 = {fb4, fb7}
dcl_function_table ft5 = {fb5, fb8}
dcl_function_table ft6 = {fb9}
dcl_function_table ft7 = {fb10}
dcl_interface fp0[1][1] = {ft0, ft1, ft2}
dcl_interface fp1[3][2] = {ft3, ft4, ft5}
dcl_interface fp4[1][1] = {ft6, ft7}
dcl_input_ps linear v0.xyz
dcl_output o0.xyzw
dcl_temps 4
//
// Initial variable locations:
//   v0.x <- n.x; v0.y <- n.y; v0.z <- n.z; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 25 "C:\dx-fixtures\classes_resources.hlsl"
fcall fp0[0][0]
fcall fp1[0][0]
add r0.xyz, r0.xyzx, r1.xyzx
fcall fp1[2][1]
add r0.xyz, r0.xyzx, r1.xyzx  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z

#line 26
fcall fp4[0][0]
mov o0.xyzw, r1.xyzw
ret 

#line 13 "C:\dx-fixtures\classes_resources.hlsl"
label_sat fb0
mov r0.xyz, v0.xyzx
ret 

#line 12 "C:\dx-fixtures\classes_resources.hlsl"
label [precise(y)] fb1
mov r0.w, this[0].z
mov r1.x, this[0].w
sample_indexable(texture2d)(float,float,float,float) r1.yzw, v0.xyxx, t[r0.w + 0].wxyz, s[r1.x + 0]
sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.yzyy, t[r0.w + 1].xyzw, s[r1.x + 1]
mov r0.w, this[0].y
mov r1.x, this[0].x
mad r0.xyz, r2.xyzx, cb[r1.x + 0][r0.w + 0].xyzx, r1.yzwy
ret 

#line 11 "C:\dx-fixtures\classes_resources.hlsl"
label_sat fb2
mov r0.w, this[0].z
mov r1.x, this[0].w
sample_indexable(texture2d)(float,float,float,float) r0.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
ret 

#line 13 "C:\dx-fixtures\classes_resources.hlsl"
label [precise(y)] fb3
mov r1.xyz, v0.xyzx
ret 

#line 12 "C:\dx-fixtures\classes_resources.hlsl"
label_sat fb4
mov r0.w, this[1].z
mov r1.w, this[1].w
sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yzyy, t[r0.w + 1].xyzw, s[r1.w + 1]
mov r0.w, this[1].y
mov r1.w, this[1].x
mad r1.xyz, r3.xyzx, cb[r1.w + 0][r0.w + 0].xyzx, r2.xyzx
ret 

#line 11 "C:\dx-fixtures\classes_resources.hlsl"
label [precise(y)] fb5
mov r0.w, this[1].z
mov r1.w, this[1].w
sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
ret 

#line 13 "C:\dx-fixtures\classes_resources.hlsl"
label_sat fb6
mov r1.xyz, v0.zyxz
ret 

#line 12 "C:\dx-fixtures\classes_resources.hlsl"
label [precise(y)] fb7
mov r0.w, this[3].z
mov r1.w, this[3].w
sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.zyzz, t[r0.w + 0].xyzw, s[r1.w + 0]
sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yxyy, t[r0.w + 1].xyzw, s[r1.w + 1]
mov r0.w, this[3].y
mov r1.w, this[3].x
mad r1.xyz, r3.xyzx, cb[r1.w + 0][r0.w + 0].xyzx, r2.xyzx
ret 

#line 11 "C:\dx-fixtures\classes_resources.hlsl"
label_sat fb8
mov r0.w, this[3].z
mov r1.w, this[3].w
sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.zyzz, t[r0.w + 0].xyzw, s[r1.w + 0]
ret   // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z

#line 15 "C:\dx-fixtures\classes_resources.hlsl"
label [precise(y)] fb9
mov r1.x, l(0x3f800000)
mov r1.yzw, r0.zzyx
ret 

#line 14 "C:\dx-fixtures\classes_resources.hlsl"
label_sat fb10
mov r0.w, l(0x3f800000)
mov r2.xy, this[4].yxyy
mul r1.xyzw, r0.xyzw, cb[r2.y + 0][r2.x + 0].xyzw
ret 
