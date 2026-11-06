      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_constantbuffer CB0[2], immediateIndexed
      0x0000001C: dcl_sampler s0, mode_default
      0x00000028: dcl_sampler s1, mode_default
      0x00000034: dcl_sampler s2, mode_default
      0x00000040: dcl_resource_texture2d (float,float,float,float) t0
      0x00000050: dcl_resource_texture2d (float,float,float,float) t1
      0x00000060: dcl_resource_texture2d (float,float,float,float) t2
      0x00000070: dcl_function_body fb0
      0x00000078: dcl_function_body fb1
      0x00000080: dcl_function_body fb2
      0x00000088: dcl_function_body fb3
      0x00000090: dcl_function_body fb4
      0x00000098: dcl_function_body fb5
      0x000000A0: dcl_function_body fb6
      0x000000A8: dcl_function_body fb7
      0x000000B0: dcl_function_body fb8
      0x000000B8: dcl_function_body fb9
      0x000000C0: dcl_function_body fb10
      0x000000C8: dcl_function_table ft0 = {fb0}
      0x000000D8: dcl_function_table ft1 = {fb1}
      0x000000E8: dcl_function_table ft2 = {fb2}
      0x000000F8: dcl_function_table ft3 = {fb3, fb6}
      0x0000010C: dcl_function_table ft4 = {fb4, fb7}
      0x00000120: dcl_function_table ft5 = {fb5, fb8}
      0x00000134: dcl_function_table ft6 = {fb9}
      0x00000144: dcl_function_table ft7 = {fb10}
      0x00000154: dcl_interface fp0[1][1] = {ft0, ft1, ft2}
      0x00000170: dcl_interface fp1[3][2] = {ft3, ft4, ft5}
      0x0000018C: dcl_interface fp4[1][1] = {ft6, ft7}
      0x000001A4: dcl_input_ps linear v0.xyz
      0x000001B0: dcl_output o0.xyzw
      0x000001BC: dcl_temps 4
   0  0x000001C4: fcall fp0[0][0]
   1  0x000001D8: fcall fp1[0][0]
   2  0x000001EC: add r0.xyz, r0.xyzx, r1.xyzx
   3  0x00000208: fcall fp1[2][1]
   4  0x0000021C: add r0.xyz, r0.xyzx, r1.xyzx
   5  0x00000238: fcall fp4[0][0]
   6  0x0000024C: mov o0.xyzw, r1.xyzw
   7  0x00000260: ret 
   8  0x00000264: label fb0
   9  0x00000270: mov r0.xyz, v0.xyzx
  10  0x00000284: ret 
  11  0x00000288: label fb1
  12  0x00000294: mov r0.w, this[0].z
  13  0x000002A8: mov r1.x, this[0].w
  14  0x000002BC: sample_indexable(texture2d)(float,float,float,float) r1.yzw, v0.xyxx, t[r0.w + 0].wxyz, s[r1.x + 0]
  15  0x000002F0: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.yzyy, t[r0.w + 1].xyzw, s[r1.x + 1]
  16  0x0000032C: mov r0.w, this[0].y
  17  0x00000340: mov r1.x, this[0].x
  18  0x00000354: mad r0.xyz, r2.xyzx, cb[r1.x + 0][r0.w + 0].xyzx, r1.yzwy
  19  0x00000384: ret 
  20  0x00000388: label fb2
  21  0x00000394: mov r0.w, this[0].z
  22  0x000003A8: mov r1.x, this[0].w
  23  0x000003BC: sample_indexable(texture2d)(float,float,float,float) r0.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
  24  0x000003F0: ret 
  25  0x000003F4: label fb3
  26  0x00000400: mov r1.xyz, v0.xyzx
  27  0x00000414: ret 
  28  0x00000418: label fb4
  29  0x00000424: mov r0.w, this[1].z
  30  0x00000438: mov r1.w, this[1].w
  31  0x0000044C: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
  32  0x00000480: sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yzyy, t[r0.w + 1].xyzw, s[r1.w + 1]
  33  0x000004BC: mov r0.w, this[1].y
  34  0x000004D0: mov r1.w, this[1].x
  35  0x000004E4: mad r1.xyz, r3.xyzx, cb[r1.w + 0][r0.w + 0].xyzx, r2.xyzx
  36  0x00000514: ret 
  37  0x00000518: label fb5
  38  0x00000524: mov r0.w, this[1].z
  39  0x00000538: mov r1.w, this[1].w
  40  0x0000054C: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
  41  0x00000580: ret 
  42  0x00000584: label fb6
  43  0x00000590: mov r1.xyz, v0.zyxz
  44  0x000005A4: ret 
  45  0x000005A8: label fb7
  46  0x000005B4: mov r0.w, this[3].z
  47  0x000005C8: mov r1.w, this[3].w
  48  0x000005DC: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.zyzz, t[r0.w + 0].xyzw, s[r1.w + 0]
  49  0x00000610: sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yxyy, t[r0.w + 1].xyzw, s[r1.w + 1]
  50  0x0000064C: mov r0.w, this[3].y
  51  0x00000660: mov r1.w, this[3].x
  52  0x00000674: mad r1.xyz, r3.xyzx, cb[r1.w + 0][r0.w + 0].xyzx, r2.xyzx
  53  0x000006A4: ret 
  54  0x000006A8: label fb8
  55  0x000006B4: mov r0.w, this[3].z
  56  0x000006C8: mov r1.w, this[3].w
  57  0x000006DC: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.zyzz, t[r0.w + 0].xyzw, s[r1.w + 0]
  58  0x00000710: ret 
  59  0x00000714: label fb9
  60  0x00000720: mov r1.x, l(0x3f800000)
  61  0x00000734: mov r1.yzw, r0.zzyx
  62  0x00000748: ret 
  63  0x0000074C: label fb10
  64  0x00000758: mov r0.w, l(0x3f800000)
  65  0x0000076C: mov r2.xy, this[4].yxyy
  66  0x00000780: mul r1.xyzw, r0.xyzw, cb[r2.y + 0][r2.x + 0].xyzw
  67  0x000007A8: ret 
