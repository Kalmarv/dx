    ps_3_0
      0x000000A8:     dcl_texcoord v0
   0  0x000000B4:     if b0
   3  0x000000BC:       mul oC0, c0, v0
   4  0x000000CC:     else
   5  0x000000D0:       add oC0, c1, v0
   6  0x000000E0:     endif

// approximately 7 instruction slots used
