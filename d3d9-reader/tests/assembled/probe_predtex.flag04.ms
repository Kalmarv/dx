    ps_2_x
          dcl t0
          dcl_2d s0
   0:     mov r1, c1
   1:     setp_gt p0, c0, r1
   2:     mov r0, c2
   3:     (p0.y) add r0, r0, c3
   5:     (!p0) texld r1, t0, s0
   6:     mov oC0, r0

// approximately 8 instruction slots used (1 texture, 7 arithmetic)
