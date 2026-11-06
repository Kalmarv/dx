    ps_3_0
    dcl_texcoord v0
    dcl_volume s0
    mov r1, c1
    mov r2, c2
    texldd r0, v0, s0, r1, r2
    mov oC0, r0

// approximately 6 instruction slots used (1 texture, 5 arithmetic)
