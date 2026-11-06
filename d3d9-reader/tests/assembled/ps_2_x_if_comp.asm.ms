    ps_2_x
    mov r0, c0
    mov r1, c1
    if_gt r0.x, r1.x
      mov r2, c2
    else
      mov r2, c3
    endif
    mov oC0, r2

// approximately 10 instruction slots used
