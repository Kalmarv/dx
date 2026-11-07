    ps_3_0
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
0x000001D0:     sgn r0, r1
0x000001DC:     abs r0, r1
0x000001E8:     nrm r0, r1
0x000001F4:     sincos r0, r1
0x00000200:     rep r1
0x00000208:     endrep
0x0000020C:     if r1
0x00000214:       if_gt r1, r2
0x00000220:       else
0x00000224:       endif
0x00000228:       break
0x0000022C:       break_gt r1, r2
0x00000238:       mova r0, r1
0x00000244:       defb_d2 b0.yz, true
0x00000250:       defi_x2 i0., 1, 2, 3, 4
0x00000268:       texcrd r0
0x00000270:       texkill r0
0x00000278:       texld r0, r1, r2
0x00000288:       texbem r0, r1
0x00000294:       texbeml r0, r1
0x000002A0:       texreg2ar r0, r1
0x000002AC:       texreg2gb r0, r1
0x000002B8:       texm3x2pad r0, r1
0x000002C4:       texm3x2tex r0, r1
0x000002D0:       texm3x3pad r0, r1
0x000002DC:       texm3x3tex r0, r1
0x000002E8:       texm3x3spec r0, r1, r2
0x000002F8:       texm3x3vspec r0, r1
0x00000304:       expp r0, r1
0x00000310:       logp r0, r1
0x0000031C:       cnd r0, r1, r2, r3
0x00000330:       def_sat_pp_centroid c0.x, 1, 0, 0, 1
0x00000348:       texreg2rgb r0, r1
0x00000354:       texdp3tex r0, r1
0x00000360:       texm3x2depth r0, r1
0x0000036C:       texdp3 r0, r1
0x00000378:       texm3x3 r0, r1
0x00000384:       texdepth r0
0x0000038C:       cmp r0, r1, r2, r3
0x000003A0:       bem r0, r1, r2
0x000003B0:       dp2add r0, r1, r2, r3
0x000003C4:       dsx r0, r1
0x000003D0:       dsy r0, r1
0x000003DC:       texldd r0, r1, r2, r3, r4
0x000003F4:       setp_gt r0, r1, r2
0x00000404:       texldl r0, r1, r2
0x00000414:       break_pp_centroid r1.z
0x0000041C:       phase
0x00000420:       dcl_texcoord1 v1

// approximately 124 instruction slots used (20 texture, 104 arithmetic)
