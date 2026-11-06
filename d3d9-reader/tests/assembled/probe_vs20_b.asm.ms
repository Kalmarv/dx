    vs_2_0
    dcl_position v0
    mov r9, c1
    frc r4, c0
    min r5, c0, r9
    max r6, c0, r9
    exp r0, c0.x
    log r1, c0.x
    mov oPos, v0
    mov oT0, r4
    mov oT1, r5
    mov oT2, r6
    mov oT3, r0
    mov oT4, r1

// approximately 12 instruction slots used
