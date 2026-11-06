      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
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
      0x00000140: dcl_temps 4
   0  0x00000148: nop 
   1  0x0000014C: mov r0.xy, v0.xyxx
   2  0x00000160: fcall fp0[0][0]
   3  0x00000174: itof o0.w, l(0x00000001)
   4  0x00000188: mov o0.xyz, r1.xyzx
   5  0x0000019C: ret 
   6  0x000001A0: label fb0
   7  0x000001AC: nop 
   8  0x000001B0: mov r0.z, this[0].z
   9  0x000001C4: mov r0.w, this[0].w
  10  0x000001D8: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.z + 0].xyzw, s[r0.w + 0]
  11  0x0000020C: mov r0.z, this[0].y
  12  0x00000220: mov r0.w, this[0].x
  13  0x00000234: mul r1.xyz, r2.xyzx, cb[r0.w + 0][r0.z + 0].wwww
  14  0x0000025C: ret 
  15  0x00000260: label fb1
  16  0x0000026C: nop 
  17  0x00000270: mov r0.z, this[0].z
  18  0x00000284: mov r0.w, this[0].w
  19  0x00000298: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.z + 0].xyzw, s[r0.w + 0]
  20  0x000002CC: mov r0.z, this[0].y
  21  0x000002E0: mov r0.w, this[0].x
  22  0x000002F4: mul r1.xyz, r2.xyzx, cb[r0.w + 0][r0.z + 0].yyyy
  23  0x0000031C: ret 
  24  0x00000320: label fb2
  25  0x0000032C: nop 
  26  0x00000330: mov r0.z, this[0].z
  27  0x00000344: mov r0.w, this[0].w
  28  0x00000358: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.z + 0].xyzw, s[r0.w + 0]
  29  0x0000038C: sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yzyy, t[r0.z + 0].xyzw, s[r0.w + 1]
  30  0x000003C4: mov r0.z, this[0].y
  31  0x000003D8: mov r0.w, this[0].x
  32  0x000003EC: mul r3.xyz, r3.xyzx, cb[r0.w + 0][r0.z + 0].xxxx
  33  0x00000414: add r1.xyz, r2.xyzx, r3.xyzx
  34  0x00000430: ret 
  35  0x00000434: label fb3
  36  0x00000440: nop 
  37  0x00000444: ftoi r0.xy, r0.xyxx
  38  0x00000458: mov r0.zw, l(0x00000000,0x00000000,0x00000000,0x00000000)
  39  0x00000478: mov r1.w, this[0].z
  40  0x0000048C: ld_indexable(texture2d)(float,float,float,float) r0.xyz, r0.xyzw, t[r1.w + 0].xyzw
  41  0x000004B4: mov r0.w, this[0].y
  42  0x000004C8: mov r1.w, this[0].x
  43  0x000004DC: mul r1.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  44  0x00000504: ret 
