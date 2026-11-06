    vs_2_0
          dcl_position v0
   0:     mov oPos, v0
   1:     mov r3, c0
   2:     sgn r0, r3, r1, r2
   5:     mov oT0, r0
   6:     mov r4, c1
   7:     crs r5.xyz, r4, c2
   9:     mov oT1.xyz, r5

// approximately 10 instruction slots used
