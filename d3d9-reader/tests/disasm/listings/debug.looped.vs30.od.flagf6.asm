    vs_3_0
      0x000002F8:     def c4, 0x00000000, 0x00000000, 0x3f800000, 0x00000000
      0x00000310:     defi i0, 255, 0, 0, 0
      0x00000328:     dcl_position v0
      0x00000334:     dcl_position o0
   0  0x00000340:     mov r0, v0
   1  0x0000034C:     mov r1.x, c4.x
   2  0x00000358:     mov r2, r0
   3  0x00000364:     mov r1.y, r1.x
   4  0x00000370:     rep i0
   7  0x00000378:       slt r1.z, r1.y, c3.x
   8  0x00000388:       mov r1.w, -r1.z
   9  0x00000394:       sge r1.z, r1.w, r1.z
  10  0x000003A4:       break_ne r1.z, -r1.z
  13  0x000003B0:       mul r3, r1.y, c2
  14  0x000003C0:       add r2, r2, r3
  15  0x000003D0:       add r1.y, r1.y, c4.z
  16  0x000003E0:     endrep
  18  0x000003E4:     if b0
  21  0x000003EC:       mov r2, -r2
  22  0x000003F8:     endif
  23  0x000003FC:     mov o0, r2

// approximately 24 instruction slots used
