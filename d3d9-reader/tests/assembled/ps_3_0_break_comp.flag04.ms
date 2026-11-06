    ps_3_0
          defi i0, 10, 0, 0, 0
          def c3, 0, 0, 0, 0
          def c4, 1, 1, 1, 1
   0:     mov r0, c3
   1:     rep i0
   4:       add r0, r0, c4
   5:       break_ge r0.x, c1.x
   8:     endrep
  10:     mov oC0, r0

// approximately 11 instruction slots used
