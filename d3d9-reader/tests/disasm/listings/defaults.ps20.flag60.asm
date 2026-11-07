    ps_2_0
0x0000020C:     dcl v0
0x00000218:     dcl t0.xy
0x00000224:     dcl_2d s0
0x00000230:     texld r0, t0, s0
0x00000240:     mov r1, c7
0x0000024C:     add r1, r1, c8
0x0000025C:     dp4 r2.x, v0, c0
0x0000026C:     dp4 r2.y, v0, c1
0x0000027C:     dp4 r2.z, v0, c2
0x0000028C:     dp4 r2.w, v0, c3
0x0000029C:     add r1, r1, r2
0x000002AC:     add r1, r1, c5.x
0x000002BC:     add r1, r1, c6.x
0x000002CC:     add r1, r1, c31
0x000002DC:     add r2.xyz, r1, c9
0x000002EC:     add r2.w, r1.w, c9.z
0x000002FC:     add r0, r0, r2
0x0000030C:     mov oC0, r0

// approximately 15 instruction slots used (1 texture, 14 arithmetic)
