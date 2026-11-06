    vs_3_0
    dcl_position v0
    dcl_position o0
    dcl_texcoord o1
    mov o0, v0
    mov r1, c1
    mov r2, c2
    crs r0.xyz, c0, r1
    mov o1, r0

// approximately 6 instruction slots used
