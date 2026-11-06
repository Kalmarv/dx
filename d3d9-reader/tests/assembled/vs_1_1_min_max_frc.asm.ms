    vs_1_1
    dcl_position v0
    mov oPos, v0
    mov r1, c1
    min oT0, c0, r1
    max oT1, c0, r1
    frc r0.xy, c0
    mov oT2.xy, r0

// approximately 8 instruction slots used
