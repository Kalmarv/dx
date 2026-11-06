    vs_2_0
    def c6, 1, 2, 0, 0
    dcl_position v0
    dcl_texcoord v1
    mul r0.x, v0.x, c4.x
    mul r0.y, v0.y, c4.y
    mov r0.x, r0.x
    mov r0.y, r0.y
    mul r0.zw, r0.x, c0.xyxy
    mul r1.xy, r0.x, c1
    add r1.z, r0.x, c6.x
    add r1.w, r0.y, c6.y
    mul r2, v0, c5
    add r2, r2, c3
    mul r0.z, r0.z, r0.x
    mul r0.w, r0.w, r0.y
    add r3.x, r0.w, r0.z
    mul r0.x, r0.x, r1.x
    mul r0.y, r0.y, r1.y
    add r3.y, r0.y, r0.x
    add r0.xy, r3, v1
    mul r0.z, r1.w, r1.z
    mov oPos, r2
    mov oT0.xy, r0
    mov oT1.x, r0.z

// approximately 21 instruction slots used
