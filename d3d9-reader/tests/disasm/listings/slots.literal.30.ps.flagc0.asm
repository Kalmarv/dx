    ps_3_0
    defi i0, 5, 0, 0, 0
    dcl_texcoord v0
    mov r0, v0
    rep i0
      mad r0, r0, r0.yzwx, c0
    endrep
    mov oC0.xyz, r0
    mov oC0.w, r0.w

// approximately 9 instruction slots used
