    ps_2_x
  + mov r0.xyz, v0
    mov r0, r0
    mov r0, r1
    mov r0, v0
    mov v0, r1
    mov r0, c0
    mov c0, r1
    mov r0, t0
    mov t0, r1
    mov r0, oD0
    mov oD0, r1
    mov r0, oT0
    mov oT0, r1
    mov r0, i0
    mov i0, r1
    mov r0, oC0
    mov oC0, r1
    mov r0, oDepth
    mov oDepth, r1
    mov r0, s0
    mov s0, r1
    mov r0, c2048
    mov c2048, r1
    mov r0, c4096
    mov c4096, r1
    mov r0, c6144
    mov c6144, r1
    mov r0, b0
    mov b0, r1
    mov r0, aL
    mov aL, r1
    mov r0, oPos
    mov oPos, r1
    mov r0, oFog
    mov oFog, r1
    mov r0, oPts
    mov oPts, r1
    mov r0, vPos
    mov vPos, r1
    mov r0, vFace
    mov vFace, r1
    mov r0, l0
    mov l0, r1
    mov r0, p0
    mov p0, r1
    dcl v0
    dcl_position1 v1
    dcl_blendweight v2
    dcl_blendweight1 v3
    dcl_blendindices v4
    dcl_blendindices1 v5
    dcl_normal v6
    dcl_normal1 v7
    dcl_psize v8
    dcl_psize1 v9
    dcl_texcoord v10
    dcl_texcoord1 v11
    dcl_tangent v12
    dcl_tangent1 v13
    dcl_binormal v14
    dcl_binormal1 v15
    dcl_tessfactor v16
    dcl_tessfactor1 v17
    dcl_positiont v18
    dcl_positiont1 v19
    dcl_color v20
    dcl_color1 v21
    dcl_fog v22
    dcl_fog1 v23
    dcl_depth v24
    dcl_depth1 v25
    dcl_sample v26
    dcl_sample1 v27
    mov_x2 r0, v0
    mov_x4 r0, v0
    mov_x8 r0, v0
    mov_d8 r0, v0
    mov_d4 r0, v0
    mov_d2 r0, v0
    mov r0[t0.x], v0
    mov r0, c0[t0.x]
    mov r0.xyz, v0
  + mov r1.w, v1
    (p0) mov r0, v0
    (!p0.x) add r0, v0, v1

// approximately 58 instruction slots used
