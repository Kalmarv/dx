    vs_3_0
    dcl_position v0
    dcl_position o0
    dcl_texcoord o1
    mov o0, v0
    mov r1, c1
    mov r2, c2
    mova a0.x, c0.x
    mov r0, c0[a0.x]
    mov o1, r0

// approximately 6 instruction slots used
