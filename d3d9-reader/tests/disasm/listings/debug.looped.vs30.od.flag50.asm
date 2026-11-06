    vs_3_0
    def c4, 0, 0, 1, 0
    defi i0, 255, 0, 0, 0
    dcl_position v0
    dcl_position o0
    mov r0, v0
    mov r1.x, c4.x
    mov r2, r0
    mov r1.y, r1.x
    rep i0
      slt r1.z, r1.y, c3.x
      mov r1.w, -r1.z
      sge r1.z, r1.w, r1.z
      break_ne r1.z, -r1.z
      mul r3, r1.y, c2
      add r2, r2, r3
      add r1.y, r1.y, c4.z
    endrep
    if b0
      mov r2, -r2
    endif
    mov o0, r2

// approximately 24 instruction slots used
