    vs_1_1
    dcl_position v0
    mov oPos, v0
    expp r0, c0.x
    mov oT0.xy, r0
    mov oT1.x, r0.w
    logp r1, c0.y
    mov oT2.xy, r1
    mov oT3.x, r1.w

// approximately 7 instruction slots used
