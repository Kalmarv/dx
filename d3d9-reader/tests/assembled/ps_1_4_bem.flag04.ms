    ps_1_4
   0:     texcrd r1.xyz, t0
   0:     texcrd r2.xyz, t1
   0:     bem r0.xy, r1, r2
   1:     phase
   1:     mov r0.zw, c0

// approximately 4 instruction slots used (2 texture, 2 arithmetic)
