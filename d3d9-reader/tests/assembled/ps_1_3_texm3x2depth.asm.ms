    ps_1_3
    texcoord t0
    texm3x2pad t1, t0
    texm3x2depth t2, t0
    mov r0, c0

// approximately 4 instruction slots used (3 texture, 1 arithmetic)
