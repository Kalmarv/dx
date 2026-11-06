      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[3], immediateIndexed
      0x0000001C: dcl_sampler s0, mode_default
      0x00000028: dcl_sampler s1, mode_default
      0x00000034: dcl_resource_texture2d (float,float,float,float) t0
      0x00000044: dcl_resource_texture2d (float,float,float,float) t1
      0x00000054: dcl_function_body fb0
      0x0000005C: dcl_function_body fb1
      0x00000064: dcl_function_table ft0 = {fb0}
      0x00000074: dcl_function_table ft1 = {fb1}
      0x00000084: dcl_interface fp0[1][1] = {ft0, ft1}
      0x0000009C: dcl_input_ps linear v0.xyz
      0x000000A8: dcl_output o0.xyzw
      0x000000B4: dcl_temps 2
   0  0x000000BC: nop 
   1  0x000000C0: mov r0.xyz, v0.xyzx
   2  0x000000D4: fcall fp0[0][0]
   3  0x000000E8: itof o0.w, l(0x00000001)
   4  0x000000FC: mov o0.xyz, r1.xyzx
   5  0x00000110: ret 
   6  0x00000114: label fb0
   7  0x00000120: nop 
   8  0x00000124: mov r0.w, this[0].z
   9  0x00000138: mov r1.w, this[0].w
  10  0x0000014C: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
  11  0x00000180: mov r1.xyz, r1.xyzx
  12  0x00000194: ret 
  13  0x00000198: label fb1
  14  0x000001A4: nop 
  15  0x000001A8: mov r0.w, this[0].y
  16  0x000001BC: mov r1.w, this[0].x
  17  0x000001D0: mul r1.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  18  0x000001F8: ret 
