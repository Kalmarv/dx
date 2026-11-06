    ps_2_x
          defi i0, 4, 0, 0, 0
   0:     mov r1, c1
   1:     rep i0
   4:       setp_ge p0, c0, r1
   5:       break_d8 p0.
   8:     endrep
  10:     mov oC0, c0

// approximately 11 instruction slots used
