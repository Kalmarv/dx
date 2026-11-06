      0x00000000: ps_5_0
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_input_ps linear v0.xyzw
      0x00000018: dcl_output o0.xyzw
      0x00000024: dcl_temps 4
   0  0x0000002C: itof r0.xy, l(0x00000002, 0x00000002, 0x00000000, 0x00000000)
   1  0x0000004C: mul r0.xy, r0.xyxx, v0.xyxx
   2  0x00000068: itof r0.zw, l(0x00000000, 0x00000000, 0x00000001, 0x00000001)
   3  0x00000088: add r0.zw, r0.zzzw, v0.zzzw
   4  0x000000A4: mul r1.x, v0.w, v0.x
   5  0x000000C0: mul r1.y, v0.z, v0.y
   6  0x000000DC: itof r1.zw, l(0x00000000, 0x00000000, 0x00000003, 0x00000003)
   7  0x000000FC: mul r1.zw, r1.zzzw, v0.yyyx
   8  0x00000118: itof r2.xy, l(0x00000004, 0x00000004, 0x00000000, 0x00000000)
   9  0x00000138: mul r2.xy, r2.xyxx, v0.wzww
  10  0x00000154: itof r2.zw, l(0x00000000, 0x00000000, 0x00000005, 0x00000005)
  11  0x00000174: mul r2.zw, r2.zzzw, v0.xxxz
  12  0x00000190: itof r3.xy, l(0x00000006, 0x00000006, 0x00000000, 0x00000000)
  13  0x000001B0: mul r3.xy, r3.xyxx, v0.zxzz
  14  0x000001CC: add o0.x, r0.x, r1.w
  15  0x000001E8: add o0.y, r0.w, r2.x
  16  0x00000204: add r0.x, r0.z, r0.y
  17  0x00000220: add o0.z, r2.z, r0.x
  18  0x0000023C: add r0.x, r1.y, r1.x
  19  0x00000258: add r0.x, r1.z, r0.x
  20  0x00000274: add r0.x, r2.y, r0.x
  21  0x00000290: add r0.x, r2.w, r0.x
  22  0x000002AC: mul r0.y, r3.y, r3.x
  23  0x000002C8: add o0.w, r0.y, r0.x
  24  0x000002E4: ret 
