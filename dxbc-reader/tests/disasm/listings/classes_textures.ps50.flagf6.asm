      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB0[5], immediateIndexed
      0x0000001C: dcl_sampler s0, mode_default
      0x00000028: dcl_sampler s1, mode_default
      0x00000034: dcl_sampler s2, mode_default
      0x00000040: dcl_sampler s3, mode_default
      0x0000004C: dcl_sampler s4, mode_default
      0x00000058: dcl_resource_texture2d (float,float,float,float) t0
      0x00000068: dcl_resource_texture2d (float,float,float,float) t1
      0x00000078: dcl_resource_texture2d (float,float,float,float) t2
      0x00000088: dcl_resource_texture2d (float,float,float,float) t3
      0x00000098: dcl_resource_texture2d (float,float,float,float) t4
      0x000000A8: dcl_function_body fb0
      0x000000B0: dcl_function_body fb1
      0x000000B8: dcl_function_body fb2
      0x000000C0: dcl_function_body fb3
      0x000000C8: dcl_function_table ft0 = {fb0}
      0x000000D8: dcl_function_table ft1 = {fb1}
      0x000000E8: dcl_function_table ft2 = {fb2}
      0x000000F8: dcl_function_table ft3 = {fb3}
      0x00000108: dcl_interface fp0[1][1] = {ft0, ft1, ft2, ft3}
      0x00000128: dcl_input_ps linear v0.xyz
      0x00000134: dcl_output o0.xyzw
      0x00000140: dcl_temps 3
   0  0x00000148: fcall fp0[0][0]
   1  0x0000015C: mov o0.xyz, r0.xyzx
   2  0x00000170: mov o0.w, l(0x3f800000)
   3  0x00000184: ret 
   4  0x00000188: label fb0
   5  0x00000194: mov r0.w, this[0].z
   6  0x000001A8: mov r1.x, this[0].w
   7  0x000001BC: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
   8  0x000001F0: mov r0.w, this[0].y
   9  0x00000204: mov r1.w, this[0].x
  10  0x00000218: mul r0.xyz, r1.xyzx, cb[r1.w + 0][r0.w + 0].wwww
  11  0x00000240: ret 
  12  0x00000244: label fb1
  13  0x00000250: mov r0.w, this[0].z
  14  0x00000264: mov r1.x, this[0].w
  15  0x00000278: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
  16  0x000002AC: mov r0.w, this[0].y
  17  0x000002C0: mov r1.w, this[0].x
  18  0x000002D4: mul r0.xyz, r1.xyzx, cb[r1.w + 0][r0.w + 0].yyyy
  19  0x000002FC: ret 
  20  0x00000300: label fb2
  21  0x0000030C: mov r0.w, this[0].z
  22  0x00000320: mov r1.x, this[0].w
  23  0x00000334: sample_indexable(texture2d)(float,float,float,float) r1.yzw, v0.xyxx, t[r0.w + 0].wxyz, s[r1.x + 0]
  24  0x00000368: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.yzyy, t[r0.w + 0].xyzw, s[r1.x + 1]
  25  0x000003A0: mov r0.w, this[0].y
  26  0x000003B4: mov r1.x, this[0].x
  27  0x000003C8: mad r0.xyz, r2.xyzx, cb[r1.x + 0][r0.w + 0].xxxx, r1.yzwy
  28  0x000003F8: ret 
  29  0x000003FC: label fb3
  30  0x00000408: ftoi r1.xy, v0.xyxx
  31  0x0000041C: mov r1.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
  32  0x0000043C: mov r0.w, this[0].z
  33  0x00000450: ld_indexable(texture2d)(float,float,float,float) r1.xyz, r1.xyzw, t[r0.w + 0].xyzw
  34  0x00000478: mov r0.w, this[0].y
  35  0x0000048C: mov r1.w, this[0].x
  36  0x000004A0: mul r0.xyz, r1.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  37  0x000004C8: ret 
