    vs_2_0
          def c0, 0, 0, 0, 0
          dcl_position v0
   0:     mov oPos, v0
   1:     mov r0, c0
   2:     loop aL, i0
   5:       add r0, r0, c0[aL]
   6:     endloop
   8:     mov oT0.x, r0.x

// approximately 9 instruction slots used
