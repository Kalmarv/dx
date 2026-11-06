    vs_3_0
    def c3, 0, 1, 0, 0
    dcl_position v0
    dcl_position o0
    mov r0, v0
    mov r1.x, c3.x
    rep i0
      mad r0, c2, r1.x, r0
      add r1.x, r1.x, c3.y
    endrep
    if b0
      mov o0, -r0
    else
      mov o0, r0
    endif

// approximately 16 instruction slots used
