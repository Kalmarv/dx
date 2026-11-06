    ps_2_x
          defi i0, 3, 0, 0, 0
          def c2, 0, 0, 0, 0
   0:     mov r0, c2
   1:     rep i0
   4:       add r0, r0, c0
   5:     endrep
   7:     mov oC0, r0

// approximately 8 instruction slots used
