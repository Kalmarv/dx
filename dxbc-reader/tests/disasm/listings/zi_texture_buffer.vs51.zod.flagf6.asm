      0x00000000: vs_5_1
      0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
      0x0000000C: dcl_resource_buffer (mixed,mixed,mixed,mixed) T0[1:1], space=0
      0x00000028: dcl_resource_buffer (mixed,mixed,mixed,mixed) T1[2:4], space=0
      0x00000044: dcl_output o0.x
      0x00000050: dcl_temps 1
   0  0x00000058: ld r0.xy, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), T0[1].xyzw
   1  0x00000084: ld r0.z, l(0x00000005, 0x00000005, 0x00000005, 0x00000005), T0[1].yzxw
   2  0x000000B0: add r0.x, r0.y, r0.x
   3  0x000000CC: mov r0.y, l(0x00000002)
   4  0x000000E0: iadd r0.y, r0.y, l(0x00000001)
   5  0x000000FC: ld r0.y, r0.yyyy, T0[1].xyzw
   6  0x0000011C: add r0.x, r0.y, r0.x
   7  0x00000138: add r0.x, r0.z, r0.x
   8  0x00000154: mov r0.y, l(0x00000003)
   9  0x00000168: iadd r0.y, r0.y, l(0x00000006)
  10  0x00000184: ld r0.y, r0.yyyy, T0[1].yxzw
  11  0x000001A4: add r0.x, r0.y, r0.x
  12  0x000001C0: mov r0.y, l(0x00000002)
  13  0x000001D4: ld r0.y, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), T1[r0.y + 2].yxzw
  14  0x00000208: add r0.x, r0.y, r0.x
  15  0x00000224: mov r0.y, l(0x00000001)
  16  0x00000238: ld r0.y, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), T1[r0.y + 2].xyzw
  17  0x0000026C: add r0.x, r0.y, r0.x
  18  0x00000288: mov r0.y, l(0x00000000)
  19  0x0000029C: mov r0.z, l(0x00000002)
  20  0x000002B0: iadd r0.z, r0.z, l(0x00000001)
  21  0x000002CC: ld r0.y, r0.zzzz, T1[r0.y + 2].xyzw
  22  0x000002F4: add r0.x, r0.y, r0.x
  23  0x00000310: mov r0.y, l(0x00000001)
  24  0x00000324: ld r0.y, l(0x00000005, 0x00000005, 0x00000005, 0x00000005), T1[r0.y + 2].yxzw
  25  0x00000358: add r0.x, r0.y, r0.x
  26  0x00000374: mov r0.y, l(0x00000000)
  27  0x00000388: mov r0.z, l(0x00000003)
  28  0x0000039C: iadd r0.z, r0.z, l(0x00000006)
  29  0x000003B8: ld r0.y, r0.zzzz, T1[r0.y + 2].yxzw
  30  0x000003E0: add o0.x, r0.y, r0.x
  31  0x000003FC: ret 
