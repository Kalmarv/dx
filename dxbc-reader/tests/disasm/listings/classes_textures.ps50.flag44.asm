      ps_5_0
      dcl_globalFlags refactoringAllowed
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
      dcl_temps 3
   0: fcall fp0[0][0]
   1: mov o0.xyz, r0.xyzx
   2: mov o0.w, l(1.000000)
   3: ret 
   4: label fb0
   5: mov r0.w, this[0].z
   6: mov r1.x, this[0].w
   7: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
   8: mov r0.w, this[0].y
   9: mov r1.w, this[0].x
  10: mul r0.xyz, r1.xyzx, cb[r1.w + 0][r0.w + 0].wwww
  11: ret 
  12: label fb1
  13: mov r0.w, this[0].z
  14: mov r1.x, this[0].w
  15: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
  16: mov r0.w, this[0].y
  17: mov r1.w, this[0].x
  18: mul r0.xyz, r1.xyzx, cb[r1.w + 0][r0.w + 0].yyyy
  19: ret 
  20: label fb2
  21: mov r0.w, this[0].z
  22: mov r1.x, this[0].w
  23: sample_indexable(texture2d)(float,float,float,float) r1.yzw, v0.xyxx, t[r0.w + 0].wxyz, s[r1.x + 0]
  24: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.yzyy, t[r0.w + 0].xyzw, s[r1.x + 1]
  25: mov r0.w, this[0].y
  26: mov r1.x, this[0].x
  27: mad r0.xyz, r2.xyzx, cb[r1.x + 0][r0.w + 0].xxxx, r1.yzwy
  28: ret 
  29: label fb3
  30: ftoi r1.xy, v0.xyxx
  31: mov r1.zw, l(0,0,0,0)
  32: mov r0.w, this[0].z
  33: ld_indexable(texture2d)(float,float,float,float) r1.xyz, r1.xyzw, t[r0.w + 0].xyzw
  34: mov r0.w, this[0].y
  35: mov r1.w, this[0].x
  36: mul r0.xyz, r1.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  37: ret 
