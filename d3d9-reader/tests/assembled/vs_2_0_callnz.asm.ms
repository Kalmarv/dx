    vs_2_0
    dcl_position v0
    mov oPos, v0
    mov r0, c0
    callnz l1, b0
    mov oT0, r0
    ret
    label l1
    add r0, r0, r0
    ret

// approximately 9 instruction slots used
