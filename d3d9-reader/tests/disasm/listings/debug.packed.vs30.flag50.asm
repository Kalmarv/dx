    vs_3_0
    def c6, 1, 2, 0, 0
    dcl_position v0
    dcl_texcoord v1
    dcl_position o0
    dcl_texcoord o1.xy
    dcl_texcoord1 o2.x
    mov r0, c5
    mad o0, v0, r0, c3
    mul r0.xy, c4, v0
    mul r1.y, r0.x, c0.y
    mul r1.z, r0.x, c1.y
    mul r0.yz, r0.y, r1
    mul r0.x, r0.x, r0.x
    mad r1.x, c0.x, r0.x, r0.y
    mad r1.y, c1.x, r0.x, r0.z
    add o1.xy, r1, v1
    mov r0.xy, c4
    mad r0.xy, v0, r0, c6
    mul o2.x, r0.y, r0.x

// approximately 13 instruction slots used
