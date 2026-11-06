    ps_3_0
    dcl_texcoord v0
    mov r1, c1
    mov r2, c2
    sincos r0.xy, c0.x
    mov r0.zw, c0
    mov oC0, r0

// approximately 12 instruction slots used
