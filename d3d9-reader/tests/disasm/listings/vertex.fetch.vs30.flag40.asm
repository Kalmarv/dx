    vs_3_0
    def c72, 3, 0, 1, 2
    def c73, 0.159154937, 0.5, 6.28318548, -3.14159274
    def c74, 1.44269502, 1, 0, 0.693147182
    def c75, 0.00999999978, 0.25, 0, 0
    dcl_position v0
    dcl_normal v1
    dcl_texcoord v2
    dcl_blendweight v3
    dcl_blendindices v4
    dcl_2d s0
    dcl_position o0
    dcl_color o1
    dcl_texcoord o2.xy
    dcl_texcoord1 o3.xyz
    dcl_fog o4.x
    dcl_texcoord2 o5
    mul r0, c72.zzyy, v2.xyxx
    texldl r0, r0, s0
    mul r0.yz, c72.x, v4.xxyw
    mova a0.xy, r0.zyzw
    mul r1, v0.y, c1[a0.x]
    mad r1, v0.x, c0[a0.x], r1
    mad r1, v0.z, c2[a0.x], r1
    mad r1, v0.w, c72.yyyz, r1
    mul r1, r1, v3.y
    mul r2, v0.y, c1[a0.y]
    mad r2, v0.x, c0[a0.y], r2
    mad r2, v0.z, c2[a0.y], r2
    mad r2, v0.w, c72.yyyz, r2
    mad r1, r2, v3.x, r1
    add r1.y, r0.x, r1.y
    dp4 o0.x, r1, c59
    dp4 o0.y, r1, c60
    dp4 o0.z, r1, c61
    dp4 o0.w, r1, c62
    mul r0.xyz, r1.y, c64
    mad r0.xyz, r1.x, c63, r0
    mad r0.xyz, r1.z, c65, r0
    mad r0.xyz, r1.w, c66, r0
    dp3 r1.x, v1, c67
    dp3 r1.y, v1, c68
    dp3 r1.z, v1, c69
    nrm r2.xyz, r1
    dp3_sat r0.w, r2, -c48
    mul r0.w, r0.w, r0.w
    mul r0.w, r0.w, r0.w
    mul r0.w, r0.w, r0.w
    mul r1, r0.w, c49
    dp3_sat r0.w, r2, -c50
    mul r0.w, r0.w, r0.w
    mul r0.w, r0.w, r0.w
    mul r0.w, r0.w, r0.w
    mul r3, r0.w, c51
    mov r4.y, c72.y
    slt r0.w, r4.y, c70.x
    slt r2.w, r0.w, c70.x
    mul r3, r3, r2.w
    mad r1, r0.w, r1, r3
    lrp r3.x, r2.w, c72.w, r0.w
    slt r0.w, r3.x, c70.x
    mul r0.w, r0.w, r2.w
    dp3_sat r2.w, r2, -c52
    mul r2.w, r2.w, r2.w
    mul r2.w, r2.w, r2.w
    mul r2.w, r2.w, r2.w
    mul r3, r2.w, c53
    mad r1, r0.w, r3, r1
    mad r3, r1.xyzx, c74.yyyz, c74.zzzw
    add r1.xy, r0_abs.yzzw, c72.z
    log r0.w, r1.x
    rsq r4.w, r1.y
    mul r1.w, r0.w, r1.w
    mov r5.xy, c73
    mad r0.w, c90.x, r5.x, r5.y
    frc r0.w, r0.w
    mad r0.w, r0.w, c73.z, c73.w
    sincos r5.xy, r0.w
    mov r1.xy, r5.yxzw
    lrp r6.y, r0.x, r5.x, r5.y
    mul r0.w, r0.x, c74.x
    exp r1.z, r0.w
    mul o1, r1, r3
    dp3 r0.w, r0, r0
    rsq r0.w, r0.w
    rcp r0.w, r0.w
    mul r0.w, r0.w, c71.x
    mul o4.x, r0.w, c75.x
    slt r0.w, -r0.z, r0.z
    slt r1.x, r0.z, -r0.z
    add r6.x, r0.w, -r1.x
    frc r0.w, c90.x
    mad r1.xy, v2, r0.w, r6
    mul r1.zw, r1.xyxy, c57.xyxy
    mul r1.xy, r1, c58
    add o2.xy, r1.wyzw, r1.zxzw
    mul r1.xyz, r0.zxyw, r2.yzxw
    mad r4.xyz, r0.yzxw, r2.zxyw, -r1
    dp3 r0.x, c55, r0
    mul r0, r0.x, c56
    mad r0, r4, c54, r0
    mov o3.xyz, r2
    min r1, r0.wzyx, c72.z
    max r1, r0, r1
    sge r2, r0, c73.y
    slt r0, c73.y, r0
    mad r0, r1, r2, r0
    rcp r1.x, r0.x
    add r1.x, -r0.y, r1.x
    slt r1.y, c75.y, r0.x
    mad o5.y, r1.y, r1.x, r0.y
    mov o5.xzw, r0

// approximately 105 instruction slots used (2 texture, 103 arithmetic)
