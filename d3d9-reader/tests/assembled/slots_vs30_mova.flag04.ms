    vs_3_0
          dcl_position v0
          dcl_position o0
          dcl_texcoord o1
   0:     mov o0, v0
   1:     mov r1, c1
   2:     mov r2, c2
   3:     mova a0.x, c0.x
   4:     mov r0, c0[a0.x]
   5:     mov o1, r0

// approximately 6 instruction slots used
