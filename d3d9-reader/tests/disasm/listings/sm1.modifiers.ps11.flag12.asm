    ps_1_1
    def c0, 1, 0.5, 0, 1
    tex t0
    tex t1
    mul_x2 r0, t0_bx2, v0
    add_sat r0, r0, 1-t1
    cnd r0, r0.w, c0, v0

// approximately 5 instruction slots used (2 texture, 3 arithmetic)
