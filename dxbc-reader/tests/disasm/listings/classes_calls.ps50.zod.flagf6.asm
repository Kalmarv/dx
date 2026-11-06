      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_constantbuffer CB0[1], immediateIndexed
      0x0000001C: dcl_function_body fb0
      0x00000024: dcl_function_body fb1
      0x0000002C: dcl_function_body fb2
      0x00000034: dcl_function_body fb3
      0x0000003C: dcl_function_body fb4
      0x00000044: dcl_function_body fb5
      0x0000004C: dcl_function_body fb6
      0x00000054: dcl_function_body fb7
      0x0000005C: dcl_function_body fb8
      0x00000064: dcl_function_body fb9
      0x0000006C: dcl_function_table ft0 = {fb0, fb2, fb4, fb6}
      0x00000088: dcl_function_table ft1 = {fb1, fb3, fb5, fb7}
      0x000000A4: dcl_function_table ft2 = {fb8}
      0x000000B4: dcl_function_table ft3 = {fb9}
      0x000000C4: dcl_interface_dynamicindexed fp0[3][4] = {ft0, ft1}
      0x000000DC: dcl_interface fp3[1][1] = {ft2, ft3}
      0x000000F4: dcl_input_ps linear v0.xyz
      0x00000100: dcl_output o0.xyzw
      0x0000010C: dcl_temps 2
   0  0x00000114: nop 
   1  0x00000118: mov r0.xyz, v0.xyzx
   2  0x0000012C: fcall fp0[0][0]
   3  0x00000140: nop 
   4  0x00000144: mov r0.xyz, v0.xyzx
   5  0x00000158: fcall fp0[1][1]
   6  0x0000016C: add r0.xyz, r0.xyzx, r1.xyzx
   7  0x00000188: nop 
   8  0x0000018C: mov r1.xyz, v0.xyzx
   9  0x000001A0: fcall fp0[2][2]
  10  0x000001B4: add r0.xyz, r0.xyzx, r1.xyzx
  11  0x000001D0: nop 
  12  0x000001D4: mov r0.w, v0.x
  13  0x000001E8: mov r1.x, cb0[0].x
  14  0x00000200: fcall fp0[r1.x + 0][3]
  15  0x00000218: add r0.xyz, r0.xyzx, r1.yyyy
  16  0x00000234: nop 
  17  0x00000238: mov r0.w, v0.y
  18  0x0000024C: fcall fp3[0][0]
  19  0x00000260: add o0.xyz, r0.xyzx, r1.xxxx
  20  0x0000027C: itof o0.w, l(0x00000001)
  21  0x00000290: ret 
  22  0x00000294: label fb0
  23  0x000002A0: nop 
  24  0x000002A4: mov r1.xyz, -r0.xyzx
  25  0x000002BC: ret 
  26  0x000002C0: label fb1
  27  0x000002CC: nop 
  28  0x000002D0: mov r0.w, this[0].y
  29  0x000002E4: mov r1.w, this[0].x
  30  0x000002F8: add r1.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xxxx
  31  0x00000320: ret 
  32  0x00000324: label fb2
  33  0x00000330: nop 
  34  0x00000334: mov r0.xyz, r0.xyzx
  35  0x00000348: ret 
  36  0x0000034C: label fb3
  37  0x00000358: nop 
  38  0x0000035C: mov r0.w, this[1].y
  39  0x00000370: mov r1.w, this[1].x
  40  0x00000384: mul r0.xyz, r0.xyzx, cb[r1.w + 0][r0.w + 0].xxxx
  41  0x000003AC: ret 
  42  0x000003B0: label fb4
  43  0x000003BC: nop 
  44  0x000003C0: mov r1.xyz, r1.xyzx
  45  0x000003D4: ret 
  46  0x000003D8: label fb5
  47  0x000003E4: nop 
  48  0x000003E8: mov r0.w, this[2].y
  49  0x000003FC: mov r1.w, this[2].x
  50  0x00000410: mul r1.xyz, r1.xyzx, cb[r1.w + 0][r0.w + 0].xxxx
  51  0x00000438: ret 
  52  0x0000043C: label fb6
  53  0x00000448: nop 
  54  0x0000044C: itof r1.z, l(0x00000002)
  55  0x00000460: mul r1.y, r0.w, r1.z
  56  0x0000047C: ret 
  57  0x00000480: label fb7
  58  0x0000048C: nop 
  59  0x00000490: mov r1.z, this[r1.x + 0].y
  60  0x000004A8: mov r1.x, this[r1.x + 0].x
  61  0x000004C0: mov r1.x, -cb[r1.x + 0][r1.z + 0].x
  62  0x000004E4: add r1.y, r0.w, r1.x
  63  0x00000500: ret 
  64  0x00000504: label fb8
  65  0x00000510: nop 
  66  0x00000514: itof r1.y, l(0x00000002)
  67  0x00000528: mul r1.x, r0.w, r1.y
  68  0x00000544: ret 
  69  0x00000548: label fb9
  70  0x00000554: nop 
  71  0x00000558: mov r1.y, this[3].y
  72  0x0000056C: mov r1.z, this[3].x
  73  0x00000580: mov r1.y, -cb[r1.z + 0][r1.y + 0].x
  74  0x000005A4: add r1.x, r0.w, r1.y
  75  0x000005C0: ret 
