    ps_3_0
    def c3, 0x3f000000, 0x00000000, 0x00000000, 0x00000000
    dcl_texcoord v0
    mov r0, c1
    mad r0, v0, r0, c2
    add r1.x, c3.x, -v0.x
    cmp oC0, r1.x, v0, r0

// approximately 4 instruction slots used
