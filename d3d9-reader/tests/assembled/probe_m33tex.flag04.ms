    ps_1_1
   0:     tex t0
   0:     texm3x3pad t1, t0
   0:     texm3x3pad t2, t0
   0:     texm3x3tex t3, t0
   0:     mov r0, t3

// approximately 5 instruction slots used (4 texture, 1 arithmetic)
