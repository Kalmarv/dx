    ps_3_0
    def c10, 1, 0, 0, 0
    dcl_color v0
    dcl_texcoord v1.xy
    dcl_2d s0
    mov r0, c7
    add r0, r0, c8
    dp4 r1.x, v0, c0
    dp4 r1.y, v0, c1
    dp4 r1.z, v0, c2
    dp4 r1.w, v0, c3
    add r0, r0, r1
    add r0, r0, c5.x
    add r0, r0, c6.x
    add r0, r0, c123
    add r0, r0, c9.xyzz
    mov r1, r0
    rep i0
      add r1, r1, v0
    endrep
    if b0
      add r1, r1, r1
    endif
    if b2
      add r1, r1, c10.x
    endif
    texld r0, v1, s0
    add oC0, r0, r1

// approximately 30 instruction slots used (1 texture, 29 arithmetic)
