    vs_1_1
    dcl_position v0
    exp r0, c0.x
    log r1, c0.x
    lit r2, c1
    mov r5, c1
    dst r3, c0, r5
    m4x4 oPos, v0, c4
    mov oT0, r0
    mov oT1, r1
    mov oT2, r2
    mov oT3, r3

// approximately 31 instruction slots used
