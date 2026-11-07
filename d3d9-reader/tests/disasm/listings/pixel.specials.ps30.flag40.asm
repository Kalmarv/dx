    ps_3_0
    def c6, 1.#INF, -1.#INF, 1.#QNAN, -1.#IND
    def c7, 1.#QNAN, -1.#QNAN, 1.#QNAN, -1.#QNAN
    def c8, 1.#QNAN, -1.#QNAN, 1.40129846e-045, -0
    dcl_texcoord v0
    dcl_texcoord1 v1.xyz
    dcl_color_centroid v2
    dcl_texcoord2 v3
    dcl vFace
    dcl vPos.xy
    dcl_2d s0
    dcl_cube s1
    dcl_volume s2
    dcl_2d s3
    dcl_2d s4
    cmp r0.x, vFace, c8.x, c8.y
    texld r1, v0, s0
    texldp r2, v3, s4
    add r1, r1, r2
    mul r2, c8.xxzx, v0.xyxw
    texldb r2, r2, s0
    add r1, r1, r2
    nrm r2.xyz, v1
    mad r0.yzw, r2.z, -c8.xzzw, r2.xxyz
    texld r2, r0.yzww, s1
    texld r3, v0, s2
    texld r4, v0.z, s3
    mul r3, r3, r4.x
    mad r1, r1, r2, r3
    dsx r0.yz, v0.xxyw
    dsy r2.xy, v0
    dp2add_sat r0.w, r0.yzzw, r2, c8.z
    lrp r3, r0.w, v2, r1
    texldd r1, v0.zwzw, s0, r0.yzzw, r2
    mad r2, v0.wzxw, c8.xxzz, c8.zzzw
    texldl r2, r2, s0
    add r1, r1, r2
    add r1, r1, r3
    add r2, r1.w, -c5.x
    texkill r2
    cmp r0.x, -r0.x, c6.x, c6.y
    mul r1.z, r0.x, r1.z
    mul r0.yz, c6.z, vPos.xxyw
    frc r0.yz, r0
    mad r1.xy, r1, r0.x, r0.yzzw
    mul_pp r0, r1, c6.x
    mad r0, r1, c4, r0
    mov r2.zw, c8.z
    mov r3, r0
    mov r4.x, c8.z
    rep i0
      add r5, r4.x, c7
      mov r4.z, c8.z
      cmp r4.y, -r5_abs.x, c0.x, r4.z
      cmp r4.y, -r5_abs.y, c1.x, r4.y
      cmp r4.y, -r5_abs.z, c2.x, r4.y
      cmp r4.y, -r5_abs.w, c3.x, r4.y
      if_lt r4.y, r3.x
        break_ne c8.x, -c8.x
      endif
      cmp r6, -r5_abs.x, c0, r4.z
      cmp r6, -r5_abs.y, c1, r6
      cmp r6, -r5_abs.z, c2, r6
      cmp r5, -r5_abs.w, c3, r6
      mul r2.xy, r4.x, v0
      texldl r6, r2, s0
      mad r3, r5, r6, r3
      add r4.x, r4.x, c8.x
    endrep
    mov oC0, r3
    log r0.x, r1_abs.x
    log r0.y, r1_abs.y
    log r0.z, r1_abs.z
    mul r0.xyz, r0, c6.w
    exp oC1.x, r0.x
    exp oC1.y, r0.y
    exp oC1.z, r0.z
    exp oC1.w, r1.w
    rcp r0.x, v3.w
    mul oDepth, r0.x, v3.z

// approximately 81 instruction slots used (11 texture, 70 arithmetic)
