    ps_1_1
    texcoord t0
    texm3x2pad t1, t0
    texm3x2tex t2, t0
    mov r0, t2

// approximately 4 instruction slots used (3 texture, 1 arithmetic)
