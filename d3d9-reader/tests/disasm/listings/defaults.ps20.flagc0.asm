    ps_2_0
    dcl v0
    dcl t0.xy
    dcl_2d s0
    texld r0, t0, s0
    mov r1, c7
    add r1, r1, c8
    dp4 r2.x, v0, c0
    dp4 r2.y, v0, c1
    dp4 r2.z, v0, c2
    dp4 r2.w, v0, c3
    add r1, r1, r2
    add r1, r1, c5.x
    add r1, r1, c6.x
    add r1, r1, c31
    add r2.xyz, r1, c9
    add r2.w, r1.w, c9.z
    add r0, r0, r2
    mov oC0, r0

// approximately 15 instruction slots used (1 texture, 14 arithmetic)
