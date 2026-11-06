      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
      0x0000001C: dcl_constantbuffer CB1[7], immediateIndexed
      0x0000002C: dcl_sampler s0, mode_default
      0x00000038: dcl_resource_texture2d (float,float,float,float) t2
      0x00000048: dcl_function_body fb0
      0x00000050: dcl_function_body fb1
      0x00000058: dcl_function_body fb2
      0x00000060: dcl_function_body fb3
      0x00000068: dcl_function_body fb4
      0x00000070: dcl_function_body fb5
      0x00000078: dcl_function_body fb6
      0x00000080: dcl_function_body fb7
      0x00000088: dcl_function_table ft0 = {fb0, fb2}
      0x0000009C: dcl_function_table ft1 = {fb1, fb3}
      0x000000B0: dcl_function_table ft2 = {fb4, fb6}
      0x000000C4: dcl_function_table ft3 = {fb5, fb7}
      0x000000D8: dcl_interface_dynamicindexed fp0[6][2] = {ft0, ft1}
      0x000000F0: dcl_interface_dynamicindexed fp6[2][2] = {ft2, ft3}
      0x00000108: dcl_input_ps linear v0.xyz
      0x00000114: dcl_input_ps linear v1.xyz
      0x00000120: dcl_input_ps linear v2.xy
      0x0000012C: dcl_output o0.xyzw
      0x00000138: dcl_temps 7
   0  0x00000140: itof r0.xyz, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
   1  0x00000160: mov r0.w, l(0x00000000)
   2  0x00000174: mov r1.xyz, r0.xyzx
   3  0x00000188: mov r2.x, r0.w
   4  0x0000019C: loop 
   5  0x000001A0:   ilt r2.y, r2.x, cb0[0].x
   6  0x000001C0:   breakc_z r2.y
   7  0x000001CC:   nop 
   8  0x000001D0:   imul null, r2.y, r2.x, l(0x00000002)
   9  0x000001F0:   mov r2.z, l(0x00000001)
  10  0x00000204:   and r2.z, r2.z, cb0[0].y
  11  0x00000224:   iadd r2.y, r2.z, r2.y
  12  0x00000240:   mov r3.xyz, v0.xyzx
  13  0x00000254:   mov r4.xyz, v1.xyzx
  14  0x00000268:   fcall fp0[r2.y + 0][0]
  15  0x00000280:   nop 
  16  0x00000284:   imul null, r2.y, r2.x, l(0x00000002)
  17  0x000002A4:   iadd r2.y, r2.y, l(0x00000001)
  18  0x000002C0:   itof r2.z, r2.x
  19  0x000002D4:   fcall fp0[r2.y + 0][1]
  20  0x000002EC:   mul r2.yzw, r2.wwww, r5.xxyz
  21  0x00000308:   add r1.xyz, r1.xyzx, r2.yzwy
  22  0x00000324:   iadd r2.x, r2.x, l(0x00000001)
  23  0x00000340: endloop 
  24  0x00000344: itof r1.w, l(0x00000001)
  25  0x00000358: nop 
  26  0x0000035C: mov r0.x, l(0x00000001)
  27  0x00000370: and r0.x, r0.x, cb0[0].y
  28  0x00000390: fcall fp6[r0.x + 0][0]
  29  0x000003A8: mul r0.xyzw, r1.xyzw, r2.xyzw
  30  0x000003C4: nop 
  31  0x000003C8: itof r1.xy, l(0x00000002, 0x00000002, 0x00000000, 0x00000000)
  32  0x000003E8: mul r1.xy, r1.xyxx, v2.xyxx
  33  0x00000404: fcall fp6[0][1]
  34  0x00000418: add o0.xyzw, r0.xyzw, r2.xyzw
  35  0x00000434: ret 
  36  0x00000438: label fb0
  37  0x00000444: nop 
  38  0x00000448: mov r4.xyz, -r4.xyzx
  39  0x00000460: mov r2.z, this[r2.y + 0].y
  40  0x00000478: mov r2.w, this[r2.y + 0].x
  41  0x00000490: add r4.xyz, r4.xyzx, cb[r2.w + 0][r2.z + 0].xyzx
  42  0x000004B8: dp3 r3.w, r4.xyzx, r4.xyzx
  43  0x000004D4: rsq r3.w, r3.w
  44  0x000004E8: mul r6.xyz, r3.wwww, r4.xyzx
  45  0x00000504: dp3 r3.w, r3.xyzx, r6.xyzx
  46  0x00000520: max r3.w, r3.w, l(0x00000000)
  47  0x0000053C: min r3.w, r3.w, l(0x3f800000)
  48  0x00000558: mul r6.xyz, r3.wwww, cb[r2.w + 0][r2.z + 1].xyzx
  49  0x00000584: nop 
  50  0x00000588: dp3 r3.w, r4.xyzx, r4.xyzx
  51  0x000005A4: sqrt r3.w, r3.w
  52  0x000005B8: itof r4.x, l(0x00000001)
  53  0x000005CC: div r2.z, r3.w, cb[r2.w + 0][r2.z + 1].w
  54  0x000005F8: mov r2.z, -r2.z
  55  0x00000610: add r2.z, r2.z, r4.x
  56  0x0000062C: max r2.z, r2.z, l(0x00000000)
  57  0x00000648: min r2.z, r2.z, l(0x3f800000)
  58  0x00000664: mul r5.xyz, r2.zzzz, r6.xyzx
  59  0x00000680: ret 
  60  0x00000684: label fb1
  61  0x00000690: nop 
  62  0x00000694: mov r2.z, this[r2.y + 0].y
  63  0x000006AC: mov r2.y, this[r2.y + 0].x
  64  0x000006C4: dp3 r2.w, r3.xyzx, cb[r2.y + 0][r2.z + 0].xyzx
  65  0x000006EC: max r2.w, r2.w, l(0x00000000)
  66  0x00000708: min r2.w, r2.w, l(0x3f800000)
  67  0x00000724: mul r5.xyz, r2.wwww, cb[r2.y + 0][r2.z + 1].xyzx
  68  0x00000750: ret 
  69  0x00000754: label fb2
  70  0x00000760: nop 
  71  0x00000764: itof r3.x, l(0x00000001)
  72  0x00000778: mov r3.y, this[r2.y + 0].y
  73  0x00000790: mov r3.z, this[r2.y + 0].x
  74  0x000007A8: div r2.z, r2.z, cb[r3.z + 0][r3.y + 1].w
  75  0x000007D4: mov r2.z, -r2.z
  76  0x000007EC: add r2.z, r2.z, r3.x
  77  0x00000808: max r2.z, r2.z, l(0x00000000)
  78  0x00000824: min r2.w, r2.z, l(0x3f800000)
  79  0x00000840: ret 
  80  0x00000844: label fb3
  81  0x00000850: nop 
  82  0x00000854: itof r2.w, l(0x00000001)
  83  0x00000868: ret 
  84  0x0000086C: label fb4
  85  0x00000878: nop 
  86  0x0000087C: mov r0.y, this[r0.x + 6].z
  87  0x00000898: sample_indexable(texture2d)(float,float,float,float) r2.xyzw, v2.xyxx, t[r0.y + 0].xyzw, s0
  88  0x000008C8: ret 
  89  0x000008CC: label fb5
  90  0x000008D8: nop 
  91  0x000008DC: mov r0.y, this[r0.x + 6].y
  92  0x000008F8: mov r0.x, this[r0.x + 6].x
  93  0x00000914: mov r2.xyzw, cb[r0.x + 0][r0.y + 0].xyzw
  94  0x00000934: ret 
  95  0x00000938: label fb6
  96  0x00000944: nop 
  97  0x00000948: mov r1.z, this[6].z
  98  0x0000095C: sample_indexable(texture2d)(float,float,float,float) r2.xyzw, r1.xyxx, t[r1.z + 0].xyzw, s0
  99  0x0000098C: ret 
 100  0x00000990: label fb7
 101  0x0000099C: nop 
 102  0x000009A0: mov r1.x, this[6].y
 103  0x000009B4: mov r1.y, this[6].x
 104  0x000009C8: mov r2.xyzw, cb[r1.y + 0][r1.x + 0].xyzw
 105  0x000009E8: ret 
