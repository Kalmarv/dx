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
   0: nop 
   1: mov r0.xy, v0.xyxx
   2: fcall fp0[0][0]
   3: itof o0.w, l(1)
   4: mov o0.xyz, r1.xyzx
   5: ret 

#line 10 "C:\dx-fixtures\classes_textures.hlsl"
   6: label fb0
   7: nop 
   8: mov r0.z, this[0].z
   9: mov r0.w, this[0].w
  10: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.z + 0].xyzw, s[r0.w + 0]
  11: mov r0.z, this[0].y
  12: mov r0.w, this[0].x
  13: mul r1.xyz, r2.xyzx, cb[r0.w + 0][r0.z + 0].wwww
  14: ret 

#line 9 "C:\dx-fixtures\classes_textures.hlsl"
  15: label fb1
  16: nop 
  17: mov r0.z, this[0].z
  18: mov r0.w, this[0].w
  19: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.z + 0].xyzw, s[r0.w + 0]
  20: mov r0.z, this[0].y
  21: mov r0.w, this[0].x
  22: mul r1.xyz, r2.xyzx, cb[r0.w + 0][r0.z + 0].yyyy
  23: ret 

#line 8 "C:\dx-fixtures\classes_textures.hlsl"
  24: label fb2
  25: nop 
  26: mov r0.z, this[0].z
  27: mov r0.w, this[0].w
  28: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.z + 0].xyzw, s[r0.w + 0]
  29: sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yzyy, t[r0.z + 0].xyzw, s[r0.w + 1]
  30: mov r0.z, this[0].y
  31: mov r0.w, this[0].x
  32: mul r3.xyz, r3.xyzx, cb[r0.w + 0][r0.z + 0].xxxx
  33: add r1.xyz, r2.xyzx, r3.xyzx
  34: ret 

#line 7 "C:\dx-fixtures\classes_textures.hlsl"
  35: label fb3
  36: nop 
  37: ftoi r0.xy, r0.xyxx
  38: mov r0.zw, l(0,0,0,0)
  39: mov r1.w, this[0].z
  40: ld_indexable(texture2d)(float,float,float,float) r0.xyz, r0.xyzw, t[r1.w + 0].xyzw
  41: mov r0.w, this[0].y
  42: mov r1.w, this[0].x
  43: mul r1.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  44: ret 
