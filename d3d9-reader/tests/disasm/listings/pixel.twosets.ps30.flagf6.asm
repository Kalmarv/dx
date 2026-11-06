    ps_3_0
      0x00000098:     def c1, 0x00000000, 0x00000000, 0x00000000, 0x00000000
      0x000000B0:     dcl_color v0
   0  0x000000BC:     mov r0, c1.x
   1  0x000000C8:     rep i0
   4  0x000000D0:       add r0, r0, v0
   5  0x000000E0:     endrep
   7  0x000000E4:     mul oC0, r0, c0.y

// approximately 8 instruction slots used
