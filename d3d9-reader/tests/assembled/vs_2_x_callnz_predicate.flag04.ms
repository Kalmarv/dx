    vs_2_x
          dcl_position v0
   0:     mov oPos, v0
   1:     mov r1, c1
   2:     setp_gt p0.x, c0.x, r1.x
   3:     mov r0, c2
   4:     callnz l0, p0.x
   7:     mov oT0, r0
   8:     ret
          label l0
   9:     add r0, r0, r0
  10:     ret

// approximately 11 instruction slots used
