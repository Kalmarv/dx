    ps_3_0
          dcl_texcoord v0
   0:     mov r1, c1
   1:     mov r2, c2
   2:     dp2add r0, c0, r1, r2.x
   4:     mov oC0, r0

// approximately 5 instruction slots used
