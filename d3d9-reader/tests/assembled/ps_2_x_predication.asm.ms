    ps_2_x
    mov r1, c1
    mov r3, c0
    setp_gt p0, r3, r1
    mov r0, c2
    (!p0) mov r0, c3
    mov oC0, r0

// approximately 7 instruction slots used
