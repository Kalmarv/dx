    ps_1_2
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
  14  0x000000DC:     log r0, r1
  15  0x000000E8:     lit r0, r1
  16  0x000000F4:     dst r0, r1, r2
  17  0x00000104:     lrp r0, r1, r2, r3
  18  0x00000118:     frc r0, r1
  19  0x00000124:     m4x4 r0, r1, r2
  20  0x00000134:     m4x3 r0, r1, r2
  21  0x00000144:     m3x4 r0, r1, r2
  22  0x00000154:     m3x3 r0, r1, r2
  23  0x00000164:     m3x2 r0, r1, r2
  24  0x00000174:     call r1
  25  0x0000017C:     callnz r1, r2
  26  0x00000188:     loop r1, r2
  27  0x00000194:       ret
  28  0x00000198:     endloop
      0x0000019C:     label r1
      0x000001A4:     dcl_texcoord v0
  29  0x000001B0:     pow r0, r1, r2
  30  0x000001C0:     crs r0, r1, r2
  31  0x000001D0:     sgn r0, r1, r2, r3
  32  0x000001E4:     abs r0, r1
  33  0x000001F0:     nrm r0, r1
  34  0x000001FC:     sincos r0, r1, r2, r3
  35  0x00000210:     rep r1
  36  0x00000218:     endrep
  37  0x0000021C:     if r1
  38  0x00000224:       if_gt r1, r2
  39  0x00000230:       else
  40  0x00000234:       endif
  41  0x00000238:       break
  42  0x0000023C:       break_gt r1, r2
  43  0x00000248:       mova r0, r1
      0x00000254:       defb b0, true
      0x00000260:       defi i0, 1, 2, 3, 4
  44  0x00000278:       texcoord r0
  44  0x00000280:       texkill r0
  45  0x00000288:       tex r0
  45  0x00000290:       texbem r0, r1
  45  0x0000029C:       texbeml r0, r1
  45  0x000002A8:       texreg2ar r0, r1
  45  0x000002B4:       texreg2gb r0, r1
  45  0x000002C0:       texm3x2pad r0, r1
  45  0x000002CC:       texm3x2tex r0, r1
  45  0x000002D8:       texm3x3pad r0, r1
  45  0x000002E4:       texm3x3tex r0, r1
  45  0x000002F0:       texm3x3spec r0, r1, r2
  45  0x00000300:       texm3x3vspec r0, r1
  45  0x0000030C:       expp r0, r1
  46  0x00000318:       logp r0, r1
  47  0x00000324:       cnd r0, r1, r2, r3
      0x00000338:       def c0, 0x3f800000, 0x00000000, 0x00000000, 0x3f800000
  48  0x00000350:       texreg2rgb r0, r1
  48  0x0000035C:       texdp3tex r0, r1
  48  0x00000368:       texm3x2depth r0, r1
  48  0x00000374:       texdp3 r0, r1
  48  0x00000380:       texm3x3 r0, r1
  48  0x0000038C:       texdepth r0
  49  0x00000394:       cmp r0, r1, r2, r3
  50  0x000003A8:       bem r0, r1, r2
  51  0x000003B8:       dp2add r0, r1, r2, r3
  52  0x000003CC:       dsx r0, r1
  53  0x000003D8:       dsy r0, r1
  54  0x000003E4:       texldd r0, r1, r2, r3, r4
  55  0x000003FC:       setp_gt r0, r1, r2
  56  0x0000040C:       texldl r0, r1, r2
  56  0x0000041C:       break_pp_centroid r1.z
  57  0x00000424:       phase
      0x00000428:       dcl_texcoord1 v1

// approximately 77 instruction slots used (20 texture, 57 arithmetic)
