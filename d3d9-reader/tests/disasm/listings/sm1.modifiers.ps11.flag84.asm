    ps_1_1
          def c0, 0x3f800000, 0x3f000000, 0x00000000, 0x3f800000
   0:     tex t0
   0:     tex t1
   0:     mul_x2 r0, t0_bx2, v0
   1:     add_sat r0, r0, 1-t1
   2:     cnd r0, r0.w, c0, v0

// approximately 5 instruction slots used (2 texture, 3 arithmetic)
