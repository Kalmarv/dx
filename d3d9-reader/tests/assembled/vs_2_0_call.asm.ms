    vs_2_0
    dcl_position v0
    mov oPos, v0
    mov r0, c0
    call l0
    mov oT0, r0
    call l0
    mov oT1, r0
    ret
    label l0
    add r0, r0, r0
    ret

// approximately 11 instruction slots used
