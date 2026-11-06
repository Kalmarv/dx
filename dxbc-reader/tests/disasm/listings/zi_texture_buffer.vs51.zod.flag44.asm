      vs_5_1
      dcl_globalFlags refactoringAllowed | skipOptimization
      dcl_resource_buffer (mixed,mixed,mixed,mixed) T0[1:1], space=0
      dcl_resource_buffer (mixed,mixed,mixed,mixed) T1[2:4], space=0
      dcl_output o0.x
      dcl_temps 1
//
// Initial variable locations:
//   o0.x <- <main return value>
//
#line 22 "C:\dx-fixtures\zi_texture_buffer.hlsl"
   0: ld r0.xy, l(0, 0, 0, 0), T0[1].xyzw  // r0.x <- tb.a; r0.y <- tb.b.x
   1: ld r0.z, l(5, 5, 5, 5), T0[1].yzxw  // r0.z <- tb.s.f
   2: add r0.x, r0.y, r0.x
   3: mov r0.y, l(2)
   4: iadd r0.y, r0.y, l(1)
   5: ld r0.y, r0.yyyy, T0[1].xyzw  // r0.y <- tb.c._m10
   6: add r0.x, r0.y, r0.x
   7: add r0.x, r0.z, r0.x
   8: mov r0.y, l(3)
   9: iadd r0.y, r0.y, l(6)
  10: ld r0.y, r0.yyyy, T0[1].yxzw  // r0.y <- tb
// <internal error> could not get find UDT child with correct offset in PDB

  11: add r0.x, r0.y, r0.x
  12: mov r0.y, l(2)
  13: ld r0.y, l(0, 0, 0, 0), T1[r0.y + 2].yxzw  // r0.y <- tbs[0].a
  14: add r0.x, r0.y, r0.x
  15: mov r0.y, l(1)
  16: ld r0.y, l(0, 0, 0, 0), T1[r0.y + 2].xyzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

  17: add r0.x, r0.y, r0.x
  18: mov r0.y, l(0)
  19: mov r0.z, l(2)
  20: iadd r0.z, r0.z, l(1)
  21: ld r0.y, r0.zzzz, T1[r0.y + 2].xyzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

  22: add r0.x, r0.y, r0.x
  23: mov r0.y, l(1)
  24: ld r0.y, l(5, 5, 5, 5), T1[r0.y + 2].yxzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

  25: add r0.x, r0.y, r0.x
  26: mov r0.y, l(0)
  27: mov r0.z, l(3)
  28: iadd r0.z, r0.z, l(6)
  29: ld r0.y, r0.zzzz, T1[r0.y + 2].yxzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

  30: add o0.x, r0.y, r0.x
  31: ret 
