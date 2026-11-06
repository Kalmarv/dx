    ps_2_0
      0x00000270:     def c3, 0x00000000, 0x3f800000, 0x00000000, 0x00000000
      0x00000288:     dcl t0.xy
      0x00000294:     dcl_2d s0
   0  0x000002A0:     texld r0, t0, s0
   0  0x000002B0:     mov r0.x, -r0.x
   1  0x000002BC:     add r0.x, r0.x, c0.x
   2  0x000002CC:     cmp r0, r0.x, c3.x, c3.y
   3  0x000002E0:     mov r1, -r0
   4  0x000002EC:     mov r0, -r0
   5  0x000002F8:     add r0, r0, r1
   6  0x00000308:     cmp r0, r0, c3.x, c3.y
   7  0x0000031C:     mov r0, -r0
   8  0x00000328:     mov r1, c2
   9  0x00000334:     cmp r0, r0, r1, c1
  10  0x00000348:     mov oC0, r0

// approximately 12 instruction slots used (1 texture, 11 arithmetic)
