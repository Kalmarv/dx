    ps_2_0
      0x00000210:     dcl t0.xy
      0x0000021C:     dcl_2d s0
   0  0x00000228:     texld r0, t0, s0
   0  0x00000238:     mul r0, r0, c0
   1  0x00000248:     add r0, r0, c1
   2  0x00000258:     mov oC0, r0

// approximately 4 instruction slots used (1 texture, 3 arithmetic)
