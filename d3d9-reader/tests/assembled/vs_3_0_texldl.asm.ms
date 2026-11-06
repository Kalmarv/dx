    vs_3_0
    dcl_position v0
    dcl_position o0
    dcl_texcoord o1
    dcl_2d s0
    mov o0, v0
    mov r0, c0
    texldl o1, r0, s0

// approximately 4 instruction slots used (2 texture, 2 arithmetic)
