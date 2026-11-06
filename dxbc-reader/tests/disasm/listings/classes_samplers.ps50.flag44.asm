      ps_5_0
      dcl_globalFlags refactoringAllowed
      dcl_constantbuffer CB0[2], immediateIndexed
      dcl_sampler s0, mode_default
      dcl_sampler s1, mode_default
      dcl_sampler s2, mode_default
      dcl_sampler s3, mode_default
      dcl_resource_texture2d (float,float,float,float) t0
      dcl_function_body fb0
      dcl_function_body fb1
      dcl_function_table ft0 = {fb0}
      dcl_function_table ft1 = {fb1}
      dcl_interface fp0[1][1] = {ft0, ft1}
      dcl_input_ps linear v0.xyz
      dcl_output o0.xyzw
      dcl_temps 3
   0: fcall fp0[0][0]
   1: mov o0.xyz, r0.xyzx
   2: mov o0.w, l(1.000000)
   3: ret 
   4: label fb0
   5: mov r0.w, this[0].w
   6: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t0.xyzw, s[r0.w + 0]
   7: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.yzyy, t0.xyzw, s[r0.w + 1]
   8: add r1.xyz, r1.xyzx, r2.xyzx
   9: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.zxzz, t0.xyzw, s[r0.w + 2]
  10: mov r0.w, this[0].y
  11: mov r1.w, this[0].x
  12: mad r0.xyz, r2.xyzx, cb[r1.w + 0][r0.w + 0].xxxx, r1.xyzx
  13: ret 
  14: label fb1
  15: mov r0.w, this[0].w
  16: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t0.xyzw, s[r0.w + 0]
  17: mov r0.w, this[0].y
  18: mov r1.w, this[0].x
  19: mul r0.xyz, r1.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  20: ret 
