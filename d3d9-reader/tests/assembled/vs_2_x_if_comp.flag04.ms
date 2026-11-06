    vs_2_x
          dcl_position v0
   0:     mov oPos, v0
   1:     mov r1, c1
   2:     mov r0, c3
   3:     if_lt c0.x, r1.x
   6:       mov r0, c2
   7:     endif
   8:     mov oT0.x, r0.x

// approximately 9 instruction slots used
