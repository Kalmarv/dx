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
   0: fcall fp0[0][0]
   1: fcall fp1[0][0]
   2: add r0.xyz, r0.xyzx, r1.xyzx
   3: fcall fp1[2][1]
   4: add r0.xyz, r0.xyzx, r1.xyzx  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z

#line 26
   5: fcall fp4[0][0]
   6: mov o0.xyzw, r1.xyzw
   7: ret 

#line 13 "C:\dx-fixtures\classes_resources.hlsl"
   8: label fb0
   9: mov r0.xyz, v0.xyzx
  10: ret 

#line 12 "C:\dx-fixtures\classes_resources.hlsl"
  11: label fb1
  12: mov r0.w, this[0].z
  13: mov r1.x, this[0].w
  14: sample_indexable(texture2d)(float,float,float,float) r1.yzw, v0.xyxx, t[r0.w + 0].wxyz, s[r1.x + 0]
  15: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.yzyy, t[r0.w + 1].xyzw, s[r1.x + 1]
  16: mov r0.w, this[0].y
  17: mov r1.x, this[0].x
  18: mad r0.xyz, r2.xyzx, cb[r1.x + 0][r0.w + 0].xyzx, r1.yzwy
  19: ret 

#line 11 "C:\dx-fixtures\classes_resources.hlsl"
  20: label fb2
  21: mov r0.w, this[0].z
  22: mov r1.x, this[0].w
  23: sample_indexable(texture2d)(float,float,float,float) r0.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
  24: ret 

#line 13 "C:\dx-fixtures\classes_resources.hlsl"
  25: label fb3
  26: mov r1.xyz, v0.xyzx
  27: ret 

#line 12 "C:\dx-fixtures\classes_resources.hlsl"
  28: label fb4
  29: mov r0.w, this[1].z
  30: mov r1.w, this[1].w
  31: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
  32: sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yzyy, t[r0.w + 1].xyzw, s[r1.w + 1]
  33: mov r0.w, this[1].y
  34: mov r1.w, this[1].x
  35: mad r1.xyz, r3.xyzx, cb[r1.w + 0][r0.w + 0].xyzx, r2.xyzx
  36: ret 

#line 11 "C:\dx-fixtures\classes_resources.hlsl"
  37: label fb5
  38: mov r0.w, this[1].z
  39: mov r1.w, this[1].w
  40: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
  41: ret 

#line 13 "C:\dx-fixtures\classes_resources.hlsl"
  42: label fb6
  43: mov r1.xyz, v0.zyxz
  44: ret 

#line 12 "C:\dx-fixtures\classes_resources.hlsl"
  45: label fb7
  46: mov r0.w, this[3].z
  47: mov r1.w, this[3].w
  48: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.zyzz, t[r0.w + 0].xyzw, s[r1.w + 0]
  49: sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yxyy, t[r0.w + 1].xyzw, s[r1.w + 1]
  50: mov r0.w, this[3].y
  51: mov r1.w, this[3].x
  52: mad r1.xyz, r3.xyzx, cb[r1.w + 0][r0.w + 0].xyzx, r2.xyzx
  53: ret 

#line 11 "C:\dx-fixtures\classes_resources.hlsl"
  54: label fb8
  55: mov r0.w, this[3].z
  56: mov r1.w, this[3].w
  57: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.zyzz, t[r0.w + 0].xyzw, s[r1.w + 0]
  58: ret   // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z

#line 15 "C:\dx-fixtures\classes_resources.hlsl"
  59: label fb9
  60: mov r1.x, l(1.000000)
  61: mov r1.yzw, r0.zzyx
  62: ret 

#line 14 "C:\dx-fixtures\classes_resources.hlsl"
  63: label fb10
  64: mov r0.w, l(1.000000)
  65: mov r2.xy, this[4].yxyy
  66: mul r1.xyzw, r0.xyzw, cb[r2.y + 0][r2.x + 0].xyzw
  67: ret 
