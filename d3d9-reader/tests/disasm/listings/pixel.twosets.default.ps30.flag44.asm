    ps_3_0
          def c1, 0, 0, 0, 0
          dcl_color v0
   0:     mov r0, c1.x
   1:     rep i0
   4:       add r0, r0, v0
   5:     endrep
   7:     mul oC0, r0, c0.y

// approximately 8 instruction slots used
