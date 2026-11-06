    vs_2_0
      0x000003C8:     dcl_position v0
   0  0x000003D4:     mul r0, v0.yzwx, c0.yzwx
      0x000003E4:     nop
   1  0x000003E8:     mov r0, r0
   2  0x000003F4:     add r0, r0, c3
   3  0x00000404:     mov r0, r0
      0x00000410:     nop
   4  0x00000414:     mov r0, r0
   5  0x00000420:     mul r0, r0, c2.zwxy
   6  0x00000430:     mov r0, r0
   7  0x0000043C:     add r0, r0, c1.yzwx
   8  0x0000044C:     mul r0, r0, c1.zwxy
   9  0x0000045C:     mov r1, -c0.wxyz
  10  0x00000468:     add r0, r0, r1
      0x00000478:     nop
  11  0x0000047C:     mov r0, r0
  12  0x00000488:     mul r0, r0.wxyz, r0
  13  0x00000498:     mov r0, r0
  14  0x000004A4:     mul r0, r0, c2
  15  0x000004B4:     add r0, r0, c3
  16  0x000004C4:     mov oPos, r0

// approximately 17 instruction slots used
