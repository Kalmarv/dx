    vs_2_0
          def c1, 0, 0, 0, 0
          dcl_position v0
   0:     mov oPos, v0
   1:     mov r0, c1
   2:     rep i0
   5:       add r0, r0, c0
   6:     endrep
   8:     mov oT0.xy, r0

// approximately 9 instruction slots used
