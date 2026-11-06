    vs_1_1
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
  23:     log r0, r1
  33:     lit r0, r1
  34:     dst r0, r1, r2
  35:     lrp r0, r1, r2, r3
  36:     frc r0, r1
  39:     m4x4 r0, r1, r2
  43:     m4x3 r0, r1, r2
  46:     m3x4 r0, r1, r2
  50:     m3x3 r0, r1, r2
  53:     m3x2 r0, r1, r2
  55:     call r1
  57:     callnz r1, r2
  60:     loop r1, r2
  63:       ret
  64:     endloop
          label r1
          dcl_texcoord v0
  66:     pow r0, r1, r2
  69:     crs r0, r1, r2
  71:     sgn r0, r1, r2, r3
  74:     abs r0, r1
  75:     nrm r0, r1
  78:     sincos r0, r1, r2, r3
  86:     rep r1
  89:     endrep
  91:     if r1
  94:       if_gt r1, r2
  97:       else
  98:       endif
  99:       break
 100:       break_gt r1, r2
 103:       mova r0, r1
            defb b0, true
            defi i0, 1, 2, 3, 4
 104:       texcoord r0
 104:       texkill r0
 105:       tex r0
 105:       texbem r0, r1
 105:       texbeml r0, r1
 105:       texreg2ar r0, r1
 105:       texreg2gb r0, r1
 105:       texm3x2pad r0, r1
 105:       texm3x2tex r0, r1
 105:       texm3x3pad r0, r1
 105:       texm3x3tex r0, r1
 105:       texm3x3spec r0, r1, r2
 105:       texm3x3vspec r0, r1
 105:       expp r0, r1
 106:       logp r0, r1
 107:       cnd r0, r1, r2, r3
            def c0, 1, 0, 0, 1
 108:       texreg2rgb r0, r1
 108:       texdp3tex r0, r1
 108:       texm3x2depth r0, r1
 108:       texdp3 r0, r1
 108:       texm3x3 r0, r1
 108:       texdepth r0
 109:       cmp r0, r1, r2, r3
 110:       bem r0, r1, r2
 112:       dp2add r0, r1, r2, r3
 114:       dsx r0, r1
 116:       dsy r0, r1
 118:       texldd r0, r1, r2, r3, r4
 120:       setp_gt r0, r1, r2
 121:       texldl r0, r1, r2
 121:       break_pp_centroid r1.z
 124:       phase
            dcl_texcoord1 v1

// approximately 144 instruction slots used (20 texture, 124 arithmetic)
