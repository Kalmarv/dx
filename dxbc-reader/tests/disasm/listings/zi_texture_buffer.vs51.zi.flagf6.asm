      0x00000000: vs_5_1
      0x00000008: dcl_globalFlags refactoringAllowed
      0x0000000C: dcl_resource_buffer (mixed,mixed,mixed,mixed) T0[1:1], space=0
      0x00000028: dcl_resource_buffer (mixed,mixed,mixed,mixed) T1[2:4], space=0
      0x00000044: dcl_output o0.x
      0x00000050: dcl_temps 1
   0  0x00000058: ld r0.xy, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), T0[1].xyzw
   1  0x00000084: ld r0.z, l(0x00000005, 0x00000005, 0x00000005, 0x00000005), T0[1].yzxw
   2  0x000000B0: add r0.x, r0.y, r0.x
   3  0x000000CC: ld r0.y, l(0x00000003, 0x00000003, 0x00000003, 0x00000003), T0[1].xyzw
   4  0x000000F8: add r0.x, r0.y, r0.x
   5  0x00000114: add r0.x, r0.z, r0.x
   6  0x00000130: ld r0.y, l(0x00000009, 0x00000009, 0x00000009, 0x00000009), T0[1].yxzw
   7  0x0000015C: add r0.x, r0.y, r0.x
   8  0x00000178: ld r0.y, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), T1[4].yxzw
   9  0x000001A4: add r0.x, r0.y, r0.x
  10  0x000001C0: ld r0.y, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), T1[3].xyzw
  11  0x000001EC: add r0.x, r0.y, r0.x
  12  0x00000208: ld r0.y, l(0x00000003, 0x00000003, 0x00000003, 0x00000003), T1[2].xyzw
  13  0x00000234: add r0.x, r0.y, r0.x
  14  0x00000250: ld r0.y, l(0x00000005, 0x00000005, 0x00000005, 0x00000005), T1[3].yxzw
  15  0x0000027C: add r0.x, r0.y, r0.x
  16  0x00000298: ld r0.y, l(0x00000009, 0x00000009, 0x00000009, 0x00000009), T1[2].yxzw
  17  0x000002C4: add o0.x, r0.y, r0.x
  18  0x000002E0: ret 
