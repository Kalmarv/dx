    ps_2_0
    def c1, 0xbf000000, 0x3f800000, 0x00000000, 0x00000000
    dcl t0.xy
    dcl v0
    dcl_2d s0
    dcl_cube s1
    texld r0, t0, s0
    mad r1, r0.w, v0.w, c1.x
    mul r0, r0, v0
    mov r2.xy, t0
    mov r2.z, c1.y
    texkill r1
    texld r1, r2, s1
    mad r0, r0, c0, r1
    mov oC0, r0

// approximately 9 instruction slots used (2 texture, 7 arithmetic)
