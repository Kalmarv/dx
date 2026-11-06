ps_5_0
dcl_globalFlags refactoringAllowed
dcl_constantbuffer CB0[3], immediateIndexed
dcl_sampler s0, mode_default
dcl_sampler s1, mode_default
dcl_resource_texture2d (float,float,float,float) t0
dcl_resource_texture2d (float,float,float,float) t1
dcl_function_body fb0
dcl_function_body fb1
dcl_function_table ft0 = {fb0}
dcl_function_table ft1 = {fb1}
dcl_interface fp0[1][1] = {ft0, ft1}
dcl_input_ps linear v0.xyz
dcl_output o0.xyzw
dcl_temps 2
//
// Initial variable locations:
//   v0.x <- n.x; v0.y <- n.y; v0.z <- n.z; 
//   v1.x <- p.x; v1.y <- p.y; v1.z <- p.z; v1.w <- p.w; 
//   v2.x <- i; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 11 "C:\dx-fixtures\classes_arrays.hlsl"
fcall fp0[0][0]
mov o0.xyz, r0.xyzx
mov o0.w, l(0x3f800000)
ret 

#line 7 "C:\dx-fixtures\classes_arrays.hlsl"
label fb0
mov r0.w, this[0].z
mov r1.x, this[0].w
sample_indexable(texture2d)(float,float,float,float) r0.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
ret 

#line 6 "C:\dx-fixtures\classes_arrays.hlsl"
label fb1
mov r0.w, this[0].y
mov r1.x, this[0].x
mul r0.xyz, v0.xyzx, cb[r1.x + 0][r0.w + 0].xyzx
ret 
