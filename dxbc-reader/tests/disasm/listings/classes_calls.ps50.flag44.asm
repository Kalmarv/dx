      ps_5_0
      dcl_globalFlags refactoringAllowed
      dcl_constantbuffer CB0[1], immediateIndexed
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
      dcl_function_table ft0 = {fb0, fb2, fb4, fb6}
      dcl_function_table ft1 = {fb1, fb3, fb5, fb7}
      dcl_function_table ft2 = {fb8}
      dcl_function_table ft3 = {fb9}
      dcl_interface_dynamicindexed fp0[3][4] = {ft0, ft1}
      dcl_interface fp3[1][1] = {ft2, ft3}
      dcl_input_ps linear v0.xyz
      dcl_output o0.xyzw
      dcl_temps 2
   0: fcall fp0[0][0]
   1: fcall fp0[1][1]
   2: add r0.xyz, r0.xyzx, r1.xyzx
   3: fcall fp0[2][2]
   4: add r0.xyz, r0.xyzx, r1.xyzx
   5: mov r0.w, cb0[0].x
   6: fcall fp0[r0.w + 0][3]
   7: add r0.xyz, r0.xyzx, r1.xxxx
   8: fcall fp3[0][0]
   9: add o0.xyz, r0.wwww, r0.xyzx
  10: mov o0.w, l(1.000000)
  11: ret 
  12: label fb0
  13: mov r0.xyz, -v0.xyzx
  14: ret 
  15: label fb1
  16: mov r0.w, this[0].y
  17: mov r1.x, this[0].x
  18: add r0.xyz, v0.xyzx, cb[r1.x + 0][r0.w + 0].xxxx
  19: ret 
  20: label fb2
  21: mov r1.xyz, v0.xyzx
  22: ret 
  23: label fb3
  24: mov r0.w, this[1].y
  25: mov r1.w, this[1].x
  26: mul r1.xyz, v0.xyzx, cb[r1.w + 0][r0.w + 0].xxxx
  27: ret 
  28: label fb4
  29: mov r1.xyz, v0.xyzx
  30: ret 
  31: label fb5
  32: mov r0.w, this[2].y
  33: mov r1.w, this[2].x
  34: mul r1.xyz, v0.xyzx, cb[r1.w + 0][r0.w + 0].xxxx
  35: ret 
  36: label fb6
  37: add r1.x, v0.x, v0.x
  38: ret 
  39: label fb7
  40: mov r1.y, this[r0.w + 0].y
  41: mov r0.w, this[r0.w + 0].x
  42: add r1.x, v0.x, -cb[r0.w + 0][r1.y + 0].x
  43: ret 
  44: label fb8
  45: add r0.w, v0.y, v0.y
  46: ret 
  47: label fb9
  48: mov r1.xy, this[3].yxyy
  49: add r0.w, v0.y, -cb[r1.y + 0][r1.x + 0].x
  50: ret 
