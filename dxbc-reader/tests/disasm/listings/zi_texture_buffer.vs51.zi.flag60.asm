0x00000000: vs_5_1
0x00000008: dcl_globalFlags refactoringAllowed
0x0000000C: dcl_resource_buffer (mixed,mixed,mixed,mixed) T0[1:1], space=0
0x00000028: dcl_resource_buffer (mixed,mixed,mixed,mixed) T1[2:4], space=0
0x00000044: dcl_output o0.x
0x00000050: dcl_temps 1
//
// Initial variable locations:
//   o0.x <- <main return value>
//
#line 22 "C:\dx-fixtures\zi_texture_buffer.hlsl"
0x00000058: ld r0.xy, l(0, 0, 0, 0), T0[1].xyzw  // r0.x <- tb.a; r0.y <- tb.b.x
0x00000084: ld r0.z, l(5, 5, 5, 5), T0[1].yzxw  // r0.z <- tb.s.f
0x000000B0: add r0.x, r0.y, r0.x
0x000000CC: ld r0.y, l(3, 3, 3, 3), T0[1].xyzw  // r0.y <- tb.c._m10
0x000000F8: add r0.x, r0.y, r0.x
0x00000114: add r0.x, r0.z, r0.x
0x00000130: ld r0.y, l(9, 9, 9, 9), T0[1].yxzw  // r0.y <- tb
// <internal error> could not get find UDT child with correct offset in PDB

0x0000015C: add r0.x, r0.y, r0.x
0x00000178: ld r0.y, l(0, 0, 0, 0), T1[4].yxzw  // r0.y <- tbs[0].a
0x000001A4: add r0.x, r0.y, r0.x
0x000001C0: ld r0.y, l(0, 0, 0, 0), T1[3].xyzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

0x000001EC: add r0.x, r0.y, r0.x
0x00000208: ld r0.y, l(3, 3, 3, 3), T1[2].xyzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

0x00000234: add r0.x, r0.y, r0.x
0x00000250: ld r0.y, l(5, 5, 5, 5), T1[3].yxzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

0x0000027C: add r0.x, r0.y, r0.x
0x00000298: ld r0.y, l(9, 9, 9, 9), T1[2].yxzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

0x000002C4: add o0.x, r0.y, r0.x
0x000002E0: ret 
