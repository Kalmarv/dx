    ps_2_x
      0x00000058:     def c0, 0x3f317218, 0x00000000, 0x00000000, 0x00000000
      0x00000070:     dcl t0
   0  0x0000007C:     log r0.x, t0.x
   1  0x00000088:     log r0.y, t0.y
   2  0x00000094:     log r0.z, t0.z
   3  0x000000A0:     log r0.w, t0.w
   4  0x000000AC:     mul r0, r0, c0.x
   5  0x000000BC:     mov oC0, r0

// approximately 6 instruction slots used
