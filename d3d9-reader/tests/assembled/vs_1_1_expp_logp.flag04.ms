    vs_1_1
          dcl_position v0
   0:     mov oPos, v0
   1:     expp r0, c0.x
   2:     mov oT0.xy, r0
   3:     mov oT1.x, r0.w
   4:     logp r1, c0.y
   5:     mov oT2.xy, r1
   6:     mov oT3.x, r1.w

// approximately 7 instruction slots used
