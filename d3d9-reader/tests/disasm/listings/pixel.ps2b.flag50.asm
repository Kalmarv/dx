    ps_2_x
    def c2, 0.5, 2.20000005, 0, 0
    def c3, 0, -2, -0, -0
    dcl t0
    dcl t1.xyz
    dcl t2
    dcl_2d s0
    dcl_cube s1
    dcl_volume s2
    dcl_2d s3
    dcl_2d s4
    mov r0.xyw, t0
    mov r0.z, c3.x
    mov r1.xy, t0.z
    nrm r2.xyz, t1
    mad r2.xyz, r2.z, c3.wzyx, r2
    texld r3, t0, s0
    texldp r4, t2, s4
    texldb r0, r0, s0
    texld r1, r1, s3
    texld r5, t0, s2
    texld r2, r2, s1
    add r3, r3, r4
    add r0, r0, r3
    mul r1, r1.x, r5
    mad r0, r0, r2, r1
    add r1, r0.w, -c1.x
    texkill r1
    mul_pp r1, r0, c2.x
    mad r1, r0, c0, r1
    add r2.x, -r1.y, c2.x
    rcp r2.y, r1.y
    cmp r1.z, r2.x, r1.z, r2.y
    mov oC0, r1
    exp r1.w, r0.w
    abs r0.xyz, r0
    log r2.x, r0.x
    log r2.y, r0.y
    log r2.z, r0.z
    mul r0.xyz, r2, c2.y
    exp r1.x, r0.x
    exp r1.y, r0.y
    exp r1.z, r0.z
    mov oC1, r1
    rcp r0.x, t2.w
    mul r0.x, r0.x, t2.z
    mov oDepth, r0.x

// approximately 38 instruction slots used (6 texture, 32 arithmetic)
