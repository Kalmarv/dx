    ps_3_0
          def c8, -4, -5, -6, -7
          def c9, 0, 1, 2, 3
          dcl_texcoord v0
   0:     mov r0, v0
   1:     mov r1.x, c9.x
   2:     rep i0
   5:       add r2, r1.x, -c9
   6:       add r3, r1.x, c8
   7:       mov r4.x, c9.x
   8:       cmp r1.y, -r2_abs.x, c0.x, r4.x
   9:       cmp r1.y, -r2_abs.y, c1.x, r1.y
  10:       cmp r1.y, -r2_abs.z, c2.x, r1.y
  11:       cmp r1.y, -r2_abs.w, c3.x, r1.y
  12:       cmp r1.y, -r3_abs.x, c4.x, r1.y
  13:       cmp r1.y, -r3_abs.y, c5.x, r1.y
  14:       cmp r1.y, -r3_abs.z, c6.x, r1.y
  15:       cmp r1.y, -r3_abs.w, c7.x, r1.y
  16:       if_lt r1.y, r0.x
  19:         break_ne c9.y, -c9.y
  22:       endif
  23:       cmp r4, -r2_abs.x, c0, r4.x
  24:       cmp r4, -r2_abs.y, c1, r4
  25:       cmp r4, -r2_abs.z, c2, r4
  26:       cmp r2, -r2_abs.w, c3, r4
  27:       cmp r2, -r3_abs.x, c4, r2
  28:       cmp r2, -r3_abs.y, c5, r2
  29:       cmp r2, -r3_abs.z, c6, r2
  30:       cmp r2, -r3_abs.w, c7, r2
  31:       add r0, r2, r0
  32:       add r1.x, r1.x, c9.y
  33:     endrep
  35:     mov oC0.yzw, r0
  36:     mov oC0.x, r0.x

// approximately 37 instruction slots used
