    ps_2_x
    mov r1, c1
    setp_gt p0, c0, r1
    mov r0, c2
    callnz l0, p0.y
    mov oC0, r0
    ret
    label l0
    mov r0, c3
    ret

// approximately 10 instruction slots used
