      ps_5_0
      dcl_globalFlags refactoringAllowed | skipOptimization
      dcl_constantbuffer CB0[4], immediateIndexed
      dcl_function_body fb0
      dcl_function_body fb1
      dcl_function_body fb2
      dcl_function_body fb3
      dcl_function_body fb4
      dcl_function_body fb5
      dcl_function_table ft0 = {fb0, fb2}
      dcl_function_table ft1 = {fb1, fb3}
      dcl_function_table ft2 = {fb4}
      dcl_function_table ft3 = {fb5}
      dcl_interface fp0[2][2] = {ft0, ft1}
      dcl_interface fp2[1][1] = {ft2, ft3}
      dcl_input_ps linear v0.xyz
      dcl_output o0.xyzw
      dcl_temps 3
//
// Initial variable locations:
//   v0.x <- n.x; v0.y <- n.y; v0.z <- n.z; 
//   o0.x <- <main return value>.x; o0.y <- <main return value>.y; o0.z <- <main return value>.z; o0.w <- <main return value>.w
//
#line 16 "C:\dx-fixtures\interfaces.hlsl"
   0: itof r0.xyz, l(0, 0, 0, 0)  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z

#line 17
   1: nop 
   2: mov r1.xyz, v0.xyzx
   3: fcall fp0[0][0]
   4: add r0.xyz, r0.xyzx, r2.xyzx
   5: nop 
   6: mov r1.xyz, v0.xyzx
   7: fcall fp0[1][1]
   8: add r0.xyz, r0.xyzx, r2.xyzx

#line 18
   9: nop 
  10: mov r0.xyz, r0.xyzx
  11: fcall fp2[0][0]
  12: mov o0.xyzw, r0.xyzw
  13: ret   // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z

#line 8 "C:\dx-fixtures\interfaces.hlsl"
  14: label fb0
  15: nop 
  16: mov r0.w, this[0].y
  17: mov r1.w, this[0].x
  18: mov r2.xyz, cb[r1.w + 0][r0.w + 0].xyzx
  19: ret 

#line 7 "C:\dx-fixtures\interfaces.hlsl"
  20: label fb1
  21: nop 
  22: mov r0.w, this[0].y
  23: mov r1.w, this[0].x
  24: dp3 r1.x, r1.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  25: max r1.x, r1.x, l(0.000000)
  26: min r1.x, r1.x, l(1.000000)
  27: mul r2.xyz, r1.xxxx, cb[r1.w + 0][r0.w + 1].xyzx
  28: ret 

#line 8 "C:\dx-fixtures\interfaces.hlsl"
  29: label fb2
  30: nop 
  31: mov r0.w, this[1].y
  32: mov r1.w, this[1].x
  33: mov r2.xyz, cb[r1.w + 0][r0.w + 0].xyzx
  34: ret 

#line 7 "C:\dx-fixtures\interfaces.hlsl"
  35: label fb3
  36: nop 
  37: mov r0.w, this[1].y
  38: mov r1.w, this[1].x
  39: dp3 r1.x, r1.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  40: max r1.x, r1.x, l(0.000000)
  41: min r1.x, r1.x, l(1.000000)
  42: mul r2.xyz, r1.xxxx, cb[r1.w + 0][r0.w + 1].xyzx
  43: ret 

#line 11 "C:\dx-fixtures\interfaces.hlsl"
  44: label fb4
  45: nop 
  46: itof r0.w, l(1)
  47: mov r1.x, this[2].y
  48: mov r1.y, this[2].x
  49: mul r0.xyzw, r0.xyzw, cb[r1.y + 0][r1.x + 0].xyzw
  50: ret 

#line 10 "C:\dx-fixtures\interfaces.hlsl"
  51: label fb5  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z
  52: nop 
  53: itof r0.w, l(1)
  54: mov r0.xyz, r0.xyzx
  55: ret 
