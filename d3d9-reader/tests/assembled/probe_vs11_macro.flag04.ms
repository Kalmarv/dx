    vs_1_1
          dcl_position v0
   0:     exp r0, c0.x
  10:     log r1, c0.x
  20:     lit r2, c1
  21:     mov r5, c1
  22:     dst r3, c0, r5
  23:     m4x4 oPos, v0, c4
  27:     mov oT0, r0
  28:     mov oT1, r1
  29:     mov oT2, r2
  30:     mov oT3, r3

// approximately 31 instruction slots used
