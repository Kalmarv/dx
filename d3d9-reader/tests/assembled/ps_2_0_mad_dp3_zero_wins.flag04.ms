    ps_2_0
   0:     mov r1, c1
   1:     mov r3, c2
   2:     mad r0, c0, r1, r3
   3:     dp3 r2.x, c0, r1
   4:     mov r2.yzw, r3
   5:     mov oC0, r0
   6:     mov oC1, r2

// approximately 7 instruction slots used
