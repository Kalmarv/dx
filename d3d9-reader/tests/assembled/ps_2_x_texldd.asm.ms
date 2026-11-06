    ps_2_x
    dcl t0
    dcl_2d s0
    mov r1, c1
    mov r2, c2
    texldd r0, t0, s0, r1, r2
    mov oC0, r0

// approximately 6 instruction slots used (1 texture, 5 arithmetic)
