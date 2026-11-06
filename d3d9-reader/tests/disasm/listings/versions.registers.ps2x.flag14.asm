    ps_2_x
        + mov r0.xyz, v0
   1:     mov r0, r0
   2:     mov r0, r1
   3:     mov r0, v0
   4:     mov v0, r1
   5:     mov r0, c0
   6:     mov c0, r1
   7:     mov r0, t0
   8:     mov t0, r1
   9:     mov r0, oD0
  10:     mov oD0, r1
  11:     mov r0, oT0
  12:     mov oT0, r1
  13:     mov r0, i0
  14:     mov i0, r1
  15:     mov r0, oC0
  16:     mov oC0, r1
  17:     mov r0, oDepth
  18:     mov oDepth, r1
  19:     mov r0, s0
  20:     mov s0, r1
  21:     mov r0, c2048
  22:     mov c2048, r1
  23:     mov r0, c4096
  24:     mov c4096, r1
  25:     mov r0, c6144
  26:     mov c6144, r1
  27:     mov r0, b0
  28:     mov b0, r1
  29:     mov r0, aL
  30:     mov aL, r1
  31:     mov r0, oPos
  32:     mov oPos, r1
  33:     mov r0, oFog
  34:     mov oFog, r1
  35:     mov r0, oPts
  36:     mov oPts, r1
  37:     mov r0, vPos
  38:     mov vPos, r1
  39:     mov r0, vFace
  40:     mov vFace, r1
  41:     mov r0, l0
  42:     mov l0, r1
  43:     mov r0, p0
  44:     mov p0, r1
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
  45:     mov_x2 r0, v0
  46:     mov_x4 r0, v0
  47:     mov_x8 r0, v0
  48:     mov_d8 r0, v0
  49:     mov_d4 r0, v0
  50:     mov_d2 r0, v0
  51:     mov r0[t0.x], v0
  52:     mov r0, c0[t0.x]
  53:     mov r0.xyz, v0
        + mov r1.w, v1
  54:     (p0) mov r0, v0
  56:     (!p0.x) add r0, v0, v1

// approximately 58 instruction slots used
