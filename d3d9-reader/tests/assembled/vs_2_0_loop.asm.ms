    vs_2_0
    def c0, 0, 0, 0, 0
    dcl_position v0
    mov oPos, v0
    mov r0, c0
    loop aL, i0
      add r0, r0, c0[aL]
    endloop
    mov oT0.x, r0.x

// approximately 9 instruction slots used
