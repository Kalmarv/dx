    ps_1_1
          nop
   0:     mov r0, r1
   1:     add r0, r1, r2
   2:     sub r0, r1, r2
   3:     mad r0, r1, r2, r3
   4:     mul r0, r1, r2
   5:     rcp r0, r1
   6:     rsq r0, r1
   7:     dp3 r0, r1, r2
   8:     dp4 r0, r1, r2
   9:     min r0, r1, r2
  10:     max r0, r1, r2
  11:     slt r0, r1, r2
  12:     sge r0, r1, r2
  13:     exp r0, r1
  14:     log r0, r1
  15:     lit r0, r1
  16:     dst r0, r1, r2
  17:     lrp r0, r1, r2, r3
  18:     frc r0, r1
  19:     m4x4 r0, r1, r2
  20:     m4x3 r0, r1, r2
  21:     m3x4 r0, r1, r2
  22:     m3x3 r0, r1, r2
  23:     m3x2 r0, r1, r2
  24:     call r1
  25:     callnz r1, r2
  26:     loop r1, r2
  27:       ret
  28:     endloop
          label r1
          dcl_texcoord v0
  29:     pow r0, r1, r2
  30:     crs r0, r1, r2
  31:     sgn r0, r1, r2, r3
  32:     abs r0, r1
  33:     nrm r0, r1
  34:     sincos r0, r1, r2, r3
  35:     rep r1
  36:     endrep
  37:     if r1
  38:       if_gt r1, r2
  39:       else
  40:       endif
  41:       break
  42:       break_gt r1, r2
  43:       mova r0, r1
            defb b0, true
            defi i0, 1, 2, 3, 4
  44:       texcoord r0
  44:       texkill r0
  45:       tex r0
  45:       texbem r0, r1
  45:       texbeml r0, r1
  45:       texreg2ar r0, r1
  45:       texreg2gb r0, r1
  45:       texm3x2pad r0, r1
  45:       texm3x2tex r0, r1
  45:       texm3x3pad r0, r1
  45:       texm3x3tex r0, r1
  45:       texm3x3spec r0, r1, r2
  45:       texm3x3vspec r0, r1
  45:       expp r0, r1
  46:       logp r0, r1
  47:       cnd r0, r1, r2, r3
            def c0, 0x3f800000, 0x00000000, 0x00000000, 0x3f800000
  48:       texreg2rgb r0, r1
  48:       texdp3tex r0, r1
  48:       texm3x2depth r0, r1
  48:       texdp3 r0, r1
  48:       texm3x3 r0, r1
  48:       texdepth r0
  49:       cmp r0, r1, r2, r3
  50:       bem r0, r1, r2
  51:       dp2add r0, r1, r2, r3
  52:       dsx r0, r1
  53:       dsy r0, r1
  54:       texldd r0, r1, r2, r3, r4
  55:       setp_gt r0, r1, r2
  56:       texldl r0, r1, r2
  56:       break_pp_centroid r1.z
  57:       phase
            dcl_texcoord1 v1

// approximately 77 instruction slots used (20 texture, 57 arithmetic)
