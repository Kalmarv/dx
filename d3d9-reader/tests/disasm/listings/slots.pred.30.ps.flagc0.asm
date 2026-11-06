    ps_3_0
    def c8, 0xc0800000, 0xc0a00000, 0xc0c00000, 0xc0e00000
    def c9, 0x00000000, 0x3f800000, 0x40000000, 0x40400000
    dcl_texcoord v0
    mov r0, v0
    mov r1.x, c9.x
    rep i0
      add r2, r1.x, -c9
      add r3, r1.x, c8
      mov r4.x, c9.x
      cmp r1.y, -r2_abs.x, c0.x, r4.x
      cmp r1.y, -r2_abs.y, c1.x, r1.y
      cmp r1.y, -r2_abs.z, c2.x, r1.y
      cmp r1.y, -r2_abs.w, c3.x, r1.y
      cmp r1.y, -r3_abs.x, c4.x, r1.y
      cmp r1.y, -r3_abs.y, c5.x, r1.y
      cmp r1.y, -r3_abs.z, c6.x, r1.y
      cmp r1.y, -r3_abs.w, c7.x, r1.y
      if_lt r1.y, r0.x
        break_ne c9.y, -c9.y
      endif
      cmp r4, -r2_abs.x, c0, r4.x
      cmp r4, -r2_abs.y, c1, r4
      cmp r4, -r2_abs.z, c2, r4
      cmp r2, -r2_abs.w, c3, r4
      cmp r2, -r3_abs.x, c4, r2
      cmp r2, -r3_abs.y, c5, r2
      cmp r2, -r3_abs.z, c6, r2
      cmp r2, -r3_abs.w, c7, r2
      add r0, r2, r0
      add r1.x, r1.x, c9.y
    endrep
    mov oC0.yzw, r0
    mov oC0.x, r0.x

// approximately 37 instruction slots used
