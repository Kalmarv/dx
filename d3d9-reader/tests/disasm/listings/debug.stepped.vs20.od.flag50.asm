    vs_2_0
    dcl_position v0
    mul r0, v0.yzwx, c0.yzwx
    nop
    mov r0, r0
    add r0, r0, c3
    mov r0, r0
    nop
    mov r0, r0
    mul r0, r0, c2.zwxy
    mov r0, r0
    add r0, r0, c1.yzwx
    mul r0, r0, c1.zwxy
    mov r1, -c0.wxyz
    add r0, r0, r1
    nop
    mov r0, r0
    mul r0, r0.wxyz, r0
    mov r0, r0
    mul r0, r0, c2
    add r0, r0, c3
    mov oPos, r0

// approximately 17 instruction slots used
