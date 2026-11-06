    vs_2_0
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
  23:     m4x3 r0, r1, r2
  26:     m3x4 r0, r1, r2
  30:     m3x3 r0, r1, r2
  33:     m3x2 r0, r1, r2
  35:     call r1
  37:     callnz r1, r2
  40:     loop r1, r2
  43:       ret
  44:     endloop
          label r1
          dcl_texcoord v0
  46:     pow r0, r1, r2
  49:     crs r0, r1, r2
  51:     sgn r0, r1, r2, r3
  54:     abs r0, r1
  55:     nrm r0, r1
  58:     sincos r0, r1, r2, r3
  66:     rep r1
  69:     endrep
  71:     if r1
  74:       if_gt r1, r2
  77:       else
  78:       endif
  79:       break
  80:       break_gt r1, r2
  83:       mova r0, r1
            defb b0, true
            defi i0, 1, 2, 3, 4
  84:       texcrd r0
  84:       texkill r0
  85:       texld r0, r1, r2
  85:       texbem r0, r1
  85:       texbeml r0, r1
  85:       texreg2ar r0, r1
  85:       texreg2gb r0, r1
  85:       texm3x2pad r0, r1
  85:       texm3x2tex r0, r1
  85:       texm3x3pad r0, r1
  85:       texm3x3tex r0, r1
  85:       texm3x3spec r0, r1, r2
  85:       texm3x3vspec r0, r1
  85:       expp r0, r1
  86:       logp r0, r1
  87:       cnd r0, r1, r2, r3
            def c0, 0x3f800000, 0x00000000, 0x00000000, 0x3f800000
  88:       texreg2rgb r0, r1
  88:       texdp3tex r0, r1
  88:       texm3x2depth r0, r1
  88:       texdp3 r0, r1
  88:       texm3x3 r0, r1
  88:       texdepth r0
  89:       cmp r0, r1, r2, r3
  90:       bem r0, r1, r2
  92:       dp2add r0, r1, r2, r3
  94:       dsx r0, r1
  96:       dsy r0, r1
  98:       texldd r0, r1, r2, r3, r4
 100:       setp_gt r0, r1, r2
 101:       texldl r0, r1, r2
 101:       break_pp_centroid r1.z
 104:       phase
            dcl_texcoord1 v1

// approximately 124 instruction slots used (20 texture, 104 arithmetic)
