    vs_3_0
0x000002AC:     def c72, 3, 0, 1, 2
0x000002C4:     def c73, 0.159154937, 0.5, 6.28318548, -3.14159274
0x000002DC:     def c74, 1.44269502, 1, 0, 0.693147182
0x000002F4:     def c75, 0.00999999978, 0.25, 0, 0
0x0000030C:     dcl_position v0
0x00000318:     dcl_normal v1
0x00000324:     dcl_texcoord v2
0x00000330:     dcl_blendweight v3
0x0000033C:     dcl_blendindices v4
0x00000348:     dcl_2d s0
0x00000354:     dcl_position o0
0x00000360:     dcl_color o1
0x0000036C:     dcl_texcoord o2.xy
0x00000378:     dcl_texcoord1 o3.xyz
0x00000384:     dcl_fog o4.x
0x00000390:     dcl_texcoord2 o5
0x0000039C:     mul r0, c72.zzyy, v2.xyxx
0x000003AC:     texldl r0, r0, s0
0x000003BC:     mul r0.yz, c72.x, v4.xxyw
0x000003CC:     mova a0.xy, r0.zyzw
0x000003D8:     mul r1, v0.y, c1[a0.x]
0x000003EC:     mad r1, v0.x, c0[a0.x], r1
0x00000404:     mad r1, v0.z, c2[a0.x], r1
0x0000041C:     mad r1, v0.w, c72.yyyz, r1
0x00000430:     mul r1, r1, v3.y
0x00000440:     mul r2, v0.y, c1[a0.y]
0x00000454:     mad r2, v0.x, c0[a0.y], r2
0x0000046C:     mad r2, v0.z, c2[a0.y], r2
0x00000484:     mad r2, v0.w, c72.yyyz, r2
0x00000498:     mad r1, r2, v3.x, r1
0x000004AC:     add r1.y, r0.x, r1.y
0x000004BC:     dp4 o0.x, r1, c59
0x000004CC:     dp4 o0.y, r1, c60
0x000004DC:     dp4 o0.z, r1, c61
0x000004EC:     dp4 o0.w, r1, c62
0x000004FC:     mul r0.xyz, r1.y, c64
0x0000050C:     mad r0.xyz, r1.x, c63, r0
0x00000520:     mad r0.xyz, r1.z, c65, r0
0x00000534:     mad r0.xyz, r1.w, c66, r0
0x00000548:     dp3 r1.x, v1, c67
0x00000558:     dp3 r1.y, v1, c68
0x00000568:     dp3 r1.z, v1, c69
0x00000578:     nrm r2.xyz, r1
0x00000584:     dp3_sat r0.w, r2, -c48
0x00000594:     mul r0.w, r0.w, r0.w
0x000005A4:     mul r0.w, r0.w, r0.w
0x000005B4:     mul r0.w, r0.w, r0.w
0x000005C4:     mul r1, r0.w, c49
0x000005D4:     dp3_sat r0.w, r2, -c50
0x000005E4:     mul r0.w, r0.w, r0.w
0x000005F4:     mul r0.w, r0.w, r0.w
0x00000604:     mul r0.w, r0.w, r0.w
0x00000614:     mul r3, r0.w, c51
0x00000624:     mov r4.y, c72.y
0x00000630:     slt r0.w, r4.y, c70.x
0x00000640:     slt r2.w, r0.w, c70.x
0x00000650:     mul r3, r3, r2.w
0x00000660:     mad r1, r0.w, r1, r3
0x00000674:     lrp r3.x, r2.w, c72.w, r0.w
0x00000688:     slt r0.w, r3.x, c70.x
0x00000698:     mul r0.w, r0.w, r2.w
0x000006A8:     dp3_sat r2.w, r2, -c52
0x000006B8:     mul r2.w, r2.w, r2.w
0x000006C8:     mul r2.w, r2.w, r2.w
0x000006D8:     mul r2.w, r2.w, r2.w
0x000006E8:     mul r3, r2.w, c53
0x000006F8:     mad r1, r0.w, r3, r1
0x0000070C:     mad r3, r1.xyzx, c74.yyyz, c74.zzzw
0x00000720:     add r1.xy, r0_abs.yzzw, c72.z
0x00000730:     log r0.w, r1.x
0x0000073C:     rsq r4.w, r1.y
0x00000748:     mul r1.w, r0.w, r1.w
0x00000758:     mov r5.xy, c73
0x00000764:     mad r0.w, c90.x, r5.x, r5.y
0x00000778:     frc r0.w, r0.w
0x00000784:     mad r0.w, r0.w, c73.z, c73.w
0x00000798:     sincos r5.xy, r0.w
0x000007A4:     mov r1.xy, r5.yxzw
0x000007B0:     lrp r6.y, r0.x, r5.x, r5.y
0x000007C4:     mul r0.w, r0.x, c74.x
0x000007D4:     exp r1.z, r0.w
0x000007E0:     mul o1, r1, r3
0x000007F0:     dp3 r0.w, r0, r0
0x00000800:     rsq r0.w, r0.w
0x0000080C:     rcp r0.w, r0.w
0x00000818:     mul r0.w, r0.w, c71.x
0x00000828:     mul o4.x, r0.w, c75.x
0x00000838:     slt r0.w, -r0.z, r0.z
0x00000848:     slt r1.x, r0.z, -r0.z
0x00000858:     add r6.x, r0.w, -r1.x
0x00000868:     frc r0.w, c90.x
0x00000874:     mad r1.xy, v2, r0.w, r6
0x00000888:     mul r1.zw, r1.xyxy, c57.xyxy
0x00000898:     mul r1.xy, r1, c58
0x000008A8:     add o2.xy, r1.wyzw, r1.zxzw
0x000008B8:     mul r1.xyz, r0.zxyw, r2.yzxw
0x000008C8:     mad r4.xyz, r0.yzxw, r2.zxyw, -r1
0x000008DC:     dp3 r0.x, c55, r0
0x000008EC:     mul r0, r0.x, c56
0x000008FC:     mad r0, r4, c54, r0
0x00000910:     mov o3.xyz, r2
0x0000091C:     min r1, r0.wzyx, c72.z
0x0000092C:     max r1, r0, r1
0x0000093C:     sge r2, r0, c73.y
0x0000094C:     slt r0, c73.y, r0
0x0000095C:     mad r0, r1, r2, r0
0x00000970:     rcp r1.x, r0.x
0x0000097C:     add r1.x, -r0.y, r1.x
0x0000098C:     slt r1.y, c75.y, r0.x
0x0000099C:     mad o5.y, r1.y, r1.x, r0.y
0x000009B0:     mov o5.xzw, r0

// approximately 105 instruction slots used (2 texture, 103 arithmetic)
