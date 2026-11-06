    vs_2_x
    dcl_position v0
    mov oPos, v0
    mov r1, c1
    setp_gt p0, c0, r1
    mov r0, c3
    (p0) mov r0, c2
    mov oT0, r0

// approximately 7 instruction slots used
