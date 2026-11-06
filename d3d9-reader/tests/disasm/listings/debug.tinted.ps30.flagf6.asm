    ps_3_0
      0x000001FC:     dcl_texcoord v0.xy
      0x00000208:     dcl_2d s0
   0  0x00000214:     texld r0, v0, s0
   0  0x00000224:     mov r1, c0
   1  0x00000230:     mad oC0, r0, r1, c1

// approximately 3 instruction slots used (1 texture, 2 arithmetic)
