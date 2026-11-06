    ps_1_1
   0  0x00000004:     tex t0
   0  0x0000000C:     tex t1
   0  0x00000014:     mul r0.xyz, t0, v0
      0x00000024:   + mul_x2 r0.w, t1, v0
   1  0x00000034:     add r0.xyz, r0, t1
      0x00000044:   + add_sat r0.w, r0, c0
   2  0x00000054:     mov r1, r0

// approximately 5 instruction slots used (2 texture, 3 arithmetic)
