      ps_5_0
      dcl_globalFlags refactoringAllowed | skipOptimization
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
   0: nop 
   1: mov r0.xyz, v0.xyzx
   2: fcall fp0[0][0]
   3: nop 
   4: mov r1.xyz, v0.xyzx
   5: fcall fp1[0][0]
   6: add r0.xyz, r0.xyzx, r1.xyzx
   7: nop 
   8: mov r1.xyz, v0.zyxz
   9: fcall fp1[2][1]
  10: add r0.yzw, r0.zzyx, r1.zzyx  // r0.y <- c.z; r0.z <- c.y; r0.w <- c.x

#line 26
  11: nop 
  12: itof r0.x, l(1)
  13: mov r0.yzw, r0.yyzw
  14: fcall fp4[0][0]
  15: mov o0.xyzw, r0.xyzw
  16: ret 

#line 13 "C:\dx-fixtures\classes_resources.hlsl"
  17: label fb0
  18: nop 
  19: mov r0.xyz, r0.xyzx
  20: ret 

#line 12 "C:\dx-fixtures\classes_resources.hlsl"
  21: label fb1
  22: nop 
  23: mov r0.w, this[0].z
  24: mov r1.x, this[0].w
  25: sample_indexable(texture2d)(float,float,float,float) r1.yzw, v0.xyxx, t[r0.w + 0].wxyz, s[r1.x + 0]
  26: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.yzyy, t[r0.w + 1].xyzw, s[r1.x + 1]
  27: mov r0.w, this[0].y
  28: mov r1.x, this[0].x
  29: mul r2.xyz, r2.xyzx, cb[r1.x + 0][r0.w + 0].xyzx
  30: add r0.xyz, r1.yzwy, r2.xyzx
  31: ret 

#line 11 "C:\dx-fixtures\classes_resources.hlsl"
  32: label fb2
  33: nop 
  34: mov r0.w, this[0].z
  35: mov r1.x, this[0].w
  36: sample_indexable(texture2d)(float,float,float,float) r0.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
  37: mov r0.xyz, r0.xyzx
  38: ret 

#line 13 "C:\dx-fixtures\classes_resources.hlsl"
  39: label fb3
  40: nop 
  41: mov r1.xyz, r1.xyzx
  42: ret 

#line 12 "C:\dx-fixtures\classes_resources.hlsl"
  43: label fb4
  44: nop 
  45: mov r0.w, this[1].z
  46: mov r1.w, this[1].w
  47: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
  48: sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yzyy, t[r0.w + 1].xyzw, s[r1.w + 1]
  49: mov r0.w, this[1].y
  50: mov r1.w, this[1].x
  51: mul r3.xyz, r3.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  52: add r1.xyz, r2.xyzx, r3.xyzx
  53: ret 

#line 11 "C:\dx-fixtures\classes_resources.hlsl"
  54: label fb5
  55: nop 
  56: mov r0.w, this[1].z
  57: mov r1.w, this[1].w
  58: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
  59: mov r1.xyz, r1.xyzx
  60: ret 

#line 13 "C:\dx-fixtures\classes_resources.hlsl"
  61: label fb6
  62: nop 
  63: mov r1.xyz, r1.xyzx
  64: ret 

#line 12 "C:\dx-fixtures\classes_resources.hlsl"
  65: label fb7
  66: nop 
  67: mov r0.w, this[3].z
  68: mov r1.w, this[3].w
  69: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.zyzz, t[r0.w + 0].xyzw, s[r1.w + 0]
  70: sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yxyy, t[r0.w + 1].xyzw, s[r1.w + 1]
  71: mov r0.w, this[3].y
  72: mov r1.w, this[3].x
  73: mul r3.xyz, r3.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  74: add r1.xyz, r2.xyzx, r3.xyzx
  75: ret 

#line 11 "C:\dx-fixtures\classes_resources.hlsl"
  76: label fb8
  77: nop 
  78: mov r0.w, this[3].z
  79: mov r1.w, this[3].w
  80: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.zyzz, t[r0.w + 0].xyzw, s[r1.w + 0]
  81: mov r1.xyz, r1.xyzx
  82: ret   // r0.y <- c.z; r0.z <- c.y; r0.w <- c.x

#line 15 "C:\dx-fixtures\classes_resources.hlsl"
  83: label fb9
  84: nop 
  85: mov r0.xyzw, r0.xyzw
  86: ret 

#line 14 "C:\dx-fixtures\classes_resources.hlsl"
  87: label fb10  // r0.y <- c.z; r0.z <- c.y; r0.w <- c.x
  88: nop 
  89: mov r1.x, this[4].y
  90: mov r1.y, this[4].x
  91: mul r0.xyzw, r0.wzyx, cb[r1.y + 0][r1.x + 0].xyzw
  92: ret 
