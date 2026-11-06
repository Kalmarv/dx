    vs_2_x
          dcl_position v0
   0:     mov oPos, v0
   1:     mov r1, c1
   2:     setp_gt p0, c0, r1
   3:     mov r0, c3
   4:     (p0) mov r0, c2
   6:     mov oT0, r0

// approximately 7 instruction slots used
