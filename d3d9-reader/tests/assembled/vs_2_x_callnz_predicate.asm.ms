    vs_2_x
    dcl_position v0
    mov oPos, v0
    mov r1, c1
    setp_gt p0.x, c0.x, r1.x
    mov r0, c2
    callnz l0, p0.x
    mov oT0, r0
    ret
    label l0
    add r0, r0, r0
    ret

// approximately 11 instruction slots used
