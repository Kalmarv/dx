    ps_3_0
          def c2, 0.5, 1, 0.125, 2.20000005
          def c3, 1, -1, 0, 2
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
   0:     texld r0, v0, s0
   0:     texldp r1, v3, s4
   0:     add r0, r0, r1
   1:     mul r1, c3.xxzx, v0.xyxw
   2:     texldb r1, r1, s0
   2:     add r0, r0, r1
   3:     nrm r1.xyz, v1
   6:     mad r1.xyz, r1.z, -c3.zzww, r1
   7:     texld r1, r1, s1
   7:     texld r2, v0, s2
   7:     texld r3, v0.z, s3
   7:     mul r2, r2, r3.x
   8:     mad r0, r0, r1, r2
   9:     dsx r1.xy, v0
  11:     dsy r1.zw, v0.xyxy
  13:     dp2add_sat r2.x, r1, r1.zwzw, c3.z
  15:     texldd r1, v0.zwzw, s0, r1, r1.zwzw
  17:     lrp r3, r2.x, v2, r0
  18:     mad r0, v0.wzxw, c3.xxzz, c3.zzzw
  19:     texldl r0, r0, s0
  19:     add r0, r0, r1
  20:     add r0, r0, r3
  21:     add r1, r0.w, -c1.x
  22:     texkill r1
  23:     cmp r1.x, vFace, c3.x, c3.y
  24:     cmp r1.x, -r1.x, c2.x, c2.y
  25:     mul r0.z, r0.z, r1.x
  26:     mul r1.yz, c2.z, vPos.xxyw
  27:     frc r1.yz, r1
  28:     mad r0.xy, r0, r1.x, r1.yzzw
  29:     exp oC1.w, r0.w
  30:     mul_pp r1, r0, c2.x
  31:     mad r1, r0, c0, r1
  32:     log r2.z, r0_abs.z
  33:     add r0.z, -r1.y, c2.x
  34:     rcp r0.w, r1.y
  35:     cmp oC0.z, r0.z, r1.z, r0.w
  36:     mov oC0.xyw, r1
  37:     log r2.x, r0_abs.x
  38:     log r2.y, r0_abs.y
  39:     mul r0.xyz, r2, c2.w
  40:     exp oC1.x, r0.x
  41:     exp oC1.y, r0.y
  42:     exp oC1.z, r0.z
  43:     rcp r0.x, v3.w
  44:     mul oDepth, r0.x, v3.z

// approximately 54 instruction slots used (9 texture, 45 arithmetic)
