    ps_3_0
    defi i0, 2, 0, 1, 0
    def c0, 0, 0, 0, 0
    dcl_texcoord v0
    dcl_texcoord1 v1
    mov r0, c0
    loop aL, i0
      add r0, r0, v0[aL]
    endloop
    mov oC0, r0

// approximately 8 instruction slots used
