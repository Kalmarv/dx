      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[2], immediateIndexed
      0x0000001C: dcl_sampler s0, mode_default
      0x00000028: dcl_sampler s1, mode_default
      0x00000034: dcl_sampler s2, mode_default
      0x00000040: dcl_sampler s3, mode_default
      0x0000004C: dcl_resource_texture2d (float,float,float,float) t0
      0x0000005C: dcl_function_body fb0
      0x00000064: dcl_function_body fb1
      0x0000006C: dcl_function_table ft0 = {fb0}
      0x0000007C: dcl_function_table ft1 = {fb1}
      0x0000008C: dcl_interface fp0[1][1] = {ft0, ft1}
      0x000000A4: dcl_input_ps linear v0.xyz
      0x000000B0: dcl_output o0.xyzw
      0x000000BC: dcl_temps 3
   0  0x000000C4: nop 
   1  0x000000C8: fcall fp0[0][0]
   2  0x000000DC: itof o0.w, l(0x00000001)
   3  0x000000F0: mov o0.xyz, r0.xyzx
   4  0x00000104: ret 
   5  0x00000108: label fb0
   6  0x00000114: nop 
   7  0x00000118: mov r0.w, this[0].w
   8  0x0000012C: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t0.xyzw, s[r0.w + 0]
   9  0x0000015C: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.yzyy, t0.xyzw, s[r0.w + 1]
  10  0x00000190: add r1.xyz, r1.xyzx, r2.xyzx
  11  0x000001AC: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.zxzz, t0.xyzw, s[r0.w + 2]
  12  0x000001E0: mov r0.w, this[0].y
  13  0x000001F4: mov r1.w, this[0].x
  14  0x00000208: mul r2.xyz, r2.xyzx, cb[r1.w + 0][r0.w + 0].xxxx
  15  0x00000230: add r0.xyz, r1.xyzx, r2.xyzx
  16  0x0000024C: ret 
  17  0x00000250: label fb1
  18  0x0000025C: nop 
  19  0x00000260: mov r0.w, this[0].w
  20  0x00000274: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t0.xyzw, s[r0.w + 0]
  21  0x000002A4: mov r0.w, this[0].y
  22  0x000002B8: mov r1.w, this[0].x
  23  0x000002CC: mul r0.xyz, r1.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  24  0x000002F4: ret 
