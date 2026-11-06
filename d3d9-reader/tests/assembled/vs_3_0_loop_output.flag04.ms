    vs_3_0
          def c2, 1, 1, 1, 1
          dcl_position v0
          dcl_position o0
          dcl_texcoord o1
          dcl_texcoord1 o2
   0:     mov o0, v0
   1:     mov r0, c0
   2:     loop aL, i0
   5:       mov o0[aL], r0
   6:       add r0, r0, c2
   7:     endloop

// approximately 9 instruction slots used
