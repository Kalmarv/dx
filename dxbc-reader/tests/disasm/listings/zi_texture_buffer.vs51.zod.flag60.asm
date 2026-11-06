0x00000000: vs_5_1
0x00000008: dcl_globalFlags refactoringAllowed | skipOptimization
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
0x000000CC: mov r0.y, l(2)
0x000000E0: iadd r0.y, r0.y, l(1)
0x000000FC: ld r0.y, r0.yyyy, T0[1].xyzw  // r0.y <- tb.c._m10
0x0000011C: add r0.x, r0.y, r0.x
0x00000138: add r0.x, r0.z, r0.x
0x00000154: mov r0.y, l(3)
0x00000168: iadd r0.y, r0.y, l(6)
0x00000184: ld r0.y, r0.yyyy, T0[1].yxzw  // r0.y <- tb
// <internal error> could not get find UDT child with correct offset in PDB

0x000001A4: add r0.x, r0.y, r0.x
0x000001C0: mov r0.y, l(2)
0x000001D4: ld r0.y, l(0, 0, 0, 0), T1[r0.y + 2].yxzw  // r0.y <- tbs[0].a
0x00000208: add r0.x, r0.y, r0.x
0x00000224: mov r0.y, l(1)
0x00000238: ld r0.y, l(0, 0, 0, 0), T1[r0.y + 2].xyzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

0x0000026C: add r0.x, r0.y, r0.x
0x00000288: mov r0.y, l(0)
0x0000029C: mov r0.z, l(2)
0x000002B0: iadd r0.z, r0.z, l(1)
0x000002CC: ld r0.y, r0.zzzz, T1[r0.y + 2].xyzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

0x000002F4: add r0.x, r0.y, r0.x
0x00000310: mov r0.y, l(1)
0x00000324: ld r0.y, l(5, 5, 5, 5), T1[r0.y + 2].yxzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

0x00000358: add r0.x, r0.y, r0.x
0x00000374: mov r0.y, l(0)
0x00000388: mov r0.z, l(3)
0x0000039C: iadd r0.z, r0.z, l(6)
0x000003B8: ld r0.y, r0.zzzz, T1[r0.y + 2].yxzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

0x000003E0: add o0.x, r0.y, r0.x
0x000003FC: ret 
