    vs_2_x
    dcl_position v0
    mov oPos, v0
    mov r1, c1
    mov r0, c3
    if_lt c0.x, r1.x
      mov r0, c2
    endif
    mov oT0.x, r0.x

// approximately 9 instruction slots used
