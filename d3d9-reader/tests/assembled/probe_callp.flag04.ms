    ps_2_x
   0:     mov r1, c1
   1:     setp_gt p0, c0, r1
   2:     mov r0, c2
   3:     callnz l0, p0.y
   6:     mov oC0, r0
   7:     ret
          label l0
   8:     mov r0, c3
   9:     ret

// approximately 10 instruction slots used
