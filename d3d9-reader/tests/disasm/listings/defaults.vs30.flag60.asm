    vs_3_0
0x00000254:     def c10, 1, 0, 0, 0
0x0000026C:     dcl_color v0
0x00000278:     dcl_position o0
0x00000284:     mov r0, c7
0x00000290:     add r0, r0, c8
0x000002A0:     dp4 r1.x, v0, c0
0x000002B0:     dp4 r1.y, v0, c1
0x000002C0:     dp4 r1.z, v0, c2
0x000002D0:     dp4 r1.w, v0, c3
0x000002E0:     add r0, r0, r1
0x000002F0:     add r0, r0, c5.x
0x00000300:     add r0, r0, c6.x
0x00000310:     add r0, r0, c123
0x00000320:     add r0, r0, c9.xyzz
0x00000330:     mov r1, r0
0x0000033C:     rep i0
0x00000344:       add r1, r1, v0
0x00000354:     endrep
0x00000358:     if b0
0x00000360:       add r1, r1, r1
0x00000370:     endif
0x00000374:     if b2
0x0000037C:       add o0, r1, c10.x
0x0000038C:     else
0x00000390:       mov o0, r1
0x0000039C:     endif

// approximately 30 instruction slots used
