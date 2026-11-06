    ps_3_0
    def c2, 0x3f000000, 0x3f800000, 0x3e000000, 0x400ccccd
    def c3, 0x3f800000, 0xbf800000, 0x00000000, 0x40000000
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
    texld r0, v0, s0
    texldp r1, v3, s4
    add r0, r0, r1
    mul r1, c3.xxzx, v0.xyxw
    texldb r1, r1, s0
    add r0, r0, r1
    nrm r1.xyz, v1
    mad r1.xyz, r1.z, -c3.zzww, r1
    texld r1, r1, s1
    texld r2, v0, s2
    texld r3, v0.z, s3
    mul r2, r2, r3.x
    mad r0, r0, r1, r2
    dsx r1.xy, v0
    dsy r1.zw, v0.xyxy
    dp2add_sat r2.x, r1, r1.zwzw, c3.z
    texldd r1, v0.zwzw, s0, r1, r1.zwzw
    lrp r3, r2.x, v2, r0
    mad r0, v0.wzxw, c3.xxzz, c3.zzzw
    texldl r0, r0, s0
    add r0, r0, r1
    add r0, r0, r3
    add r1, r0.w, -c1.x
    texkill r1
    cmp r1.x, vFace, c3.x, c3.y
    cmp r1.x, -r1.x, c2.x, c2.y
    mul r0.z, r0.z, r1.x
    mul r1.yz, c2.z, vPos.xxyw
    frc r1.yz, r1
    mad r0.xy, r0, r1.x, r1.yzzw
    exp oC1.w, r0.w
    mul_pp r1, r0, c2.x
    mad r1, r0, c0, r1
    log r2.z, r0_abs.z
    add r0.z, -r1.y, c2.x
    rcp r0.w, r1.y
    cmp oC0.z, r0.z, r1.z, r0.w
    mov oC0.xyw, r1
    log r2.x, r0_abs.x
    log r2.y, r0_abs.y
    mul r0.xyz, r2, c2.w
    exp oC1.x, r0.x
    exp oC1.y, r0.y
    exp oC1.z, r0.z
    rcp r0.x, v3.w
    mul oDepth, r0.x, v3.z

// approximately 54 instruction slots used (9 texture, 45 arithmetic)
