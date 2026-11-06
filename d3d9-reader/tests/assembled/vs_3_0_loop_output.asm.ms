    vs_3_0
    def c2, 1, 1, 1, 1
    dcl_position v0
    dcl_position o0
    dcl_texcoord o1
    dcl_texcoord1 o2
    mov o0, v0
    mov r0, c0
    loop aL, i0
      mov o0[aL], r0
      add r0, r0, c2
    endloop

// approximately 9 instruction slots used
