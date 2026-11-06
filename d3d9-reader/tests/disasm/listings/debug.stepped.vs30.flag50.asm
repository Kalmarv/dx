    vs_3_0
    dcl_position v0
    dcl_position o0
    mov r0, c0
    mad r1, v0.yzwx, r0.yzwx, c3
    mov r2, c2
    mad r1, r1, r2.zwxy, c1.yzwx
    mad r0, r1, c1.zwxy, -r0.wxyz
    mul r0, r0.wxyz, r0
    mad o0, r0, r2, c3

// approximately 7 instruction slots used
