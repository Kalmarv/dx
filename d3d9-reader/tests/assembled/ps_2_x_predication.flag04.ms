    ps_2_x
   0:     mov r1, c1
   1:     mov r3, c0
   2:     setp_gt p0, r3, r1
   3:     mov r0, c2
   4:     (!p0) mov r0, c3
   6:     mov oC0, r0

// approximately 7 instruction slots used
