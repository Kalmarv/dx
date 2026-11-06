    vs_3_0
    dcl_position v0
    dcl_position o0
    dcl_texcoord o1
    mov o0, v0
    mov r1, c1
    mov r2, c2
    m4x4 r0, r1, c4
    mov o1, r0

// approximately 8 instruction slots used
