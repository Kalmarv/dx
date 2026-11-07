    ps_2_x
    def c2, 0x3f000000, 0x400ccccd, 0x00000000, 0x00000000
    def c3, 0x3f800000, 0x00000000, 0x80000000, 0xc0000000
    dcl t0
    dcl t1.xyz
    dcl v0
    dcl t2
    dcl_2d s0
    dcl_cube s1
    dcl_volume s2
    dcl_2d s3
    dcl_2d s4
    texldp r0, t2, s4.wwxx
    texld r1, t0, s0.x
    add r0, r0, r1
    mul r1, t0.xyxw, c3.xxyx
    mov r2.xy, t0.z
    nrm r3.xyz, t1
    mad r3.xyz, r3.z, c3.zzww, r3
    texldb r1, r1, s0.yzxw
    texld r3, r3, s1.wwxx
    add r0, r0, r1
    texld r1, t0, s2.x
    texld r2, r2, s3.yzxw
    mul r1, r1, r2.x
    mad r0, r0, r3, r1
    dsx r1.xy, t0
    dsy r1.zw, t0.xyxy
    dp2add_sat r1.x, r1, r1.zwzw, c3.y
    lrp r2, r1.x, v0, r0
    add r0, r2.w, -c1.x
    texkill r0
    exp r0.w, r2.w
    abs r1.xyz, r2
    log r3.x, r1.x
    log r3.y, r1.y
    log r3.z, r1.z
    mul r1.xyz, r3, c2.y
    exp r0.x, r1.x
    exp r0.y, r1.y
    exp r0.z, r1.z
    mov oC1, r0
    rcp r0.x, t2.w
    mul r0.x, r0.x, t2.z
    mov oDepth, r0.x
    mul_pp r0, r2, c2.x
    mad r0, r2, c0, r0
    add r1.x, -r0.y, c2.x
    rcp r1.y, r0.y
    cmp r0.z, r1.x, r0.z, r1.y
    mov oC0, r0

// approximately 44 instruction slots used (6 texture, 38 arithmetic)
