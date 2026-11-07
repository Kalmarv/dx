    ps_2_0
          dcl v0
          dcl t0.xy
          dcl_2d s0
   0:     texld r0, t0, s0
   0:     mov r1, c7
   1:     add r1, r1, c8
   2:     dp4 r2.x, v0, c0
   3:     dp4 r2.y, v0, c1
   4:     dp4 r2.z, v0, c2
   5:     dp4 r2.w, v0, c3
   6:     add r1, r1, r2
   7:     add r1, r1, c5.x
   8:     add r1, r1, c6.x
   9:     add r1, r1, c31
  10:     add r2.xyz, r1, c9
  11:     add r2.w, r1.w, c9.z
  12:     add r0, r0, r2
  13:     mov oC0, r0

// approximately 15 instruction slots used (1 texture, 14 arithmetic)
