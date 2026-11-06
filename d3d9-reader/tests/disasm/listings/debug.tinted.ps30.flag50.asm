    ps_3_0
    dcl_texcoord v0.xy
    dcl_2d s0
    texld r0, v0, s0
    mov r1, c0
    mad oC0, r0, r1, c1

// approximately 3 instruction slots used (1 texture, 2 arithmetic)
