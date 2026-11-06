    ps_2_0
          dcl t0
   0:     mov r9, c1
   1:     exp r0, c0.x
   2:     log r1, c0.x
   3:     rcp r2, c0.x
   4:     rsq r3, c0.x
   5:     frc r4, c0
   6:     min r5, c0, r9
   7:     max r6, c0, r9
   8:     add r0, r0, r1
   9:     add r0, r0, r2
  10:     add r0, r0, r3
  11:     add r0, r0, r4
  12:     add r0, r0, r5
  13:     add r0, r0, r6
  14:     mov oC0, r0

// approximately 15 instruction slots used
