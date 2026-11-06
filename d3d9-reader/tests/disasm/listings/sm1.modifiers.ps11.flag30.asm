    ps_1_1
0x00000004:     def c0, 1, 0.5, 0, 1
0x0000001C:     tex t0
0x00000024:     tex t1
0x0000002C:     mul_x2 r0, t0_bx2, v0
0x0000003C:     add_sat r0, r0, 1-t1
0x0000004C:     cnd r0, r0.w, c0, v0

// approximately 5 instruction slots used (2 texture, 3 arithmetic)
