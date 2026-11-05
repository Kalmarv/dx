    ps_3_0
    def c8, -4, -5, -6, -7
    def c9, 0, 1, 2, 3
    mov r0, c9.x
    mov r1.x, c9.x
    rep i0
      add r2, r1.x, -c9
      add r3, r1.x, c8
      mov r4.x, c9.x
      cmp r4, -r2_abs.x, c0, r4.x
      cmp r4, -r2_abs.y, c1, r4
      cmp r4, -r2_abs.z, c2, r4
      cmp r2, -r2_abs.w, c3, r4
      cmp r2, -r3_abs.x, c4, r2
      cmp r2, -r3_abs.y, c5, r2
      cmp r2, -r3_abs.z, c6, r2
      cmp r2, -r3_abs.w, c7, r2
      add r0, r0, r2
      add r1.x, r1.x, c9.y
    endrep
    mov oC0, r0

// approximately 21 instruction slots used
