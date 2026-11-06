      ps_5_0
      dcl_globalFlags refactoringAllowed
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
   0: fcall fp0[0][0]
   1: mov o0.xyz, r0.xyzx
   2: mov o0.w, l(1.000000)
   3: ret 
   4: label fb0
   5: mov r0.w, this[0].z
   6: mov r1.x, this[0].w
   7: sample_indexable(texture2d)(float,float,float,float) r0.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
   8: ret 
   9: label fb1
  10: mov r0.w, this[0].y
  11: mov r1.x, this[0].x
  12: mul r0.xyz, v0.xyzx, cb[r1.x + 0][r0.w + 0].xyzx
  13: ret 
