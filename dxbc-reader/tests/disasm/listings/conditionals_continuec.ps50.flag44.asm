      ps_5_0
      dcl_globalFlags refactoringAllowed
      dcl_constantbuffer CB0[1], immediateIndexed
      dcl_constantbuffer CB1[7], immediateIndexed
      dcl_sampler s0, mode_default
      dcl_resource_texture2d (float,float,float,float) t2
      dcl_function_body fb0
      dcl_function_body fb1
      dcl_function_body fb2
      dcl_function_body fb3
      dcl_function_body fb4
      dcl_function_body fb5
      dcl_function_body fb6
      dcl_function_body fb7
      dcl_function_table ft0 = {fb0, fb2}
      dcl_function_table ft1 = {fb1, fb3}
      dcl_function_table ft2 = {fb4, fb6}
      dcl_function_table ft3 = {fb5, fb7}
      dcl_interface_dynamicindexed fp0[6][2] = {ft0, ft1}
      dcl_interface_dynamicindexed fp6[2][2] = {ft2, ft3}
      dcl_input_ps linear v0.xyz
      dcl_input_ps linear v1.xyz
      dcl_input_ps linear v2.xy
      dcl_output o0.xyzw
      dcl_temps 5
   0: and r0.x, cb0[0].y, l(1)
   1: mov r1.xyz, l(0,0,0,0)
   2: mov r0.y, l(0)
   3: loop 
   4:   ige r0.z, r0.y, cb0[0].x
   5:   continuec_nz l(0x40000000)
   6:   bfi r0.z, l(31), l(1), r0.y, cb0[0].y
   7:   fcall fp0[r0.z + 0][0]
   8:   bfi r0.z, l(31), l(1), r0.y, l(1)
   9:   fcall fp0[r0.z + 0][1]
  10:   mad r1.xyz, r2.xyzx, r0.wwww, r1.xyzx
  11:   iadd r0.y, r0.y, l(1)
  12: endloop 
  13: fcall fp6[r0.x + 0][0]
  14: mov r1.w, l(1.000000)
  15: fcall fp6[0][1]
  16: mad o0.xyzw, r1.xyzw, r2.xyzw, r0.xyzw
  17: ret 
  18: label fb0
  19: mov r0.w, this[r0.z + 0].y
  20: mov r2.w, this[r0.z + 0].x
  21: add r3.xyz, -v1.xyzx, cb[r2.w + 0][r0.w + 0].xyzx
  22: dp3 r3.w, r3.xyzx, r3.xyzx
  23: rsq r4.x, r3.w
  24: mul r3.xyz, r3.xyzx, r4.xxxx
  25: dp3_sat r3.x, v0.xyzx, r3.xyzx
  26: mul r3.xyz, r3.xxxx, cb[r2.w + 0][r0.w + 1].xyzx
  27: sqrt r3.w, r3.w
  28: div r0.w, r3.w, cb[r2.w + 0][r0.w + 1].w
  29: add_sat r0.w, -r0.w, l(1.000000)
  30: mul r2.xyz, r0.wwww, r3.xyzx
  31: ret 
  32: label fb1
  33: mov r0.w, this[r0.z + 0].y
  34: mov r0.z, this[r0.z + 0].x
  35: dp3_sat r2.w, v0.xyzx, cb[r0.z + 0][r0.w + 0].xyzx
  36: mul r2.xyz, r2.wwww, cb[r0.z + 0][r0.w + 1].xyzx
  37: ret 
  38: label fb2
  39: itof r2.w, r0.y
  40: mov r3.x, this[r0.z + 0].y
  41: mov r0.z, this[r0.z + 0].x
  42: div r0.z, r2.w, cb[r0.z + 0][r3.x + 1].w
  43: add_sat r0.w, -r0.z, l(1.000000)
  44: ret 
  45: label fb3
  46: mov r0.w, l(1.000000)
  47: ret 
  48: label fb4
  49: mov r0.y, this[r0.x + 6].z
  50: sample_indexable(texture2d)(float,float,float,float) r2.xyzw, v2.xyxx, t[r0.y + 0].xyzw, s0
  51: ret 
  52: label fb5
  53: mov r0.y, this[r0.x + 6].y
  54: mov r0.x, this[r0.x + 6].x
  55: mov r2.xyzw, cb[r0.x + 0][r0.y + 0].xyzw
  56: ret 
  57: label fb6
  58: add r3.xy, v2.xyxx, v2.xyxx
  59: mov r3.z, this[6].z
  60: sample_indexable(texture2d)(float,float,float,float) r0.xyzw, r3.xyxx, t[r3.z + 0].xyzw, s0
  61: ret 
  62: label fb7
  63: mov r3.xy, this[6].yxyy
  64: mov r0.xyzw, cb[r3.y + 0][r3.x + 0].xyzw
  65: ret 
