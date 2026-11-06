    ps_3_0
          def c0, 1, 0, 0, 1
          def c1, 0, 1, 0, 1
          def c2, 0, 0, 0, 0
          dcl vFace
   0:     if_gt vFace, c2.x
   3:       mov r0, c0
   4:     else
   5:       mov r0, c1
   6:     endif
   7:     mov oC0, r0

// approximately 8 instruction slots used
