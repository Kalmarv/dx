    vs_3_0
          dcl_position v0
          dcl_position o0
          dcl_texcoord o1
   0:     mov o0, v0
   1:     mov r1, c1
   2:     mov r2, c2
   3:     sincos r0.xy, c0.x
  11:     mov o1, r0

// approximately 12 instruction slots used
