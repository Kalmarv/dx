    ps_3_0
      0x00000080:     defi i0, 5, 0, 0, 0
      0x00000098:     dcl_texcoord v0
   0  0x000000A4:     mov r0, v0
   1  0x000000B0:     rep i0
   4  0x000000B8:       mad r0, r0, r0.yzwx, c0
   5  0x000000CC:     endrep
   7  0x000000D0:     mov oC0.xyz, r0
   8  0x000000DC:     mov oC0.w, r0.w

// approximately 9 instruction slots used
