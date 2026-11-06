    ps_2_x
    mov r0, c0
    call l0
    call l0
    mov oC0, r0
    ret
    label l0
    add r0, r0, r0
    ret

// approximately 9 instruction slots used
