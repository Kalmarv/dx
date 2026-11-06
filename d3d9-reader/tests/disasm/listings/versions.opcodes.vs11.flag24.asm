    vs_1_1
      0x00000004:     nop
   0  0x00000008:     mov r0, r1
   1  0x00000014:     add r0, r1, r2
   2  0x00000024:     sub r0, r1, r2
   3  0x00000034:     mad r0, r1, r2, r3
   4  0x00000048:     mul r0, r1, r2
   5  0x00000058:     rcp r0, r1
   6  0x00000064:     rsq r0, r1
   7  0x00000070:     dp3 r0, r1, r2
   8  0x00000080:     dp4 r0, r1, r2
   9  0x00000090:     min r0, r1, r2
  10  0x000000A0:     max r0, r1, r2
  11  0x000000B0:     slt r0, r1, r2
  12  0x000000C0:     sge r0, r1, r2
  13  0x000000D0:     exp r0, r1
  23  0x000000DC:     log r0, r1
  33  0x000000E8:     lit r0, r1
  34  0x000000F4:     dst r0, r1, r2
  35  0x00000104:     lrp r0, r1, r2, r3
  36  0x00000118:     frc r0, r1
  39  0x00000124:     m4x4 r0, r1, r2
  43  0x00000134:     m4x3 r0, r1, r2
  46  0x00000144:     m3x4 r0, r1, r2
  50  0x00000154:     m3x3 r0, r1, r2
  53  0x00000164:     m3x2 r0, r1, r2
  55  0x00000174:     call r1
  57  0x0000017C:     callnz r1, r2
  60  0x00000188:     loop r1, r2
  63  0x00000194:       ret
  64  0x00000198:     endloop
      0x0000019C:     label r1
      0x000001A4:     dcl_texcoord v0
  66  0x000001B0:     pow r0, r1, r2
  69  0x000001C0:     crs r0, r1, r2
  71  0x000001D0:     sgn r0, r1, r2, r3
  74  0x000001E4:     abs r0, r1
  75  0x000001F0:     nrm r0, r1
  78  0x000001FC:     sincos r0, r1, r2, r3
  86  0x00000210:     rep r1
  89  0x00000218:     endrep
  91  0x0000021C:     if r1
  94  0x00000224:       if_gt r1, r2
  97  0x00000230:       else
  98  0x00000234:       endif
  99  0x00000238:       break
 100  0x0000023C:       break_gt r1, r2
 103  0x00000248:       mova r0, r1
      0x00000254:       defb b0, true
      0x00000260:       defi i0, 1, 2, 3, 4
 104  0x00000278:       texcoord r0
 104  0x00000280:       texkill r0
 105  0x00000288:       tex r0
 105  0x00000290:       texbem r0, r1
 105  0x0000029C:       texbeml r0, r1
 105  0x000002A8:       texreg2ar r0, r1
 105  0x000002B4:       texreg2gb r0, r1
 105  0x000002C0:       texm3x2pad r0, r1
 105  0x000002CC:       texm3x2tex r0, r1
 105  0x000002D8:       texm3x3pad r0, r1
 105  0x000002E4:       texm3x3tex r0, r1
 105  0x000002F0:       texm3x3spec r0, r1, r2
 105  0x00000300:       texm3x3vspec r0, r1
 105  0x0000030C:       expp r0, r1
 106  0x00000318:       logp r0, r1
 107  0x00000324:       cnd r0, r1, r2, r3
      0x00000338:       def c0, 1, 0, 0, 1
 108  0x00000350:       texreg2rgb r0, r1
 108  0x0000035C:       texdp3tex r0, r1
 108  0x00000368:       texm3x2depth r0, r1
 108  0x00000374:       texdp3 r0, r1
 108  0x00000380:       texm3x3 r0, r1
 108  0x0000038C:       texdepth r0
 109  0x00000394:       cmp r0, r1, r2, r3
 110  0x000003A8:       bem r0, r1, r2
 112  0x000003B8:       dp2add r0, r1, r2, r3
 114  0x000003CC:       dsx r0, r1
 116  0x000003D8:       dsy r0, r1
 118  0x000003E4:       texldd r0, r1, r2, r3, r4
 120  0x000003FC:       setp_gt r0, r1, r2
 121  0x0000040C:       texldl r0, r1, r2
 121  0x0000041C:       break_pp_centroid r1.z
 124  0x00000424:       phase
      0x00000428:       dcl_texcoord1 v1

// approximately 144 instruction slots used (20 texture, 124 arithmetic)
