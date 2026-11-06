    vs_3_0
      0x00000284:     def c3, 0x00000000, 0x3f800000, 0x00000000, 0x00000000
      0x0000029C:     dcl_position v0
      0x000002A8:     dcl_position o0
   0  0x000002B4:     mov r0, v0
   1  0x000002C0:     mov r1.x, c3.x
   2  0x000002CC:     rep i0
   5  0x000002D4:       mad r0, c2, r1.x, r0
   6  0x000002E8:       add r1.x, r1.x, c3.y
   7  0x000002F8:     endrep
   9  0x000002FC:     if b0
  12  0x00000304:       mov o0, -r0
  13  0x00000310:     else
  14  0x00000314:       mov o0, r0
  15  0x00000320:     endif

// approximately 16 instruction slots used
