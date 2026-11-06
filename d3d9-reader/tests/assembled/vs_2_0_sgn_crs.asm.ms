    vs_2_0
    dcl_position v0
    mov oPos, v0
    mov r3, c0
    sgn r0, r3, r1, r2
    mov oT0, r0
    mov r4, c1
    crs r5.xyz, r4, c2
    mov oT1.xyz, r5

// approximately 10 instruction slots used
