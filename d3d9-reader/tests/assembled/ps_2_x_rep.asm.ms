    ps_2_x
    defi i0, 3, 0, 0, 0
    def c2, 0, 0, 0, 0
    mov r0, c2
    rep i0
      add r0, r0, c0
    endrep
    mov oC0, r0

// approximately 8 instruction slots used
