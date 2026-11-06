    ps_1_2
    texcoord t0
    texm3x3pad t1, t0
    texm3x3pad t2, t0
    texm3x3 t3, t0
    mov r0, t3

// approximately 5 instruction slots used (4 texture, 1 arithmetic)
