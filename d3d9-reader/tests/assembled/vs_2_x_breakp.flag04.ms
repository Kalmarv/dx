    vs_2_x
          def c2, 0, 0, 0, 0
          dcl_position v0
   0:     mov oPos, v0
   1:     mov r0, c2
   2:     mov r1, c1
   3:     rep i0
   6:       add r0, r0, c0
   7:       setp_ge p0.x, r0.x, r1.x
   8:       break p0.
  11:     endrep
  13:     mov oT0.x, r0.x

// approximately 14 instruction slots used
