    ps_1_1
    tex t0
    texm3x3pad t1, t0
    texm3x3pad t2, t0
    texm3x3spec t3, t0, c0
    mov r0, t3

// approximately 5 instruction slots used (4 texture, 1 arithmetic)
