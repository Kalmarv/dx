    ps_2_0
0x00000004:     nop
0x00000008:     mov r0, r1
0x00000014:     add r0, r1, r2
0x00000024:     sub r0, r1, r2
0x00000034:     mad r0, r1, r2, r3
0x00000048:     mul r0, r1, r2
0x00000058:     rcp r0, r1
0x00000064:     rsq r0, r1
0x00000070:     dp3 r0, r1, r2
0x00000080:     dp4 r0, r1, r2
0x00000090:     min r0, r1, r2
0x000000A0:     max r0, r1, r2
0x000000B0:     slt r0, r1, r2
0x000000C0:     sge r0, r1, r2
0x000000D0:     exp r0, r1
0x000000DC:     log r0, r1
0x000000E8:     lit r0, r1
0x000000F4:     dst r0, r1, r2
0x00000104:     lrp r0, r1, r2, r3
0x00000118:     frc r0, r1
0x00000124:     m4x4 r0, r1, r2
0x00000134:     m4x3 r0, r1, r2
0x00000144:     m3x4 r0, r1, r2
0x00000154:     m3x3 r0, r1, r2
0x00000164:     m3x2 r0, r1, r2
0x00000174:     call r1
0x0000017C:     callnz r1, r2
0x00000188:     loop r1, r2
0x00000194:       ret
0x00000198:     endloop
0x0000019C:     label r1
0x000001A4:     dcl_texcoord v0
0x000001B0:     pow r0, r1, r2
0x000001C0:     crs r0, r1, r2
0x000001D0:     sgn r0, r1, r2, r3
0x000001E4:     abs r0, r1
0x000001F0:     nrm r0, r1
0x000001FC:     sincos r0, r1, r2, r3
0x00000210:     rep r1
0x00000218:     endrep
0x0000021C:     if r1
0x00000224:       if_gt r1, r2
0x00000230:       else
0x00000234:       endif
0x00000238:       break
0x0000023C:       break_gt r1, r2
0x00000248:       mova r0, r1
0x00000254:       defb b0, true
0x00000260:       defi i0, 1, 2, 3, 4
0x00000278:       texcrd r0
0x00000280:       texkill r0
0x00000288:       texld r0, r1, r2
0x00000298:       texbem r0, r1
0x000002A4:       texbeml r0, r1
0x000002B0:       texreg2ar r0, r1
0x000002BC:       texreg2gb r0, r1
0x000002C8:       texm3x2pad r0, r1
0x000002D4:       texm3x2tex r0, r1
0x000002E0:       texm3x3pad r0, r1
0x000002EC:       texm3x3tex r0, r1
0x000002F8:       texm3x3spec r0, r1, r2
0x00000308:       texm3x3vspec r0, r1
0x00000314:       expp r0, r1
0x00000320:       logp r0, r1
0x0000032C:       cnd r0, r1, r2, r3
0x00000340:       def c0, 1, 0, 0, 1
0x00000358:       texreg2rgb r0, r1
0x00000364:       texdp3tex r0, r1
0x00000370:       texm3x2depth r0, r1
0x0000037C:       texdp3 r0, r1
0x00000388:       texm3x3 r0, r1
0x00000394:       texdepth r0
0x0000039C:       cmp r0, r1, r2, r3
0x000003B0:       bem r0, r1, r2
0x000003C0:       dp2add r0, r1, r2, r3
0x000003D4:       dsx r0, r1
0x000003E0:       dsy r0, r1
0x000003EC:       texldd r0, r1, r2, r3, r4
0x00000404:       setp_gt r0, r1, r2
0x00000414:       texldl r0, r1, r2
0x00000424:       break_pp_centroid r1.z
0x0000042C:       phase
0x00000430:       dcl_texcoord1 v1

// approximately 124 instruction slots used (20 texture, 104 arithmetic)
