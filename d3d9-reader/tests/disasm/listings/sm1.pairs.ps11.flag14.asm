    ps_1_1
   0:     tex t0
   0:     tex t1
   0:     mul r0.xyz, t0, v0
        + mul_x2 r0.w, t1, v0
   1:     add r0.xyz, r0, t1
        + add_sat r0.w, r0, c0
   2:     mov r1, r0

// approximately 5 instruction slots used (2 texture, 3 arithmetic)
