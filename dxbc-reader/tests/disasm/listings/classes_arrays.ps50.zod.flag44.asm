      ps_5_0
      dcl_globalFlags refactoringAllowed | skipOptimization
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
   0: nop 
   1: mov r0.xyz, v0.xyzx
   2: fcall fp0[0][0]
   3: itof o0.w, l(1)
   4: mov o0.xyz, r1.xyzx
   5: ret 

#line 7 "C:\dx-fixtures\classes_arrays.hlsl"
   6: label fb0
   7: nop 
   8: mov r0.w, this[0].z
   9: mov r1.w, this[0].w
  10: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
  11: mov r1.xyz, r1.xyzx
  12: ret 

#line 6 "C:\dx-fixtures\classes_arrays.hlsl"
  13: label fb1
  14: nop 
  15: mov r0.w, this[0].y
  16: mov r1.w, this[0].x
  17: mul r1.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  18: ret 
