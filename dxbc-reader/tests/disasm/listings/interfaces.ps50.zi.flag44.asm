      ps_5_0
      dcl_globalFlags refactoringAllowed
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
#line 17 "C:\dx-fixtures\interfaces.hlsl"
   0: fcall fp0[0][0]
   1: fcall fp0[1][1]
   2: add r0.xyz, r0.xyzx, r1.xyzx  // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z

#line 18
   3: fcall fp2[0][0]
   4: mov o0.xyzw, r0.xyzw
   5: ret 

#line 8 "C:\dx-fixtures\interfaces.hlsl"
   6: label fb0
   7: mov r0.w, this[0].y
   8: mov r1.x, this[0].x
   9: mov r0.xyz, cb[r1.x + 0][r0.w + 0].xyzx
  10: ret 

#line 7 "C:\dx-fixtures\interfaces.hlsl"
  11: label fb1
  12: mov r0.w, this[0].y
  13: mov r1.x, this[0].x
  14: dp3_sat r1.y, v0.xyzx, cb[r1.x + 0][r0.w + 0].xyzx
  15: mul r0.xyz, r1.yyyy, cb[r1.x + 0][r0.w + 1].xyzx
  16: ret 

#line 8 "C:\dx-fixtures\interfaces.hlsl"
  17: label fb2
  18: mov r0.w, this[1].y
  19: mov r1.w, this[1].x
  20: mov r1.xyz, cb[r1.w + 0][r0.w + 0].xyzx
  21: ret 

#line 7 "C:\dx-fixtures\interfaces.hlsl"
  22: label fb3
  23: mov r0.w, this[1].y
  24: mov r1.w, this[1].x
  25: dp3_sat r2.x, v0.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  26: mul r1.xyz, r2.xxxx, cb[r1.w + 0][r0.w + 1].xyzx
  27: ret   // r0.x <- c.x; r0.y <- c.y; r0.z <- c.z

#line 11 "C:\dx-fixtures\interfaces.hlsl"
  28: label fb4
  29: mov r0.w, l(1.000000)
  30: mov r1.xy, this[2].yxyy
  31: mul r0.xyzw, r0.xyzw, cb[r1.y + 0][r1.x + 0].xyzw
  32: ret 

#line 10 "C:\dx-fixtures\interfaces.hlsl"
  33: label fb5
  34: mov r0.w, l(1.000000)
  35: ret 
