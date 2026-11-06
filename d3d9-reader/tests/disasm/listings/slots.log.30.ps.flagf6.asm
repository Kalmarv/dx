    ps_3_0
      0x00000058:     def c0, 0x3f317218, 0x00000000, 0x00000000, 0x00000000
      0x00000070:     dcl_texcoord v0
   0  0x0000007C:     log r0.x, v0.x
   1  0x00000088:     log r0.y, v0.y
   2  0x00000094:     log r0.z, v0.z
   3  0x000000A0:     log r0.w, v0.w
   4  0x000000AC:     mul oC0, r0, c0.x

// approximately 5 instruction slots used
