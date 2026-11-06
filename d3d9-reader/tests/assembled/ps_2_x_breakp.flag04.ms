    ps_2_x
          defi i0, 10, 0, 0, 0
          def c3, 0, 0, 0, 0
   0:     mov r0, c3
   1:     mov r1, c1
   2:     rep i0
   5:       add r0, r0, c0
   6:       setp_ge p0.x, r0.x, r1.x
   7:       break p0.
  10:     endrep
  12:     mov oC0, r0

// approximately 13 instruction slots used
