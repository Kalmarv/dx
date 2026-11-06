      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
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
   0  0x000001C4: nop 
   1  0x000001C8: mov r0.xyz, v0.xyzx
   2  0x000001DC: fcall fp0[0][0]
   3  0x000001F0: nop 
   4  0x000001F4: mov r1.xyz, v0.xyzx
   5  0x00000208: fcall fp1[0][0]
   6  0x0000021C: add r0.xyz, r0.xyzx, r1.xyzx
   7  0x00000238: nop 
   8  0x0000023C: mov r1.xyz, v0.zyxz
   9  0x00000250: fcall fp1[2][1]
  10  0x00000264: add r0.yzw, r0.zzyx, r1.zzyx
  11  0x00000280: nop 
  12  0x00000284: itof r0.x, l(0x00000001)
  13  0x00000298: mov r0.yzw, r0.yyzw
  14  0x000002AC: fcall fp4[0][0]
  15  0x000002C0: mov o0.xyzw, r0.xyzw
  16  0x000002D4: ret 
  17  0x000002D8: label fb0
  18  0x000002E4: nop 
  19  0x000002E8: mov r0.xyz, r0.xyzx
  20  0x000002FC: ret 
  21  0x00000300: label fb1
  22  0x0000030C: nop 
  23  0x00000310: mov r0.w, this[0].z
  24  0x00000324: mov r1.x, this[0].w
  25  0x00000338: sample_indexable(texture2d)(float,float,float,float) r1.yzw, v0.xyxx, t[r0.w + 0].wxyz, s[r1.x + 0]
  26  0x0000036C: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.yzyy, t[r0.w + 1].xyzw, s[r1.x + 1]
  27  0x000003A8: mov r0.w, this[0].y
  28  0x000003BC: mov r1.x, this[0].x
  29  0x000003D0: mul r2.xyz, r2.xyzx, cb[r1.x + 0][r0.w + 0].xyzx
  30  0x000003F8: add r0.xyz, r1.yzwy, r2.xyzx
  31  0x00000414: ret 
  32  0x00000418: label fb2
  33  0x00000424: nop 
  34  0x00000428: mov r0.w, this[0].z
  35  0x0000043C: mov r1.x, this[0].w
  36  0x00000450: sample_indexable(texture2d)(float,float,float,float) r0.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.x + 0]
  37  0x00000484: mov r0.xyz, r0.xyzx
  38  0x00000498: ret 
  39  0x0000049C: label fb3
  40  0x000004A8: nop 
  41  0x000004AC: mov r1.xyz, r1.xyzx
  42  0x000004C0: ret 
  43  0x000004C4: label fb4
  44  0x000004D0: nop 
  45  0x000004D4: mov r0.w, this[1].z
  46  0x000004E8: mov r1.w, this[1].w
  47  0x000004FC: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
  48  0x00000530: sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yzyy, t[r0.w + 1].xyzw, s[r1.w + 1]
  49  0x0000056C: mov r0.w, this[1].y
  50  0x00000580: mov r1.w, this[1].x
  51  0x00000594: mul r3.xyz, r3.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  52  0x000005BC: add r1.xyz, r2.xyzx, r3.xyzx
  53  0x000005D8: ret 
  54  0x000005DC: label fb5
  55  0x000005E8: nop 
  56  0x000005EC: mov r0.w, this[1].z
  57  0x00000600: mov r1.w, this[1].w
  58  0x00000614: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.xyxx, t[r0.w + 0].xyzw, s[r1.w + 0]
  59  0x00000648: mov r1.xyz, r1.xyzx
  60  0x0000065C: ret 
  61  0x00000660: label fb6
  62  0x0000066C: nop 
  63  0x00000670: mov r1.xyz, r1.xyzx
  64  0x00000684: ret 
  65  0x00000688: label fb7
  66  0x00000694: nop 
  67  0x00000698: mov r0.w, this[3].z
  68  0x000006AC: mov r1.w, this[3].w
  69  0x000006C0: sample_indexable(texture2d)(float,float,float,float) r2.xyz, v0.zyzz, t[r0.w + 0].xyzw, s[r1.w + 0]
  70  0x000006F4: sample_indexable(texture2d)(float,float,float,float) r3.xyz, v0.yxyy, t[r0.w + 1].xyzw, s[r1.w + 1]
  71  0x00000730: mov r0.w, this[3].y
  72  0x00000744: mov r1.w, this[3].x
  73  0x00000758: mul r3.xyz, r3.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  74  0x00000780: add r1.xyz, r2.xyzx, r3.xyzx
  75  0x0000079C: ret 
  76  0x000007A0: label fb8
  77  0x000007AC: nop 
  78  0x000007B0: mov r0.w, this[3].z
  79  0x000007C4: mov r1.w, this[3].w
  80  0x000007D8: sample_indexable(texture2d)(float,float,float,float) r1.xyz, v0.zyzz, t[r0.w + 0].xyzw, s[r1.w + 0]
  81  0x0000080C: mov r1.xyz, r1.xyzx
  82  0x00000820: ret 
  83  0x00000824: label fb9
  84  0x00000830: nop 
  85  0x00000834: mov r0.xyzw, r0.xyzw
  86  0x00000848: ret 
  87  0x0000084C: label fb10
  88  0x00000858: nop 
  89  0x0000085C: mov r1.x, this[4].y
  90  0x00000870: mov r1.y, this[4].x
  91  0x00000884: mul r0.xyzw, r0.wzyx, cb[r1.y + 0][r1.x + 0].xyzw
  92  0x000008AC: ret 
