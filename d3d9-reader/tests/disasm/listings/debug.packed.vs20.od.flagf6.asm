    vs_2_0
      0x00000450:     def c6, 0x3f800000, 0x40000000, 0x00000000, 0x00000000
      0x00000468:     dcl_position v0
      0x00000474:     dcl_texcoord v1
   0  0x00000480:     mul r0.x, v0.x, c4.x
   1  0x00000490:     mul r0.y, v0.y, c4.y
   2  0x000004A0:     mov r0.x, r0.x
   3  0x000004AC:     mov r0.y, r0.y
   4  0x000004B8:     mul r0.zw, r0.x, c0.xyxy
   5  0x000004C8:     mul r1.xy, r0.x, c1
   6  0x000004D8:     add r1.z, r0.x, c6.x
   7  0x000004E8:     add r1.w, r0.y, c6.y
   8  0x000004F8:     mul r2, v0, c5
   9  0x00000508:     add r2, r2, c3
  10  0x00000518:     mul r0.z, r0.z, r0.x
  11  0x00000528:     mul r0.w, r0.w, r0.y
  12  0x00000538:     add r3.x, r0.w, r0.z
  13  0x00000548:     mul r0.x, r0.x, r1.x
  14  0x00000558:     mul r0.y, r0.y, r1.y
  15  0x00000568:     add r3.y, r0.y, r0.x
  16  0x00000578:     add r0.xy, r3, v1
  17  0x00000588:     mul r0.z, r1.w, r1.z
  18  0x00000598:     mov oPos, r2
  19  0x000005A4:     mov oT0.xy, r0
  20  0x000005B0:     mov oT1.x, r0.z

// approximately 21 instruction slots used
