    vs_2_0
          defb b0, true
          defi i0, 4, 0, 0, 0
          def c1, 0, 0, 0, 0
          dcl_position v0
   0:     mov oPos, v0
   1:     mov r0, c1
   2:     if b0
   5:       rep i0
   8:         add r0, r0, c0
   9:       endrep
  11:     endif
  12:     mov oT0.x, r0.x

// approximately 13 instruction slots used
