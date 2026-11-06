    ps_2_x
   0:     mov r0, c0
   1:     mov r1, c1
   2:     if_gt r0.x, r1.x
   5:       mov r2, c2
   6:     else
   7:       mov r2, c3
   8:     endif
   9:     mov oC0, r2

// approximately 10 instruction slots used
