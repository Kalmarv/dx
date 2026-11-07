    ps_3_0
0x0000018C:     def c2 {min16f}, 0.5, 1, 0.125, 2.20000005
0x000001A4:     def c3 {min2_8f}, 1, -1, 0, 2
0x000001BC:     dcl_texcoord v0
0x000001C8:     dcl_texcoord1 v1.xyz {min16f}
0x000001D4:     dcl_color_centroid v2 {min2_8f}
0x000001E0:     dcl_texcoord2 v3
0x000001EC:     dcl vFace {min16f}
0x000001F8:     dcl vPos.xy {min2_8f}
0x00000204:     dcl_2d s0
0x00000210:     dcl_cube s1 {min16f}
0x0000021C:     dcl_volume s2 {min2_8f}
0x00000228:     dcl_2d s3
0x00000234:     dcl_2d s4 {min16f}
0x00000240:     texld r0 {min2_8f}, v0, s0 {min16f}
0x00000250:     texldp r1 {min2_8f}, v3, s4 {min16f}
0x00000260:     add r0 {min2_8f}, r0, r1 {min16f}
0x00000270:     mul r1 {min2_8f}, c3.xxzx, v0.xyxw {min16f}
0x00000280:     texldb r1 {min2_8f}, r1, s0 {min16f}
0x00000290:     add r0 {min2_8f}, r0, r1 {min16f}
0x000002A0:     nrm r1.xyz {min2_8f}, v1
0x000002AC:     mad r1.xyz {min16f}, r1.z {min2_8f}, -c3.zzww, r1 {min16f}
0x000002C0:     texld r1 {min2_8f}, r1, s1 {min16f}
0x000002D0:     texld r2 {min2_8f}, v0, s2 {min16f}
0x000002E0:     texld r3 {min2_8f}, v0.z, s3 {min16f}
0x000002F0:     mul r2 {min2_8f}, r2, r3.x {min16f}
0x00000300:     mad r0 {min2_8f}, r0, r1 {min16f}, r2 {min2_8f}
0x00000314:     dsx r1.xy, v0 {min16f}
0x00000320:     dsy r1.zw {min2_8f}, v0.xyxy
0x0000032C:     dp2add_sat r2.x {min16f}, r1 {min2_8f}, r1.zwzw, c3.z {min16f}
0x00000340:     texldd r1 {min2_8f}, v0.zwzw, s0 {min16f}, r1 {min2_8f}, r1.zwzw
0x00000358:     lrp r3 {min16f}, r2.x {min2_8f}, v2, r0 {min16f}
0x0000036C:     mad r0 {min2_8f}, v0.wzxw, c3.xxzz {min16f}, c3.zzzw {min2_8f}
0x00000380:     texldl r0, r0 {min16f}, s0 {min2_8f}
0x00000390:     add r0, r0 {min16f}, r1 {min2_8f}
0x000003A0:     add r0, r0 {min16f}, r3 {min2_8f}
0x000003B0:     add r1, r0.w {min16f}, -c1.x {min2_8f}
0x000003C0:     texkill r1
0x000003C8:     cmp r1.x {min16f}, vFace {min2_8f}, c3.x, c3.y {min16f}
0x000003DC:     cmp r1.x {min2_8f}, -r1.x, c2.x {min16f}, c2.y {min2_8f}
0x000003F0:     mul r0.z, r0.z {min16f}, r1.x {min2_8f}
0x00000400:     mul r1.yz, c2.z {min16f}, vPos.xxyw {min2_8f}
0x00000410:     frc r1.yz, r1 {min16f}
0x0000041C:     mad r0.xy {min2_8f}, r0, r1.x {min16f}, r1.yzzw {min2_8f}
0x00000430:     exp oC1.w, r0.w {min16f}
0x0000043C:     mul_pp r1 {min2_8f}, r0, c2.x {min16f}
0x0000044C:     mad r1 {min2_8f}, r0, c0 {min16f}, r1 {min2_8f}
0x00000460:     log r2.z, r0_abs.z {min16f}
0x0000046C:     add r0.z {min2_8f}, -r1.y, c2.x {min16f}
0x0000047C:     rcp r0.w {min2_8f}, r1.y
0x00000488:     cmp oC0.z {min16f}, r0.z {min2_8f}, r1.z, r0.w {min16f}
0x0000049C:     mov oC0.xyw {min2_8f}, r1
0x000004A8:     log r2.x {min16f}, r0_abs.x {min2_8f}
0x000004B4:     log r2.y, r0_abs.y {min16f}
0x000004C0:     mul r0.xyz {min2_8f}, r2, c2.w {min16f}
0x000004D0:     exp oC1.x {min2_8f}, r0.x
0x000004DC:     exp oC1.y {min16f}, r0.y {min2_8f}
0x000004E8:     exp oC1.z, r0.z {min16f}
0x000004F4:     rcp r0.x {min2_8f}, v3.w
0x00000500:     mul oDepth {min16f}, r0.x {min2_8f}, v3.z

// approximately 54 instruction slots used (9 texture, 45 arithmetic)
