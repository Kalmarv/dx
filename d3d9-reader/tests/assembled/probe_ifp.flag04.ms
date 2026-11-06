    ps_2_x
   0:     mov r1, c1
   1:     setp_gt p0, c0, r1
   2:     mov r0, c2
   3:     if p0.x
   6:       mov r0, c3
   7:     endif
   8:     mov oC0, r0

// approximately 9 instruction slots used
