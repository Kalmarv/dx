    ps_3_0
    def c1, 0, 0, 0, 0
    dcl_color v0
    mov r0, c1.x
    rep i0
      add r0, r0, v0
    endrep
    mul oC0, r0, c0.y

// approximately 8 instruction slots used
