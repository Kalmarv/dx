ps_5_0
dcl_globalFlags refactoringAllowed | skipOptimization
dcl_constantbuffer CB0[5], immediateIndexed
dcl_sampler s0, mode_default
dcl_sampler s1, mode_default
dcl_sampler s2, mode_default
dcl_sampler s3, mode_default
dcl_sampler s4, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_resource_texture2d (float,float,float,float) t1
dcl_resource_texture2d (float,float,float,float) t2
dcl_resource_texture2d (float,float,float,float) t3
dcl_resource_texture2d (float,float,float,float) t4
dcl_function_body fb0
dcl_function_body fb1
dcl_function_body fb2
dcl_function_body fb3
dcl_function_table ft0 = {fb0}
dcl_function_table ft1 = {fb1}
dcl_function_table ft2 = {fb2}
dcl_function_table ft3 = {fb3}
dcl_interface fp0[1][1] = {ft0, ft1, ft2, ft3}
dcl_input_ps linear v0.xyz
dcl_output o0.xyzw
dcl_temps 4
//
// Initial variable locations:
//   v0.x <- n.x; v0.y <- n.y; v0.z <- n.z; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 17 "C:\dx-fixtures\classes_textures.hlsl"
nop 
mov r0.xy, v0.xyxx
fcall fp0[0][0]
itof o0.w, l(0x00000001)
mov o0.xyz, r1.xyzx
ret 

#line 10 "C:\dx-fixtures\classes_textures.hlsl"
label fb0
nop 
mov r0.z, this[0].z
mov r0.w, this[0].w
sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.z + 0].xyzw, s[r0.w + 0]
mov r0.z, this[0].y
mov r0.w, this[0].x
mul r1.xyz, r2.xyzx, cb[r0.w + 0][r0.z + 0].wwww
ret 

#line 9 "C:\dx-fixtures\classes_textures.hlsl"
label fb1
nop 
mov r0.z, this[0].z
mov r0.w, this[0].w
sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.z + 0].xyzw, s[r0.w + 0]
mov r0.z, this[0].y
mov r0.w, this[0].x
mul r1.xyz, r2.xyzx, cb[r0.w + 0][r0.z + 0].yyyy
ret 

#line 8 "C:\dx-fixtures\classes_textures.hlsl"
label fb2
nop 
mov r0.z, this[0].z
mov r0.w, this[0].w
sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.z + 0].xyzw, s[r0.w + 0]
sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yzyy, t[r0.z + 0].xyzw, s[r0.w + 1]
mov r0.z, this[0].y
mov r0.w, this[0].x
mul r3.xyz, r3.xyzx, cb[r0.w + 0][r0.z + 0].xxxx
add r1.xyz, r2.xyzx, r3.xyzx
ret 

#line 7 "C:\dx-fixtures\classes_textures.hlsl"
label fb3
nop 
ftoi r0.xy, r0.xyxx
mov r0.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
mov r1.w, this[0].z
ld_indexable(texture2d)(float,float,float,float) r0.xyz, r0.xyzw, t[r1.w + 0].xyzw
mov r0.w, this[0].y
mov r1.w, this[0].x
mul r1.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
ret 
