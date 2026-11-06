vs_5_1
dcl_globalFlags refactoringAllowed
dcl_resource_buffer (mixed,mixed,mixed,mixed) T0[1:1], space=0
dcl_resource_buffer (mixed,mixed,mixed,mixed) T1[2:4], space=0
dcl_output o0.x
dcl_temps 1
//
// Initial variable locations:
//   o0.x <- <main return value>
//
#line 22 "C:\dx-fixtures\zi_texture_buffer.hlsl"
ld r0.xy, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), T0[1].xyzw  // r0.x <- tb.a; r0.y <- tb.b.x
ld r0.z, l(0x00000005, 0x00000005, 0x00000005, 0x00000005), T0[1].yzxw  // r0.z <- tb.s.f
add r0.x, r0.y, r0.x
ld r0.y, l(0x00000003, 0x00000003, 0x00000003, 0x00000003), T0[1].xyzw  // r0.y <- tb.c._m10
add r0.x, r0.y, r0.x
add r0.x, r0.z, r0.x
ld r0.y, l(0x00000009, 0x00000009, 0x00000009, 0x00000009), T0[1].yxzw  // r0.y <- tb
// <internal error> could not get find UDT child with correct offset in PDB

add r0.x, r0.y, r0.x
ld r0.y, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), T1[4].yxzw  // r0.y <- tbs[0].a
add r0.x, r0.y, r0.x
ld r0.y, l(0x00000000, 0x00000000, 0x00000000, 0x00000000), T1[3].xyzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

add r0.x, r0.y, r0.x
ld r0.y, l(0x00000003, 0x00000003, 0x00000003, 0x00000003), T1[2].xyzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

add r0.x, r0.y, r0.x
ld r0.y, l(0x00000005, 0x00000005, 0x00000005, 0x00000005), T1[3].yxzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

add r0.x, r0.y, r0.x
ld r0.y, l(0x00000009, 0x00000009, 0x00000009, 0x00000009), T1[2].yxzw  // r0.y <- tbs
// <internal error> offset overruns length for type in PDB

add o0.x, r0.y, r0.x
ret 
