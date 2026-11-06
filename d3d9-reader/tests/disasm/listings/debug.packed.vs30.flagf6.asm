    vs_3_0
      0x000003F8:     def c6, 0x3f800000, 0x40000000, 0x00000000, 0x00000000
      0x00000410:     dcl_position v0
      0x0000041C:     dcl_texcoord v1
      0x00000428:     dcl_position o0
      0x00000434:     dcl_texcoord o1.xy
      0x00000440:     dcl_texcoord1 o2.x
   0  0x0000044C:     mov r0, c5
   1  0x00000458:     mad o0, v0, r0, c3
   2  0x0000046C:     mul r0.xy, c4, v0
   3  0x0000047C:     mul r1.y, r0.x, c0.y
   4  0x0000048C:     mul r1.z, r0.x, c1.y
   5  0x0000049C:     mul r0.yz, r0.y, r1
   6  0x000004AC:     mul r0.x, r0.x, r0.x
   7  0x000004BC:     mad r1.x, c0.x, r0.x, r0.y
   8  0x000004D0:     mad r1.y, c1.x, r0.x, r0.z
   9  0x000004E4:     add o1.xy, r1, v1
  10  0x000004F4:     mov r0.xy, c4
  11  0x00000500:     mad r0.xy, v0, r0, c6
  12  0x00000514:     mul o2.x, r0.y, r0.x

// approximately 13 instruction slots used
