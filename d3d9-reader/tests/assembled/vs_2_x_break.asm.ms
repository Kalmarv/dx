    vs_2_x
    def c2, 0, 0, 0, 0
    dcl_position v0
    mov oPos, v0
    mov r0, c2
    mov r1, c1
    rep i0
      break_ge r0.x, r1.x
      add r0, r0, c0
    endrep
    mov oT0.x, r0.x

// approximately 13 instruction slots used
