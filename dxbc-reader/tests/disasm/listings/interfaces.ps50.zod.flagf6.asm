      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[4], immediateIndexed
      0x0000001C: dcl_function_body fb0
      0x00000024: dcl_function_body fb1
      0x0000002C: dcl_function_body fb2
      0x00000034: dcl_function_body fb3
      0x0000003C: dcl_function_body fb4
      0x00000044: dcl_function_body fb5
      0x0000004C: dcl_function_table ft0 = {fb0, fb2}
      0x00000060: dcl_function_table ft1 = {fb1, fb3}
      0x00000074: dcl_function_table ft2 = {fb4}
      0x00000084: dcl_function_table ft3 = {fb5}
      0x00000094: dcl_interface fp0[2][2] = {ft0, ft1}
      0x000000AC: dcl_interface fp2[1][1] = {ft2, ft3}
      0x000000C4: dcl_input_ps linear v0.xyz
      0x000000D0: dcl_output o0.xyzw
      0x000000DC: dcl_temps 3
   0  0x000000E4: itof r0.xyz, l(0x00000000, 0x00000000, 0x00000000, 0x00000000)
   1  0x00000104: nop 
   2  0x00000108: mov r1.xyz, v0.xyzx
   3  0x0000011C: fcall fp0[0][0]
   4  0x00000130: add r0.xyz, r0.xyzx, r2.xyzx
   5  0x0000014C: nop 
   6  0x00000150: mov r1.xyz, v0.xyzx
   7  0x00000164: fcall fp0[1][1]
   8  0x00000178: add r0.xyz, r0.xyzx, r2.xyzx
   9  0x00000194: nop 
  10  0x00000198: mov r0.xyz, r0.xyzx
  11  0x000001AC: fcall fp2[0][0]
  12  0x000001C0: mov o0.xyzw, r0.xyzw
  13  0x000001D4: ret 
  14  0x000001D8: label fb0
  15  0x000001E4: nop 
  16  0x000001E8: mov r0.w, this[0].y
  17  0x000001FC: mov r1.w, this[0].x
  18  0x00000210: mov r2.xyz, cb[r1.w + 0][r0.w + 0].xyzx
  19  0x00000230: ret 
  20  0x00000234: label fb1
  21  0x00000240: nop 
  22  0x00000244: mov r0.w, this[0].y
  23  0x00000258: mov r1.w, this[0].x
  24  0x0000026C: dp3 r1.x, r1.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  25  0x00000294: max r1.x, r1.x, l(0x00000000)
  26  0x000002B0: min r1.x, r1.x, l(0x3f800000)
  27  0x000002CC: mul r2.xyz, r1.xxxx, cb[r1.w + 0][r0.w + 1].xyzx
  28  0x000002F8: ret 
  29  0x000002FC: label fb2
  30  0x00000308: nop 
  31  0x0000030C: mov r0.w, this[1].y
  32  0x00000320: mov r1.w, this[1].x
  33  0x00000334: mov r2.xyz, cb[r1.w + 0][r0.w + 0].xyzx
  34  0x00000354: ret 
  35  0x00000358: label fb3
  36  0x00000364: nop 
  37  0x00000368: mov r0.w, this[1].y
  38  0x0000037C: mov r1.w, this[1].x
  39  0x00000390: dp3 r1.x, r1.xyzx, cb[r1.w + 0][r0.w + 0].xyzx
  40  0x000003B8: max r1.x, r1.x, l(0x00000000)
  41  0x000003D4: min r1.x, r1.x, l(0x3f800000)
  42  0x000003F0: mul r2.xyz, r1.xxxx, cb[r1.w + 0][r0.w + 1].xyzx
  43  0x0000041C: ret 
  44  0x00000420: label fb4
  45  0x0000042C: nop 
  46  0x00000430: itof r0.w, l(0x00000001)
  47  0x00000444: mov r1.x, this[2].y
  48  0x00000458: mov r1.y, this[2].x
  49  0x0000046C: mul r0.xyzw, r0.xyzw, cb[r1.y + 0][r1.x + 0].xyzw
  50  0x00000494: ret 
  51  0x00000498: label fb5
  52  0x000004A4: nop 
  53  0x000004A8: itof r0.w, l(0x00000001)
  54  0x000004BC: mov r0.xyz, r0.xyzx
  55  0x000004D0: ret 
