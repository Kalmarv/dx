    ps_3_0
          def c2, 0.5, 1, 0.125, 2.20000005
          def c3, 1, -1, 0, 2
          dcl_texcoord_pp v0
          dcl_texcoord1_pp v1.xyz
          dcl_color_pp_centroid v2
          dcl_texcoord2_pp v3
          dcl vFace
          dcl vPos.xy
          dcl_2d s0
          dcl_cube s1
          dcl_volume s2
          dcl_2d s3
          dcl_2d s4
   0:     texld_pp r0, v0, s0
   0:     texldp_pp r1, v3, s4
   0:     add_pp r0, r0, r1
   1:     mul_pp r1, c3.xxzx, v0.xyxw
   2:     texldb_pp r1, r1, s0
   2:     add_pp r0, r0, r1
   3:     nrm_pp r1.xyz, v1
   6:     mad_pp r1.xyz, r1.z, -c3.zzww, r1
   7:     texld_pp r1, r1, s1
   7:     texld_pp r2, v0, s2
   7:     texld_pp r3, v0.z, s3
   7:     mul_pp r2, r2, r3.x
   8:     mad_pp r0, r0, r1, r2
   9:     dsx_pp r1.xy, v0
  11:     dsy_pp r1.zw, v0.xyxy
  13:     dp2add_sat_pp r2.x, r1, r1.zwzw, c3.z
  15:     texldd_pp r1, v0.zwzw, s0, r1, r1.zwzw
  17:     lrp_pp r3, r2.x, v2, r0
  18:     mad_pp r0, v0.wzxw, c3.xxzz, c3.zzzw
  19:     texldl_pp r0, r0, s0
  19:     add_pp r0, r0, r1
  20:     add_pp r0, r0, r3
  21:     add_pp r1, r0.w, -c1.x
  22:     texkill r1
  23:     cmp_pp r1.x, vFace, c3.x, c3.y
  24:     cmp_pp r1.x, -r1.x, c2.x, c2.y
  25:     mul_pp r0.z, r0.z, r1.x
  26:     mul_pp r1.yz, c2.z, vPos.xxyw
  27:     frc_pp r1.yz, r1
  28:     mad_pp r0.xy, r0, r1.x, r1.yzzw
  29:     exp_pp oC1.w, r0.w
  30:     mul_pp r1, r0, c2.x
  31:     mad_pp r1, r0, c0, r1
  32:     log_pp r2.z, r0_abs.z
  33:     add_pp r0.z, -r1.y, c2.x
  34:     rcp_pp r0.w, r1.y
  35:     cmp_pp oC0.z, r0.z, r1.z, r0.w
  36:     mov_pp oC0.xyw, r1
  37:     log_pp r2.x, r0_abs.x
  38:     log_pp r2.y, r0_abs.y
  39:     mul_pp r0.xyz, r2, c2.w
  40:     exp_pp oC1.x, r0.x
  41:     exp_pp oC1.y, r0.y
  42:     exp_pp oC1.z, r0.z
  43:     rcp_pp r0.x, v3.w
  44:     mul_pp oDepth, r0.x, v3.z

// approximately 54 instruction slots used (9 texture, 45 arithmetic)
