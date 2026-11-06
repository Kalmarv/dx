    vs_2_0
          dcl_position v0
   0:     mov r9, c1
   1:     frc r4, c0
   2:     min r5, c0, r9
   3:     max r6, c0, r9
   4:     exp r0, c0.x
   5:     log r1, c0.x
   6:     mov oPos, v0
   7:     mov oT0, r4
   8:     mov oT1, r5
   9:     mov oT2, r6
  10:     mov oT3, r0
  11:     mov oT4, r1

// approximately 12 instruction slots used
