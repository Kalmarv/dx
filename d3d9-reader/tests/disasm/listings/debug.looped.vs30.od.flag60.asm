    vs_3_0
0x000002F8:     def c4, 0, 0, 1, 0
0x00000310:     defi i0, 255, 0, 0, 0
0x00000328:     dcl_position v0  // p<0,1,2,3>
0x00000334:     dcl_position o0

#line 67 "C:\dx9-fixtures\debug.hlsl"
0x00000340:     mov r0, v0  // ::o<0,1,2,3>
0x0000034C:     mov r1.x, c4.x  // ::i<0>
0x00000358:     mov r2, r0  // ::o<0,1,2,3>
0x00000364:     mov r1.y, r1.x  // ::i<0>
0x00000370:     rep i0
0x00000378:       slt r1.z, r1.y, c3.x
0x00000388:       mov r1.w, -r1.z
0x00000394:       sge r1.z, r1.w, r1.z
0x000003A4:       break_ne r1.z, -r1.z
0x000003B0:       mul r3, r1.y, c2
0x000003C0:       add r2, r2, r3  // ::o<0,1,2,3>
0x000003D0:       add r1.y, r1.y, c4.z  // ::i<0>
0x000003E0:     endrep
0x000003E4:     if b0
0x000003EC:       mov r2, -r2  // ::o<0,1,2,3>
0x000003F8:     endif
0x000003FC:     mov o0, r2  // ::looped<0,1,2,3>

// approximately 24 instruction slots used
