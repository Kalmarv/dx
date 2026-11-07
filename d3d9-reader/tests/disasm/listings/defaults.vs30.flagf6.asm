    vs_3_0
      0x00000254:     def c10, 0x3f800000, 0x00000000, 0x00000000, 0x00000000
      0x0000026C:     dcl_color v0
      0x00000278:     dcl_position o0
   0  0x00000284:     mov r0, c7
   1  0x00000290:     add r0, r0, c8
   2  0x000002A0:     dp4 r1.x, v0, c0
   3  0x000002B0:     dp4 r1.y, v0, c1
   4  0x000002C0:     dp4 r1.z, v0, c2
   5  0x000002D0:     dp4 r1.w, v0, c3
   6  0x000002E0:     add r0, r0, r1
   7  0x000002F0:     add r0, r0, c5.x
   8  0x00000300:     add r0, r0, c6.x
   9  0x00000310:     add r0, r0, c123
  10  0x00000320:     add r0, r0, c9.xyzz
  11  0x00000330:     mov r1, r0
  12  0x0000033C:     rep i0
  15  0x00000344:       add r1, r1, v0
  16  0x00000354:     endrep
  18  0x00000358:     if b0
  21  0x00000360:       add r1, r1, r1
  22  0x00000370:     endif
  23  0x00000374:     if b2
  26  0x0000037C:       add o0, r1, c10.x
  27  0x0000038C:     else
  28  0x00000390:       mov o0, r1
  29  0x0000039C:     endif

// approximately 30 instruction slots used
