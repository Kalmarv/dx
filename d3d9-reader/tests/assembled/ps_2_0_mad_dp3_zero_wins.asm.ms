    ps_2_0
    mov r1, c1
    mov r3, c2
    mad r0, c0, r1, r3
    dp3 r2.x, c0, r1
    mov r2.yzw, r3
    mov oC0, r0
    mov oC1, r2

// approximately 7 instruction slots used
