    ps_2_x
    defi i0, 10, 0, 0, 0
    def c3, 0, 0, 0, 0
    mov r0, c3
    mov r1, c1
    rep i0
      add r0, r0, c0
      setp_ge p0.x, r0.x, r1.x
      break p0.
    endrep
    mov oC0, r0

// approximately 13 instruction slots used
